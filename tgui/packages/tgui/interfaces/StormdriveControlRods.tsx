// NSV13

import { Fragment } from 'react';
import { Button, ProgressBar, Section } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  mounted_control_rods: any;
};

export const StormdriveControlRods = (props) => {
  const { act, data } = useBackend<Data>();
  return (
    <Window theme="hackerman" width={560} height={600}>
      <Window.Content scrollable>
        <Section>
          <Section title="Installed Control Rods:">
            {!!data.mounted_control_rods && (
              <Section>
                {Object.keys(data.mounted_control_rods).map((key) => {
                  let value = data.mounted_control_rods[key];
                  return (
                    <Fragment key={key}>
                      <Section title={`${value.name}`}>
                        <>
                          <Button
                            fluid
                            content={`Eject ${value.name}`}
                            icon="eject"
                            onClick={() =>
                              act('remove_rod', { target: value.id })
                            }
                          />
                          <ProgressBar
                            value={
                              (value.health / value.max_health) * 100 * 0.01
                            }
                            ranges={{
                              good: [0.66, Infinity],
                              average: [0.33, 0.66],
                              bad: [-Infinity, 0.33],
                            }}
                          />
                        </>
                      </Section>
                    </Fragment>
                  );
                })}
              </Section>
            )}
          </Section>
        </Section>
      </Window.Content>
    </Window>
  );
};
