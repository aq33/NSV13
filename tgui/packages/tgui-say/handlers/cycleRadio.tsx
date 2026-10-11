import { CHANNELS, RADIO_PREFIXES } from '../constants';
import { Modal } from '../types';

/** AQUILA: one stop of the TAB cycle - a channel plus an optional radio prefix */
type RadioStop = {
  channel: number;
  prefix: string;
};

const SAY = CHANNELS.indexOf('Say');
const RADIO = CHANNELS.indexOf('Radio');
const ME = CHANNELS.indexOf('Me');

/** Say -> Radio -> every radio channel the mob can talk on -> Me */
const getRadioStops = function (this: Modal): RadioStop[] {
  const stops: RadioStop[] = [
    { channel: SAY, prefix: '' },
    { channel: RADIO, prefix: '' },
  ];
  for (const prefix of this.fields.radioChannels) {
    if (RADIO_PREFIXES[prefix]) {
      stops.push({ channel: SAY, prefix });
    }
  }
  stops.push({ channel: ME, prefix: '' });
  return stops;
};

/** Strips a known radio prefix typed into the input (show radio prefix pref) */
const stripPrefix = (value: string): string => {
  if (value.startsWith(';')) {
    return value.slice(1);
  }
  const typed = value.slice(0, 3).toLowerCase().replace('.', ':');
  return RADIO_PREFIXES[typed] ? value.slice(3) : value;
};

/**
 * AQUILA: TAB cycles the IC channels and the radio channels of the headset
 * instead of going through OOC and LOOC. Clicking the button still goes
 * through every channel.
 */
export const handleCycleRadio = function (this: Modal, direction: number) {
  const { channel } = this.state;
  const { radioPrefix, showRadioPrefix, value } = this.fields;
  const stops = getRadioStops.call(this);
  const current = stops.findIndex(
    (stop) =>
      stop.channel === channel
      && (stop.prefix === radioPrefix
        || (stop.prefix === '' && (radioPrefix === '' || radioPrefix === ';')))
  );
  let next: number;
  if (current === -1) {
    // OOC, LOOC or a channel outside the cycle: start over from Say/Me
    next = direction > 0 ? 0 : stops.length - 1;
  } else {
    next = (current + direction + stops.length) % stops.length;
  }
  const stop = stops[next];

  // Leaving OOC/LOOC or binary turns the thinking indicator back on
  if (channel > ME || radioPrefix === ':b ') {
    this.timers.channelDebounce({ mode: true });
  }

  this.fields.radioPrefix = stop.prefix;
  if (showRadioPrefix) {
    this.fields.value = stop.prefix + stripPrefix(value || '');
  }
  this.setState({
    buttonContent: RADIO_PREFIXES[stop.prefix]?.label || CHANNELS[stop.channel],
    channel: stop.channel,
    edited: showRadioPrefix,
  });
};
