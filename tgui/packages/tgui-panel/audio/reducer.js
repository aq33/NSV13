/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

const initialState = {
  visible: false,
  playing: false,
  track: null,
};

export const audioReducer = (state = initialState, action) => {
  const { type, payload } = action;
  if (type === 'audio/playing') {
    // AQUILA EDIT - don't pop the volume panel open on every track (jukebox);
    // the player opens it with the music button
    return {
      ...state,
      playing: true,
    };
  }
  if (type === 'audio/stopped') {
    return {
      ...state,
      visible: false,
      playing: false,
    };
  }
  if (type === 'audio/playMusic') {
    return {
      ...state,
      meta: payload,
    };
  }
  if (type === 'audio/stopMusic') {
    return {
      ...state,
      visible: false,
      playing: false,
      meta: null,
    };
  }
  if (type === 'audio/toggle') {
    return {
      ...state,
      visible: !state.visible,
    };
  }
  return state;
};
