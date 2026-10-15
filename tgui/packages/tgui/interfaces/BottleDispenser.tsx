import {
  Button,
  LabeledList,
  NumberInput,
  Section,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  bottle_name: any;
  bottle_size: any;
};

export const BottleDispenser = (props) => {
  const { act, data } = useBackend<Data>();
  const { bottle_size, bottle_name } = data;
  return (
    <Window width={300} height={120}>
      <Window.Content>
        <Section>
          <LabeledList>
            <LabeledList.Item label="Bottle Volume">
              <NumberInput
                value={bottle_size}
                unit="u"
                width="43px"
                minValue={5}
                maxValue={30}
                step={1}
                stepPixelSize={2}
                onChange={(value) =>
                  act('change_bottle_size', {
                    volume: value,
                  })
                }
              />
            </LabeledList.Item>
            <LabeledList.Item label="Bottle Name">
              <Button
                icon="pencil-alt"
                content={bottle_name}
                onClick={() => act('change_bottle_name')}
              />
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
