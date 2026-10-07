/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { createLogger } from 'tgui/logging';

const logger = createLogger('AudioPlayer');

// AQUILA EDIT START - jukebox distance falloff, echo and muffling
//
// Where Web Audio exists (BYOND 516+ / WebView2), music goes through a graph:
//   element -> lowpass -> dry ----------------------> master -> speakers
//                      -> delay (+feedback) -> echo -^
//                      -> convolver (reverb) -> reverb -^
// so volume changes glide, distant music echoes and another deck sounds
// muffled. The element needs CORS for that; when the stream refuses it (or the
// audio context can't start) we fall back to a plain <audio> element.
// On old IE (BYOND 515) there is no Web Audio, so the plain element fakes it:
// volume changes are ramped by a timer in tiny steps, the echo is a quieter
// copy of the stream lagging behind ("taps"), and another deck is
// quieter with relatively more echo, like sound reflected through the hull.

const ECHO_DELAY = 0.28;
const ECHO_FEEDBACK = 0.35;
const ECHO_LEVEL = 0.45;
const REVERB_LEVEL = 0.7;
const REVERB_SECONDS = 2.2;
// Time constant (seconds) of Web Audio parameter glides
const GLIDE = 0.35;
// Plain element: max volume change per ramp tick
const GAIN_RAMP_STEP = 0.01;
const GAIN_RAMP_INTERVAL = 25;
// Plain element: muffled music is this much quieter
const PLAIN_MUFFLE_VOLUME = 0.4;
// Plain element echo copies: delay (s) and level relative to the music
// (one copy - every copy is another download of the stream)
const PLAIN_TAPS = [
  { delay: 0.3, level: 0.85 },
];
// How much the direct sound is lowered at full echo
const PLAIN_ECHO_DUCK = 0.4;
// How far an echo copy may drift before it gets re-seeked (s)
const TAP_MAX_DRIFT = 0.4;

const AudioContextClass = window.AudioContext || window.webkitAudioContext;

const clamp01 = value => Math.min(1, Math.max(0, value));

const createAudioElement = () => {
  const node = document.createElement('audio');
  node.style.setProperty('display', 'none');
  document.body.appendChild(node);
  return node;
};

// Stereo noise with an exponential tail, used as the reverb impulse
const createImpulse = context => {
  const length = Math.floor(context.sampleRate * REVERB_SECONDS);
  const impulse = context.createBuffer(2, length, context.sampleRate);
  for (let channel = 0; channel < 2; channel++) {
    const data = impulse.getChannelData(channel);
    for (let i = 0; i < length; i++) {
      data[i] = (Math.random() * 2 - 1) * Math.pow(1 - i / length, 3);
    }
  }
  return impulse;
};
// AQUILA EDIT END

export class AudioPlayer {
  constructor() {
    // Doesn't support HTMLAudioElement
    if (Byond.IS_LTE_IE9) {
      return;
    }
    // Set up the HTMLAudioElement node
    this.node = createAudioElement();
    this.setupElement(this.node);
    // Set up other properties
    this.playing = false;
    this.volume = 1;
    this.options = {};
    this.onPlaySubscribers = [];
    this.onStopSubscribers = [];
    // AQUILA EDIT START
    this.url = null;
    this.current = this.node;
    this.gain = 1;
    this.targetGain = 1;
    this.echo = 0;
    this.muffle = 0;
    this.fx = null;
    this.fxBroken = !AudioContextClass;
    this.taps = [];
    this.tapInterval = setInterval(() => this.syncTaps(), 250);
    // AQUILA EDIT END
    // Check every second to stop the playback at the right time
    this.playbackInterval = setInterval(() => {
      if (!this.playing) {
        return;
      }
      const shouldStop = this.options.end > 0
        && this.current.currentTime >= this.options.end;
      if (shouldStop) {
        this.stop();
      }
    }, 1000);
    // AQUILA EDIT - smooth volume changes of the plain element
    this.rampInterval = setInterval(() => {
      if (this.gain === this.targetGain) {
        return;
      }
      const delta = this.targetGain - this.gain;
      this.gain = Math.abs(delta) <= GAIN_RAMP_STEP
        ? this.targetGain
        : this.gain + (delta > 0 ? GAIN_RAMP_STEP : -GAIN_RAMP_STEP);
      if (this.current === this.node) {
        this.applyVolume();
      }
    }, GAIN_RAMP_INTERVAL);
  }

