import { Button, ProgressBar, Section } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  salvage_target: any;
  salvage_target_integrity: any;
  salvage_target_max_integrity: any;
  salvage_target_name: any;
  ships: any;
};

export const SalvageConsole = (props) => {
  const { act, data } = useBackend<Data>();
  return (
    <Window theme="hackerman" width={600} height={800}>
      <Window.Content scrollable>
        <br />
        {!!data.salvage_target && (
          <Section
            title={'Currently maintaining: ' + data.salvage_target_name}
            buttons={
              <Button
                icon="bullseye"
                content="Release Hammerlock"
                color="average"
                tooltip="Stop scrambling this ship's defenses. This will cause any forces boarding it to be killed."
                onClick={() => act('stop_salvage')}
              />
            }
          >
            <ProgressBar
              value={
                (data.salvage_target_integrity /
                  data.salvage_target_max_integrity) *
                100 *
                0.01
              }
              ranges={{
                good: [0.5, Infinity],
                average: [0.15, 0.5],
                bad: [-Infinity, 0.15],
              }}
            />
          </Section>
        )}
        <Section title="Available Salvage Targets:">
          {Object.keys(data.ships).map((key) => {
            let value = data.ships[key];
            return (
              <Section
                key={key}
                title={value.name}
                buttons={
                  <Button
                    content="Establish Hammerlock"
                    icon="anchor"
                    onClick={() => act('salvage', { target: value.id })}
                  />
                }
              >
                {value.desc}
              </Section>
            );
          })}
        </Section>
      </Window.Content>
    </Window>
  );
};
