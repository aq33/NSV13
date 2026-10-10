// NSV13

import { Button, NumberInput, Section } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  categories: any;
  data_source: any;
  shot_limit: any;
};

export const AMS = (props) => {
  const { act, data } = useBackend<Data>();
  return (
    <Window theme="hackerman" width={500} height={500}>
      <Window.Content scrollable>
        <Section title="Target Source:">
          <Button
            content={data.data_source}
            icon="bullseye"
            onClick={() => act('data_source')}
          />
        </Section>
        <Section title="AMS Modes:">
          {Object.keys(data.categories).map((key) => {
            let value = data.categories[key];
            return (
              <Section
                key={key}
                title={value.name}
                buttons={
                  <Button
                    content={value.enabled ? 'Enabled' : 'Disabled'}
                    icon={value.enabled ? 'check-circle' : 'times'}
                    selected={value.enabled}
                    onClick={() => act('select', { target: value.id })}
                  />
                }
              >
                <p>{value.desc}</p>
              </Section>
            );
          })}
        </Section>
        <Section title="Shots to fire:">
          <NumberInput
            animated
            value={parseInt(data.shot_limit, 10)}
            unit="shots"
            width="125px"
            minValue={1}
            maxValue={100}
            step={1}
            onChange={(value) =>
              act('set_shot_limit', {
                shot_limit: value,
              })
            }
          />
        </Section>
      </Window.Content>
    </Window>
  );
};