  // AQUILA EDIT START
  setupElement(node) {
    // Listen for playback start events
    node.addEventListener('canplaythrough', () => {
      if (node !== this.current || node.started) {
        return;
      }
      logger.log('canplaythrough');
      node.started = true;
      this.playing = true;
      node.playbackRate = this.options.pitch || 1;
      node.currentTime = this.options.start || 0;
      this.applyVolume(true);
      node.play();
      if (this.fx && node === this.fx.node) {
        this.checkFxRunning();
      }
      for (let subscriber of this.onPlaySubscribers) {
        subscriber();
      }
    });
    // Listen for playback stop events
    node.addEventListener('ended', () => {
      if (node !== this.current) {
        return;
      }
      logger.log('ended');
      this.stop();
    });
    // Listen for playback errors
    node.addEventListener('error', e => {
      // Clearing src on stop also raises an error - ignore that one
      const cleared = !node.src || node.src === window.location.href;
      if (node !== this.current || !this.url || cleared) {
        return;
      }
      if (this.fx && node === this.fx.node && !node.started) {
        // Most likely the stream refused CORS - play it without effects
        logger.log('fx playback error, falling back to plain audio');
        this.fallbackToPlain();
        return;
      }
      if (this.playing) {
        logger.log('playback error', e.error);
        this.stop();
      }
    });
  }

  // Builds the Web Audio graph on first use. Returns false if unavailable.
  ensureFx() {
    if (this.fxBroken) {
      return false;
    }
    if (this.fx) {
      return true;
    }
    try {
      const context = new AudioContextClass();
      const node = createAudioElement();
      node.crossOrigin = 'anonymous';
      this.setupElement(node);
      const source = context.createMediaElementSource(node);
      const lowpass = context.createBiquadFilter();
      lowpass.type = 'lowpass';
      lowpass.frequency.value = 20000;
      lowpass.Q.value = 0.7;
      const dry = context.createGain();
      const delay = context.createDelay(1);
      delay.delayTime.value = ECHO_DELAY;
      const feedback = context.createGain();
      feedback.gain.value = ECHO_FEEDBACK;
      const echo = context.createGain();
      echo.gain.value = 0;
      const convolver = context.createConvolver();
      convolver.buffer = createImpulse(context);
      const reverb = context.createGain();
      reverb.gain.value = 0;
      const master = context.createGain();
      master.gain.value = 0;
      source.connect(lowpass);
      lowpass.connect(dry);
      dry.connect(master);
      lowpass.connect(delay);
      delay.connect(feedback);
      feedback.connect(delay);
      delay.connect(echo);
      echo.connect(master);
      lowpass.connect(convolver);
      convolver.connect(reverb);
      reverb.connect(master);
      master.connect(context.destination);
      this.fx = { context, node, lowpass, echo, reverb, master };
      return true;
    } catch (err) {
      logger.log('web audio unavailable', err);
      this.fxBroken = true;
      return false;
    }
  }

  // The audio context may refuse to start (autoplay policy) - don't stay mute
  checkFxRunning() {
    const { context } = this.fx;
    if (context.state === 'running') {
      return;
    }
    context.resume();
    setTimeout(() => {
      if (this.current === this.fx.node && context.state !== 'running') {
        logger.log('audio context did not start, falling back');
        this.fxBroken = true;
        this.fallbackToPlain(this.fx.node.currentTime);
      }
    }, 1500);
  }

  fallbackToPlain(time) {
    const url = this.url;
    if (this.fx) {
      this.fx.node.pause();
      this.fx.node.started = false;
      this.fx.node.src = '';
    }
    this.current = this.node;
    if (time) {
      this.options = { ...this.options, start: time };
    }
    this.node.started = false;
    this.node.src = url;
  }

  applyVolume(instant = false) {
    if (this.fx && this.current === this.fx.node) {
      const { context, lowpass, echo, reverb, master } = this.fx;
      const now = context.currentTime;
      const glide = (param, value) => {
        if (instant) {
          param.cancelScheduledValues(now);
          param.setValueAtTime(value, now);
        }
        else {
          param.setTargetAtTime(value, now, GLIDE);
        }
      };
      const gain = this.targetGain;
      this.gain = gain;
      glide(master.gain, this.volume * gain);
      glide(echo.gain, this.echo * ECHO_LEVEL);
      glide(reverb.gain, this.echo * REVERB_LEVEL);
      // Far away takes the edge off the highs, another deck muffles hard
      const cutoff = this.muffle > 0
        ? 2500 - this.muffle * 2000
        : 20000 - this.echo * 15000;
      glide(lowpass.frequency, cutoff);
      return;
    }
    if (instant) {
      this.gain = this.targetGain;
    }
    const muffle = 1 - this.muffle * (1 - PLAIN_MUFFLE_VOLUME);
    const volume = this.volume * this.gain * muffle;
    // Wet/dry: the further away, the more of what you hear is the echo
    const dry = 1 - this.tapMix() * PLAIN_ECHO_DUCK;
    this.node.volume = clamp01(volume * dry);
    const mix = this.tapMix();
    for (let tap of this.taps) {
      tap.node.volume = clamp01(volume * mix * tap.level);
    }
  }

