import { Button, Section } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  default_programs: any;
  program: any;
};

export const Workshop = (props) => {
  const { act, data } = useBackend<Data>();
  const { default_programs = [], program } = data;
  return (
    <Window width={400} height={500}>
      <Window.Content scrollable>
        <Section
          title="Default Programs"
          buttons={
            <Button
              icon="exclamation-triangle"
              content="Emergency Shutdown"
              color="bad"
              onClick={() => act('shutdown')}
            />
          }
        >
          {default_programs.map((def_program) => (
            <Button
              fluid
              key={def_program.id}
              content={def_program.name.substring(11)}
              textAlign="center"
              selected={def_program.id === program}
              onClick={() =>
                act('load_program', {
                  id: def_program.id,
                })
              }
            />
          ))}
        </Section>
      </Window.Content>
    </Window>
  );
};
