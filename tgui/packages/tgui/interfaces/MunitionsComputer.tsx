// NSV13

// AQUILA: okno przetłumaczone na polski
import { Button, ProgressBar, Section } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  ammo: any;
  canReload: any;
  chambered: any;
  charge: any;
  has_linked_gun: any;
  isgaussgun: any;
  loaded: any;
  maint_req: any;
  max_ammo: any;
  max_maint_req: any;
  safety: any;
  sudo_mode: any;
  tool_buffer: any;
  tool_buffer_name: any;
};

export const MunitionsComputer = (props) => {
  const { act, data } = useBackend<Data>();
  const {
    loaded,
    chambered,
    charge,
    safety,
    ammo,
    max_ammo,
    isgaussgun,
    maint_req,
    max_maint_req,
    sudo_mode,
    tool_buffer,
    tool_buffer_name,
    has_linked_gun,
  } = data;
  return (
    <Window theme="hackerman" width={290} height={380}>
      <Window.Content>
        {(!sudo_mode && (
          <Section title="Sterowanie bronią:">
            <Button
              fluid
              icon={loaded ? 'check-circle' : 'square-o'}
              width="100"
              selected={loaded}
              content="I1 - Pocisk podany"
              onClick={() => act('toggle_load')}
            />
            <Button
              fluid
              icon={chambered ? 'check-circle' : 'square-o'}
              width="100"
              selected={chambered}
              content="I2 - Pocisk w komorze"
              onClick={() => act('chamber')}
            />
            <Button
              fluid
              icon={safety ? 'power-off' : 'times'}
              color={safety ? 'green' : 'red'}
              content="I3 - Bezpieczniki"
              onClick={() => act('toggle_safety')}
            />
            {!!isgaussgun && (
              <Button
                fluid
                icon={data.canReload ? 'power-off' : 'square-o'}
                color={data.canReload ? 'green' : 'red'}
                content="I4 - Przeładuj ze stojaka"
                onClick={() => act('load')}
              />
            )}
            <Section title="Statystyki:">
              <Section title="Amunicja:">
                <ProgressBar
                  value={(ammo / max_ammo) * 100 * 0.01}
                  ranges={{
                    good: [0.5, Infinity],
                    average: [0.15, 0.5],
                    bad: [-Infinity, 0.15],
                  }}
                />
              </Section>
              <Section title="Stan działa:">
                <ProgressBar
                  value={(maint_req / 25) * 100 * 0.01}
                  ranges={{
                    good: [0.5, Infinity],
                    average: [0.15, 0.5],
                    bad: [-Infinity, 0.15],
                  }}
                />
              </Section>
            </Section>
          </Section>
        )) || (
          <Section title="Łączenie z bronią:">
            <Button
              fluid
              icon="search"
              content="Połącz z najbliższą bronią"
              onClick={() => act('search')}
            />
            <Button
              fluid
              icon={tool_buffer ? 'link' : 'square-o'}
              selected={tool_buffer}
              content={`Połącz z: ${tool_buffer_name}`}
              onClick={() => act('link')}
            />
            <Button
              fluid
              icon={tool_buffer ? 'exclamation-triangle' : 'square-o'}
              color={tool_buffer ? 'bad' : undefined}
              content={'Wyczyść pamięć multitoola'}
              onClick={() => act('fflush')}
            />
            <Button
              fluid
              icon={has_linked_gun ? 'check-circle' : 'square-o'}
              selected={has_linked_gun}
              content="Broń połączona."
              onClick={() => act('unlink')}
            />
          </Section>
        )}
      </Window.Content>
    </Window>
  );
};