  // How loud the echo copies are (0-1): distance echo, more of it through a deck
  tapMix() {
    return Math.max(this.echo, this.muffle * 0.8);
  }

  // Keeps the echo copies of the plain element playing, lagging behind it
  syncTaps() {
    const active = this.playing && this.url
      && this.current === this.node && this.node.started
      && this.tapMix() > 0.02;
    if (!active) {
      for (let tap of this.taps) {
        if (!tap.node.paused) {
          tap.node.pause();
        }
      }
      return;
    }
    if (!this.taps.length) {
      for (let config of PLAIN_TAPS) {
        const tap = { ...config, node: createAudioElement(), url: null };
        tap.node.addEventListener('canplaythrough', () => {
          tap.ready = true;
        });
        this.taps.push(tap);
      }
    }
    const rate = this.node.playbackRate;
    for (let tap of this.taps) {
      if (tap.url !== this.url) {
        tap.url = this.url;
        tap.ready = false;
        tap.node.src = this.url;
        continue;
      }
      if (!tap.ready) {
        continue;
      }
      const target = this.node.currentTime - tap.delay * rate;
      if (target < 0) {
        continue;
      }
      tap.node.playbackRate = rate;
      if (tap.node.paused
        || Math.abs(tap.node.currentTime - target) > TAP_MAX_DRIFT) {
        tap.node.currentTime = target;
      }
      if (tap.node.paused) {
        tap.node.play();
      }
    }
    this.applyVolume();
  }
  // AQUILA EDIT END

  destroy() {
    if (!this.node) {
      return;
    }
    this.stop();
    document.body.removeChild(this.node);
    clearInterval(this.playbackInterval);
    clearInterval(this.rampInterval);
    clearInterval(this.tapInterval);
    for (let tap of this.taps) {
      document.body.removeChild(tap.node);
    }
    if (this.fx) {
      document.body.removeChild(this.fx.node);
      this.fx.context.close();
    }
  }

  play(url, options = {}) {
    if (!this.node) {
      return;
    }
    logger.log('playing', url, options);
    this.stopElements();
    this.playing = false;
    this.options = options;
    // AQUILA EDIT START
    this.url = url;
    this.targetGain = typeof options.volume === 'number' ? options.volume : 1;
    this.gain = this.targetGain;
    this.echo = typeof options.echo === 'number' ? options.echo : 0;
    this.muffle = typeof options.muffle === 'number' ? options.muffle : 0;
    this.current = this.ensureFx() ? this.fx.node : this.node;
    if (this.fx && this.current === this.fx.node) {
      this.fx.context.resume();
    }
    this.current.started = false;
    this.current.src = url;
    // AQUILA EDIT END
  }

  stop() {
    if (!this.node) {
      return;
    }
    if (this.playing) {
      for (let subscriber of this.onStopSubscribers) {
        subscriber();
      }
    }
    logger.log('stopping');
    this.playing = false;
    this.url = null;
    this.stopElements();
  }

  // AQUILA EDIT
  stopElements() {
    for (let node of [this.node, this.fx && this.fx.node]) {
      if (!node) {
        continue;
      }
      node.started = false;
      node.pause();
      node.src = '';
    }
    for (let tap of this.taps) {
      tap.node.pause();
      tap.node.src = '';
      tap.url = null;
      tap.ready = false;
    }
  }

  setVolume(volume) {
    if (!this.node) {
      return;
    }
    this.volume = volume;
    this.applyVolume();
  }

  // AQUILA EDIT
  setGain(gain, echo = 0, muffle = 0) {
    if (!this.node) {
      return;
    }
    this.targetGain = gain;
    this.echo = echo;
    this.muffle = muffle;
    this.applyVolume();
  }

  onPlay(subscriber) {
    if (!this.node) {
      return;
    }
    this.onPlaySubscribers.push(subscriber);
  }

  onStop(subscriber) {
    if (!this.node) {
      return;
    }
    this.onStopSubscribers.push(subscriber);
  }
}
