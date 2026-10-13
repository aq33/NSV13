import { Button, ProgressBar, Section } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  fuel: any;
  maxfuel: any;
  targetfuel: any;
  targetmaxfuel: any;
  transfer_mode: any;
};

export const CryogenicFuel = (props) => {
  const { act, data } = useBackend<Data>();
  return (
    <Window width={400} height={400}>
      <Window.Content scrollable>
        <Section>
          Fuel level:
          <ProgressBar
            value={(data.fuel / data.maxfuel) * 100 * 0.01}
            ranges={{
              good: [-Infinity, 0.4],
              average: [0.4, 0.7],
              bad: [0.7, Infinity],
            }}
          />
          Target fuel level:
          <ProgressBar
            value={(data.targetfuel / data.targetmaxfuel) * 100 * 0.01}
            ranges={{
              good: [-Infinity, 0.4],
              average: [0.4, 0.7],
              bad: [0.7, Infinity],
            }}
          />
          <br />
          <br />
          <Button
            content="Stop fuelling"
            icon="times"
            color="average"
            onClick={() => act('stopfuel')}
          />
          <Button
            content="Fuel inlet"
            icon={data.transfer_mode ? 'power-off' : 'square-o'}
            selected={data.transfer_mode}
            onClick={() => act('transfer_mode')}
          />
        </Section>
      </Window.Content>
    </Window>
  );
};
