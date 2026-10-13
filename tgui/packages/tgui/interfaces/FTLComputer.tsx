// NSV13

import { Fragment } from 'react';
import { Button, Knob, ProgressBar, Section } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  await_emergency_ftl_confirm: any;
  goal: any;
  powered: any;
  progress: any;
  tracking: any;
};

// legacy FTL drive computer
export const FTLComputer = (props) => {
  const { act, data } = useBackend<Data>();
  return (
    <Window
      theme={data.await_emergency_ftl_confirm ? 'malfunction' : 'retro'}
      width={560}
      height={350}
    >
      <Window.Content scrollable>
        {(data.await_emergency_ftl_confirm && (
          <Section>
            <Section title="OVERRIDE">
              <Button
                icon="exclamation-triangle"
                fluid
                color="red"
                onClick={() => act('emergency_jump')}
                content="CONFIRM EMERGENCY JUMP?"
              />
            </Section>
          </Section>
        )) || (
          <Section>
            <Section title="Actions:">
              <Knob
                size={2}
                color={!!data.powered && 'green'}
                value={data.powered * 10}
                unit=""
                minValue={0}
                maxValue={10}
                step={1}
                stepPixelSize={1}
                onDrag={(e, value) => act('toggle_power')}
              />
            </Section>
            <Section title="FTL Spoolup:">
              <ProgressBar
                value={(data.progress / data.goal) * 100 * 0.01}
                ranges={{
                  good: [0.9, Infinity],
                  average: [0.15, 0.9],
                  bad: [-Infinity, 0.15],
                }}
              />
            </Section>
            <Section title="Tracking:">
              {Object.keys(data.tracking).map((key) => {
                let value = data.tracking[key];
                return (
                  <Fragment key={key}>
                    <Section title={`${value.name}`}>
                      <Button
                        fluid
                        content={`Current location: ${value.current_system}`}
                        icon="target"
                      />
                    </Section>
                  </Fragment>
                );
              })}
            </Section>
          </Section>
        )}
      </Window.Content>
    </Window>
  );
};
