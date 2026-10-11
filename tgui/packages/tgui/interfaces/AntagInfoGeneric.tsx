import { useBackend } from '../backend';
import { Box, Section, Stack } from '../components';
import { Window } from '../layouts';
import { AntagInfoHeader } from './common/AntagInfoHeader';
import { Objective, ObjectivesSection } from './common/ObjectiveSection';

type Info = {
  antag_name: string;
  objectives: Objective[];
  // AQUILA: opis roli (np. playstyle_string potwora)
  intro?: string;
};

export const AntagInfoGeneric = (_props) => {
  const { data } = useBackend<Info>();
  const { antag_name, objectives, intro } = data;
  return (
    <Window width={620} height={intro ? 480 : 250} theme="neutral">
      <Window.Content>
        <Stack vertical fill>
          <Stack.Item>
            <AntagInfoHeader name={antag_name || 'Antagonist'} />
          </Stack.Item>
          {!!intro && (
            <Stack.Item grow>
              <Section fill scrollable title="Twoja rola">
                <Box
                  style={{ whiteSpace: 'pre-line' }}
                  dangerouslySetInnerHTML={{ __html: intro }}
                />
              </Section>
            </Stack.Item>
          )}
          <Stack.Item grow={!intro}>
            <ObjectivesSection objectives={objectives} />
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
