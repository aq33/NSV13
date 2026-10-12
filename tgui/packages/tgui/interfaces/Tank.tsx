import {
  Button,
  LabeledList,
  NumberInput,
  ProgressBar,
  Section,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  ReleasePressure: any;
  defaultReleasePressure: any;
  maxReleasePressure: any;
  minReleasePressure: any;
  releasePressure: any;
  tankPressure: any;
};

export const Tank = (props) => {
  const { act, data } = useBackend<Data>();
  return (
    <Window width={400} height={120}>
      <Window.Content>
        <Section>
          <LabeledList>
            <LabeledList.Item label="Pressure">
              <ProgressBar
                value={data.tankPressure / 1013}
                ranges={{
                  good: [0.35, Infinity],
                  average: [0.15, 0.35],
                  bad: [-Infinity, 0.15],
                }}
              >
                {data.tankPressure + ' kPa'}
              </ProgressBar>
            </LabeledList.Item>
            <LabeledList.Item label="Pressure Regulator">
              <Button
                icon="fast-backward"
                disabled={data.ReleasePressure === data.minReleasePressure}
                onClick={() =>
                  act('pressure', {
                    pressure: 'min',
                  })
                }
              />
              <NumberInput
                step={1}
                animated
                value={parseFloat(data.releasePressure)}
                width="65px"
                unit="kPa"
                minValue={data.minReleasePressure}
                maxValue={data.maxReleasePressure}
                onChange={(value) =>
                  act('pressure', {
                    pressure: value,
                  })
                }
              />
              <Button
                icon="fast-forward"
                disabled={data.ReleasePressure === data.maxReleasePressure}
                onClick={() =>
                  act('pressure', {
                    pressure: 'max',
                  })
                }
              />
              <Button
                icon="undo"
                content=""
                disabled={data.ReleasePressure === data.defaultReleasePressure}
                onClick={() =>
                  act('pressure', {
                    pressure: 'reset',
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
