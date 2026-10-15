/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

export const CONNECTION_LOST_AFTER = 15000;

// Po restarcie rundy BYOND sam łączy klienta ponownie, ale przy długim
// starcie nowego świata potrafi się poddać. Wtedy panel próbuje sam.
export const AUTO_RECONNECT_AFTER = 45000;
export const AUTO_RECONNECT_INTERVAL = 30000;
