// NSV13

import { Button, ProgressBar, Section } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  ammo: any;
  can_load: any;
  loaded: any;
  max_ammo: any;
  max_speed: any;
  parts: any;
  speed: any;
};

export const DeckGun = (props) => {
  const { act, data } = useBackend<Data>();
  return (
    <Window theme="hackerman" width={500} height={400}>
      <Window.Content scrollable>
        <Section title="Naval Artillery Cannon">
          <Section title="Loaded:">{data.loaded}</Section>
          {!!data.parts && (
            <Section title="Shell powder content (dT):">
              {Object.keys(data.parts).map((key) => {
                let value = data.parts[key];
                return (
                  <Button
                    key={key}
                    content="Pack from loader"
                    icon="box"
                    disabled={!value.loaded}
                    onClick={() => act('load_powder', { target: value.id })}
                  />
                );
              })}
            </Section>
          )}
          <ProgressBar
            value={(data.speed / data.max_speed) * 100 * 0.01}
            ranges={{
              good: [0.4, Infinity],
              average: [0.15, 0.4],
              bad: [-Infinity, 0.4],
            }}
          />
          <br />
          <br />
        </Section>
        <Section title="Turret Ammunition:">
          <Button
            content="Feed Shell"
            icon="exclamation-triangle"
            disabled={!data.can_load}
            onClick={() => act('load')}
          />
          <br />
          <br />
          <ProgressBar
            value={(data.ammo / data.max_ammo) * 100 * 0.01}
            ranges={{
              good: [0.4, Infinity],
              average: [0.15, 0.4],
              bad: [-Infinity, 0.4],
            }}
          />
        </Section>
      </Window.Content>
    </Window>
  );
};
