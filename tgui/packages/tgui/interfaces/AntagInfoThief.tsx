// AQUILA - Thief antagonist info (tgstation#64144)
import { Section, Stack } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Objective = {
  count: number;
  name: string;
  explanation: string;
};

type Info = {
  objectives: Objective[];
  goal: string;
  intro: string;
};

export const AntagInfoThief = (props) => {
  const { data } = useBackend<Info>();
  const { intro, goal } = data;
  return (
    <Window width={620} height={300}>
      <Window.Content>
        <Stack vertical fill>
          <Stack.Item grow>
            <Section scrollable fill>
              <Stack vertical>
                <Stack.Item textColor="red" fontSize="20px">
                  {intro}
                </Stack.Item>
                <Stack.Item>{goal}</Stack.Item>
                <Stack.Item>
                  <ObjectivePrintout />
                </Stack.Item>
              </Stack>
            </Section>
          </Stack.Item>
          <Stack.Item>
            <Section textAlign="center" textColor="red" fontSize="19px">
              Pamiętaj: nie masz licencji na zabijanie, jak inni antagoniści.
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const ObjectivePrintout = (props) => {
  const { data } = useBackend<Info>();
  const { objectives } = data;
  return (
    <Stack vertical>
      <Stack.Item bold>Twoje cele na dzisiejszy skok:</Stack.Item>
      <Stack.Item>
        {(!objectives && 'Brak!') ||
          objectives.map((objective) => (
            <Stack.Item key={objective.count}>
              #{objective.count}: {objective.explanation}
            </Stack.Item>
          ))}
      </Stack.Item>
    </Stack>
  );
};
