/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { createLogger } from 'tgui/logging';

const logger = createLogger('AudioPlayer');

// AQUILA EDIT - jukebox distance falloff and echo
// The echo is a second, quieter copy of the stream lagging behind the main one.
const ECHO_DELAY = 0.35;
const ECHO_LEVEL = 0.5;
// Max gain change per ramp tick, so distance changes fade instead of jumping
const GAIN_RAMP_STEP = 0.04;
const GAIN_RAMP_INTERVAL = 50;

const clamp01 = value => Math.min(1, Math.max(0, value));

export class AudioPlayer {
  constructor() {
    // Doesn't support HTMLAudioElement
    if (Byond.IS_LTE_IE9) {
      return;
    }
    // Set up the HTMLAudioElement node
    this.node = document.createElement('audio');
    this.node.style.setProperty('display', 'none');
    document.body.appendChild(this.node);
    // Set up other properties
    this.playing = false;
    this.volume = 1;
    // AQUILA EDIT - extra volume multiplier set by the server (jukebox distance falloff)
    this.gain = 1;
    this.targetGain = 1;
    this.echo = 0;
    this.url = null;
    this.echoNode = null;
    this.echoReady = false;
    this.options = {};
    this.onPlaySubscribers = [];
    this.onStopSubscribers = [];
    // Listen for playback start events
    this.node.addEventListener('canplaythrough', () => {
      logger.log('canplaythrough');
      this.playing = true;
      this.node.playbackRate = this.options.pitch || 1;
      this.node.currentTime = this.options.start || 0;
      this.applyVolume();
      this.node.play();
      this.syncEcho();
      for (let subscriber of this.onPlaySubscribers) {
        subscriber();
      }
    });
    // Listen for playback stop events
    this.node.addEventListener('ended', () => {
      logger.log('ended');
      this.stop();
    });
    // Listen for playback errors
    this.node.addEventListener('error', e => {
      if (this.playing) {
        logger.log('playback error', e.error);
        this.stop();
      }
    });
    // Check every second to stop the playback at the right time
    this.playbackInterval = setInterval(() => {
      if (!this.playing) {
        return;
      }
      const shouldStop = this.options.end > 0
        && this.node.currentTime >= this.options.end;
      if (shouldStop) {
        this.stop();
        return;
      }
      this.syncEcho();
    }, 1000);
    // AQUILA EDIT - smooth volume changes
    this.rampInterval = setInterval(() => {
      if (this.gain === this.targetGain) {
        return;
      }
      const delta = this.targetGain - this.gain;
      this.gain = Math.abs(delta) <= GAIN_RAMP_STEP
        ? this.targetGain
        : this.gain + (delta > 0 ? GAIN_RAMP_STEP : -GAIN_RAMP_STEP);
      this.applyVolume();
    }, GAIN_RAMP_INTERVAL);
  }

  destroy() {
    if (!this.node) {
      return;
    }
    this.node.stop();
    document.removeChild(this.node);
    clearInterval(this.playbackInterval);
    clearInterval(this.rampInterval);
  }

  play(url, options = {}) {
    if (!this.node) {
      return;
    }
    logger.log('playing', url, options);
    this.options = options;
    this.gain = typeof options.volume === 'number' ? options.volume : 1;
    this.targetGain = this.gain;
    this.echo = typeof options.echo === 'number' ? options.echo : 0;
    this.url = url;
    this.stopEcho();
    this.node.src = url;
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
    this.stopEcho();
    this.node.src = '';
  }

  setVolume(volume) {
    if (!this.node) {
      return;
    }
    this.volume = volume;
    this.applyVolume();
  }

  // AQUILA EDIT START
  setGain(gain, echo = 0) {
    if (!this.node) {
      return;
    }
    this.targetGain = gain;
    this.echo = echo;
    this.applyVolume();
    this.syncEcho();
  }

  applyVolume() {
    this.node.volume = clamp01(this.volume * this.gain);
    if (this.echoNode) {
      this.echoNode.volume = clamp01(
        this.volume * this.gain * this.echo * ECHO_LEVEL);
    }
  }

  stopEcho() {
    if (!this.echoNode) {
      return;
    }
    this.echoReady = false;
    this.echoNode.pause();
    this.echoNode.src = '';
  }

  // Starts, pauses or resyncs the echo copy to lag ECHO_DELAY behind
  syncEcho() {
    if (!this.playing || !this.url || this.echo <= 0) {
      if (this.echoNode && !this.echoNode.paused) {
        this.echoNode.pause();
      }
      return;
    }
    if (!this.echoNode) {
      this.echoNode = document.createElement('audio');
      this.echoNode.style.setProperty('display', 'none');
      document.body.appendChild(this.echoNode);
      this.echoNode.addEventListener('canplaythrough', () => {
        if (this.echoReady) {
          return;
        }
        this.echoReady = true;
        this.syncEcho();
      });
      this.echoNode.addEventListener('error', () => {
        this.echoReady = false;
      });
    }
    if (!this.echoReady) {
      if (!this.echoNode.src || this.echoNode.src === window.location.href) {
        this.echoNode.src = this.url;
      }
      return;
    }
    const target = this.node.currentTime - ECHO_DELAY;
    if (target < 0) {
      return;
    }
    this.echoNode.playbackRate = this.node.playbackRate;
    this.applyVolume();
    if (this.echoNode.paused
      || Math.abs(this.echoNode.currentTime - target) > 0.2) {
      this.echoNode.currentTime = target;
    }
    if (this.echoNode.paused) {
      this.echoNode.play();
    }
  }
  // AQUILA EDIT END

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
