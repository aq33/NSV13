/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

export const MAX_VISIBLE_MESSAGES = 2500;
export const MAX_PERSISTED_MESSAGES = 1000;
export const MESSAGE_SAVE_INTERVAL = 10000;
// 516 byondstorage writes one JSON file to disk per save and stalls the
// client while doing it, so save less, less often (see tgstation#93044).
export const HUB_STORAGE_MAX_PERSISTED_MESSAGES = 200;
export const HUB_STORAGE_SAVE_INTERVAL = 60000;
export const MESSAGE_PRUNE_INTERVAL = 60000;
export const COMBINE_MAX_MESSAGES = 5;
export const COMBINE_MAX_TIME_WINDOW = 5000;
export const IMAGE_RETRY_DELAY = 250;
export const IMAGE_RETRY_LIMIT = 10;
export const IMAGE_RETRY_MESSAGE_AGE = 60000;

// Default message type
export const MESSAGE_TYPE_UNKNOWN = 'unknown';

// Internal message type
export const MESSAGE_TYPE_INTERNAL = 'internal';

// Must match the set of defines in code/__DEFINES/chat.dm
export const MESSAGE_TYPE_SYSTEM = 'system';
export const MESSAGE_TYPE_LOCALCHAT = 'localchat';
export const MESSAGE_TYPE_RADIO = 'radio';
export const MESSAGE_TYPE_INFO = 'info';
export const MESSAGE_TYPE_WARNING = 'warning';
export const MESSAGE_TYPE_DEADCHAT = 'deadchat';
export const MESSAGE_TYPE_OOC = 'ooc';
export const MESSAGE_TYPE_ADMINPM = 'adminpm';
export const MESSAGE_TYPE_MENTORPM = 'mentorpm';
export const MESSAGE_TYPE_COMBAT = 'combat';
export const MESSAGE_TYPE_ADMINCHAT = 'adminchat';
export const MESSAGE_TYPE_MENTORCHAT = 'mentorchat';
export const MESSAGE_TYPE_EVENTCHAT = 'eventchat';
export const MESSAGE_TYPE_ADMINLOG = 'adminlog';
export const MESSAGE_TYPE_ATTACKLOG = 'attacklog';
export const MESSAGE_TYPE_DEBUG = 'debug';

// Metadata for each message type
export const MESSAGE_TYPES = [
  // Always-on types
  {
    type: MESSAGE_TYPE_SYSTEM,
    name: 'Komunikaty systemowe',
    description: 'Komunikaty twojego klienta, zawsze włączone',
    selector: '.boldannounce',
    important: true,
  },
  // Basic types
  {
    type: MESSAGE_TYPE_LOCALCHAT,
    name: 'Lokalne',
    description: 'Lokalne wiadomości IC (mowa, emotki itp.)',
    selector: '.say, .emote',
  },
  {
    type: MESSAGE_TYPE_RADIO,
    name: 'Radio',
    description: 'Wiadomości radiowe wszystkich działów',
    selector: '.alert, .syndradio, .centcomradio, .aiprivradio, .comradio, .secradio, .engradio, .medradio, .sciradio, .suppradio, .servradio, .explradio, .entradio, .radio, .deptradio, .newscaster, .redteamradio, .blueteamradio, .sinister, .cult, .shadowling, .changeling',
  },
  {
    type: MESSAGE_TYPE_INFO,
    name: 'Informacje',
    description: 'Niepilne komunikaty gry i przedmiotów',
    selector: '.notice:not(.pm), .adminnotice, .info',
  },
  {
    type: MESSAGE_TYPE_WARNING,
    name: 'Ostrzeżenia',
    description: 'Pilne komunikaty gry i przedmiotów',
    selector: '.warning:not(.pm), .critical, .userdanger, .italics',
  },
  {
    type: MESSAGE_TYPE_DEADCHAT,
    name: 'Deadchat',
    description: 'Cały deadchat',
    selector: '.deadsay',
  },
  {
    type: MESSAGE_TYPE_OOC,
    name: 'OOC',
    description: 'Wiadomości OOC i LOOC',
    selector: '.ooc, .looc, .adminooc',
  },
  {
    type: MESSAGE_TYPE_ADMINPM,
    name: 'PW z adminami',
    description: 'Wiadomości do/od adminów (adminhelp)',
    selector: '.pm, .adminhelp',
  },
  {
    type: MESSAGE_TYPE_MENTORPM,
    name: 'PW z mentorami',
    description: 'Wiadomości do/od mentorów (mentorhelp)',
    selector: '.mentorhelp, .mentorto, .mentorfrom',
  },
  {
    type: MESSAGE_TYPE_COMBAT,
    name: 'Walka',
    description: 'Urist McZdrajca dźga cię nożem!',
    selector: '.danger',
  },
  {
    type: MESSAGE_TYPE_UNKNOWN,
    name: 'Nieposortowane',
    description: 'Wszystko, co nie pasuje gdzie indziej',
  },
  // Admin stuff
  {
    type: MESSAGE_TYPE_ADMINCHAT,
    name: 'Czat adminów',
    description: 'Wiadomości ASAY',
    selector: '.admin_channel, .adminsay',
    admin: true,
  },
  {
    type: MESSAGE_TYPE_MENTORCHAT,
    name: 'Czat mentorów',
    description: 'Czat MSAY (mentorzy)',
    selector: '.mentorsay',
    admin: true,
  },
  {
    type: MESSAGE_TYPE_ADMINLOG,
    name: 'Log adminów',
    description: 'ADMIN LOG: Urist McAdmin has jumped to coordinates X, Y, Z',
    selector: '.log_message',
    admin: true,
  },
  {
    type: MESSAGE_TYPE_ATTACKLOG,
    name: 'Log ataków',
    description: 'Urist McTraitor has shot John Doe',
    admin: true,
  },
  {
    type: MESSAGE_TYPE_DEBUG,
    name: 'Log debugowania',
    description: 'DEBUG: SSPlanets subsystem Recover().',
    admin: true,
  },
];
