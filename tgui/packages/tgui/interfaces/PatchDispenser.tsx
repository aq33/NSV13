import {
  Button,
  LabeledList,
  NumberInput,
  Section,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  patch_name: any;
  patch_size: any;
};

export const PatchDispenser = (props) => {
  const { act, data } = useBackend<Data>();
  const { patch_size, patch_name } = data;
  return (
    <Window width={300} height={120}>
      <Window.Content>
        <Section>
          <LabeledList>
            <LabeledList.Item label="Patch Volume">
              <NumberInput
                value={patch_size}
                unit="u"
                width="43px"
                minValue={5}
                maxValue={40}
                step={1}
                stepPixelSize={2}
                onChange={(value) =>
                  act('change_patch_size', {
                    volume: value,
                  })
                }
              />
            </LabeledList.Item>
            <LabeledList.Item label="Patch Name">
              <Button
                icon="pencil-alt"
                content={patch_name}
                onClick={() => act('change_patch_name')}
              />
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
