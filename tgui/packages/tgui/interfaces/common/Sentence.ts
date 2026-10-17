// AQUILA - liczenie wyroku wspólne dla terminala GenPop i programu PDA „Prawo kosmiczne”
import { clamp, toFixed } from 'common/math';

// Te same stałe co w code/modules/security/crimes.dm (decysekundy).
export const PRESET_SHORT = 3000;
export const PRESET_LONG = 9000;
export const MAX_TIMER = 360000;

export const formatSentence = (time: number) =>
  time >= MAX_TIMER ? 'dożywocie' : `${toFixed(time / 600, 1)} min`;

export type SentenceModifiers = {
  adjust?: number;
  attempted?: boolean;
  elevated?: boolean;
  resisted?: boolean;
};

/** Ta sama reguła co calculate_sentence() w genpop.dm. */
export const calculateSentence = (
  baseTime: number,
  modifiers: SentenceModifiers = {},
) => {
  const { adjust = 0, attempted, elevated, resisted } = modifiers;
  let time = clamp(baseTime + adjust, 0, MAX_TIMER);
  if (attempted) {
    time = time >= MAX_TIMER ? PRESET_LONG : time - PRESET_SHORT;
  }
  if (elevated) {
    time = time >= PRESET_LONG ? MAX_TIMER : time + PRESET_SHORT;
  }
  if (resisted) {
    time *= 1.2;
  }
  return clamp(Math.round(time / 10) * 10, 0, MAX_TIMER);
};
