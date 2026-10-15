import { toFixed } from 'common/math';
import {
  Button,
  LabeledList,
  NumberInput,
  Section,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  code: any;
  frequency: any;
  maxFrequency: any;
  minFrequency: any;
  power: any;
};

export const Electropack = (props) => {
  const { act, data } = useBackend<Data>();
  const { power, code, frequency, minFrequency, maxFrequency } = data;
  return (
    <Window width={260} height={137}>
      <Window.Content>
        <Section>
          <LabeledList>
            <LabeledList.Item label="Power">
              <Button
                icon={power ? 'power-off' : 'times'}
                content={power ? 'On' : 'Off'}
                selected={power}
                onClick={() => act('power')}
              />
            </LabeledList.Item>
            <LabeledList.Item
              label="Frequency"
              buttons={
                <Button
                  icon="sync"
                  content="Reset"
                  onClick={() =>
                    act('reset', {
                      reset: 'freq',
                    })
                  }
                />
              }
            >
              <NumberInput
                animated
                unit="kHz"
                step={0.2}
                stepPixelSize={6}
                minValue={minFrequency / 10}
                maxValue={maxFrequency / 10}
                value={frequency / 10}
                format={(value) => toFixed(value, 1)}
                width="80px"
                onDrag={(value) =>
                  act('freq', {
                    freq: value,
                  })
                }
              />
            </LabeledList.Item>
            <LabeledList.Item
              label="Code"
              buttons={
                <Button
                  icon="sync"
                  content="Reset"
                  onClick={() =>
                    act('reset', {
                      reset: 'code',
                    })
                  }
                />
              }
            >
              <NumberInput
                animated
                step={1}
                stepPixelSize={6}
                minValue={1}
                maxValue={100}
                value={code}
                width="80px"
                onDrag={(value) =>
                  act('code', {
                    code: value,
                  })
                }
              />
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
