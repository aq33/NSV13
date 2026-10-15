// NSV13

import { Button, ProgressBar, Section } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  goal: any;
  powered: any;
  progress: any;
  ready: any;
};

export const GaussDispenser = (props) => {
  const { act, data } = useBackend<Data>();
  return (
    <Window width={560} height={600}>
      <Window.Content scrollable>
        <Section>
          <Section title="Controls:">
            <Button
              fluid
              content="Toggle power"
              color={data.powered ? 'good' : 'bad'}
              icon="power-off"
              onClick={() => act('toggle_power')}
            />
            <Button
              fluid
              content="Retrieve ammunition"
              icon="download"
              selected={data.ready}
              disabled={!data.ready}
              onClick={() => act('dispense')}
            />
          </Section>
          <Section title="Ammunition retrieval status:">
            <ProgressBar
              value={(data.progress / data.goal) * 100 * 0.01}
              ranges={{
                good: [0.9, Infinity],
                average: [0.15, 0.9],
                bad: [-Infinity, 0.15],
              }}
            />
            <br />
          </Section>
        </Section>
      </Window.Content>
    </Window>
  );
};
