/** Radio channels */
export const CHANNELS = ['Say', 'Radio', 'Me', 'OOC', 'LOOC'];
export const NO_RADIO_CHANNELS = ['Me', 'OOC', 'LOOC'];
/** Polskie etykiety kanałów (same kanały zostają po angielsku, bo idą do DM). */
export const CHANNEL_LABELS: Record<string, string> = {
  'Say': 'Mów',
  'Radio': 'Radio',
  'Me': 'Akcja',
};

/** Window sizes in pixels */
export enum WINDOW_SIZES {
  small = 30,
  medium = 50,
  large = 70,
  width = 231,
}

/** Line lengths for autoexpand */
export enum LINE_LENGTHS {
  small = 19,
  medium = 35,
}

/**
 * Radio prefixes.
 * Contains the properties:
 * id - string. css class identifier.
 * label - string. button label.
 */
export const RADIO_PREFIXES = {
  ':a ': {
    id: 'hive',
    label: 'Rój',
  },
  ':b ': {
    id: 'binary',
    label: '0101',
  },
  ':c ': {
    id: 'command',
    label: 'Dow',
  },
  ':d ': {
    id: 'uplink',
    label: 'Upl',
  },
  ':e ': {
    id: 'engi',
    label: 'Inż',
  },
  ':h ': {
    id: 'holo',
    label: 'Holo',
  },
  ':i ': {
    id: 'intercom',
    label: 'Inter',
  },
  ':l ': {
    id: 'left',
    label: 'Lewo',
  },
  ':m ': {
    id: 'medical',
    label: 'Med',
  },
  ':n ': {
    id: 'science',
    label: 'Nauk',
  },
  ':o ': {
    id: 'ai',
    label: 'SI',
  },
  // NSV13 - We need this stuff
  // ':q ': {
  //  id: 'exploration',
  //  label: 'Explo',
  // },
  ':r ': {
    id: 'right',
    label: 'Prawo',
  },
  ':s ': {
    id: 'security',
    label: 'Ochr',
  },
  ':t ': {
    id: 'syndicate',
    label: 'Synd',
  },
  ':u ': {
    id: 'supply',
    label: 'Zaop',
  },
  ':v ': {
    id: 'service',
    label: 'Usł',
  },
  ':y ': {
    id: 'centcom',
    label: 'CCom',
  },
  // NSV13 - Start of NSV13 Comms
  ':q ': {
    id: 'atc',
    label: 'ATC',
  },
  ':w ': {
    id: 'munition',
    label: 'Amun',
  },
  ':z ': {
    id: 'space_pirate',
    label: 'SP',
  },
  // NSV13 - End of NSV13 Comms
} as const;
