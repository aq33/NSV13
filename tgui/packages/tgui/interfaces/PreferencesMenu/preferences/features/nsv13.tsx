// AQUILA: ustawienia, których nie ma w BeeStation (NSV13 i nasze), do okna PreferencesMenu
import { Box, Button, Stack } from 'tgui-core/components';

import {
  CheckboxInput,
  Feature,
  FeatureChoiced,
  FeatureNumeric,
  FeatureSliderInput,
  FeatureToggle,
  FeatureValueProps,
} from './base';
import { FeatureButtonedDropdownInput } from './dropdowns';

// Postać

export const feature_ethcolor: FeatureChoiced = {
  name: 'Ethereal Color',
  component: FeatureButtonedDropdownInput,
};

export const feature_ipc_chassis: FeatureChoiced = {
  name: 'Chassis',
  component: FeatureButtonedDropdownInput,
};

export const preferred_pilot_role: FeatureChoiced = {
  name: 'Preferred Pilot Role',
  component: FeatureButtonedDropdownInput,
};

export const preferred_squad: FeatureChoiced = {
  name: 'Preferred GQ Squad',
  component: FeatureButtonedDropdownInput,
};

export const lizard_hiss_style: FeatureChoiced = {
  name: 'Lizard Hiss',
  component: FeatureButtonedDropdownInput,
};

export const preferred_syndie_role: Feature<string> = {
  name: 'Preferred Syndicate Role',
  component: (props: FeatureValueProps<string>) => {
    const { act, value } = props;

    return (
      <Stack align="center">
        <Stack.Item grow>{value}</Stack.Item>
        <Stack.Item>
          <Button icon="pen" onClick={() => act('open_syndie_roles')}>
            Change
          </Button>
        </Stack.Item>
      </Stack>
    );
  },
};

/** Długi tekst edytowany w okienku serwera, tu tylko podgląd */
const TextPreferenceInput = (props: FeatureValueProps<string>) => {
  const { act, featureId, value } = props;

  return (
    <Stack align="center">
      <Stack.Item grow basis={0} style={{ overflow: 'hidden' }}>
        <Box
          color={value ? undefined : 'label'}
          style={{
            whiteSpace: 'nowrap',
            overflow: 'hidden',
            textOverflow: 'ellipsis',
          }}
        >
          {value || 'Empty'}
        </Box>
      </Stack.Item>
      <Stack.Item>
        <Button
          icon="pen"
          tooltip={value || undefined}
          onClick={() => act('edit_text_preference', { preference: featureId })}
        >
          Edit
        </Button>
      </Stack.Item>
    </Stack>
  );
};

export const flavor_text: Feature<string> = {
  name: 'Flavor Text',
  predictable: false,
  component: TextPreferenceInput,
};

export const silicon_flavor_text: Feature<string> = {
  name: 'Silicon Flavor Text',
  predictable: false,
  component: TextPreferenceInput,
};

export const general_record: Feature<string> = {
  name: 'General Record',
  predictable: false,
  component: TextPreferenceInput,
};

export const security_record: Feature<string> = {
  name: 'Security Record',
  predictable: false,
  component: TextPreferenceInput,
};

export const medical_record: Feature<string> = {
  name: 'Medical Record',
  predictable: false,
  component: TextPreferenceInput,
};

// Ustawienia gry

export const sound_lobby: FeatureToggle = {
  name: 'Lobby music',
  category: 'SOUND',
  subcategory: 'Music',
  component: CheckboxInput,
  important: true,
};

export const sound_midi: FeatureToggle = {
  name: 'Admin music',
  category: 'SOUND',
  subcategory: 'Music',
  description: 'Play music played by admins.',
  component: CheckboxInput,
  important: true,
};

export const sound_instruments: FeatureToggle = {
  name: 'Instruments',
  category: 'SOUND',
  subcategory: 'IC',
  description: 'Hear instruments played by other players.',
  component: CheckboxInput,
  important: true,
};

export const sound_ambience: FeatureToggle = {
  name: 'Ambience',
  category: 'SOUND',
  subcategory: 'Ambience',
  component: CheckboxInput,
  important: true,
};

export const sound_ship_ambience: FeatureToggle = {
  name: 'Ship ambience',
  category: 'SOUND',
  subcategory: 'Ambience',
  description: 'The background hum of the ship.',
  component: CheckboxInput,
  important: true,
};

export const tesla_volume: FeatureNumeric = {
  name: 'Tesla volume',
  category: 'SOUND',
  subcategory: 'IC',
  component: FeatureSliderInput,
};

export const chat_looc: FeatureToggle = {
  name: 'See LOOC',
  category: 'CHAT',
  subcategory: 'OOC',
  component: CheckboxInput,
};

export const widescreen: FeatureToggle = {
  name: 'Widescreen',
  category: 'GRAPHICS',
  subcategory: 'Scaling',
  component: CheckboxInput,
  important: true,
};

export const walk_animation: FeatureToggle = {
  name: 'Walk animation',
  category: 'GRAPHICS',
  subcategory: 'Misc',
  description: 'Animate the arms and legs of your character when walking.',
  component: CheckboxInput,
};

export const tgui_fancy: FeatureToggle = {
  name: 'Fancy TGUI windows',
  category: 'UI',
  subcategory: 'TGUI',
  description: 'Use borderless windows for TGUI.',
  component: CheckboxInput,
};

export const announce_login: FeatureToggle = {
  name: 'Announce login',
  category: 'ADMIN',
  subcategory: 'Misc',
  description: 'Admins will be notified when you log in.',
  component: CheckboxInput,
};
