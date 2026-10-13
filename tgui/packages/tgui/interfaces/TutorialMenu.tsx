import { useState } from 'react';
import {
  Box,
  Button,
  Icon,
  NoticeBox,
  Section,
  Stack,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

// AQUILA: samouczek (rdzeń z cmss13-devs/cmss13#5030), okno wyboru lekcji w lobby

type Tutorial = {
  name: string;
  id: string;
  description: string;
  icon: string;
  path: string;
  completed: BooleanLike;
  locked: BooleanLike;
  required_name: string | null;
};

type Data = {
  tutorials: Tutorial[];
  round_ready: BooleanLike;
};

const TutorialEntry = (props: {
  tutorial: Tutorial;
  selected: boolean;
  onSelect: () => void;
}) => {
  const { tutorial, selected, onSelect } = props;
  return (
    <Button
      fluid
      selected={selected}
      color={tutorial.completed ? 'good' : undefined}
      disabled={!!tutorial.locked}
      tooltip={
        tutorial.locked
          ? `Najpierw ukończ lekcję „${tutorial.required_name}”`
          : undefined
      }
      onClick={onSelect}
      py={0.75}
    >
      <Stack align="center">
        <Stack.Item>
          <Icon name={tutorial.icon} size={1.5} width={2} />
        </Stack.Item>
        <Stack.Item grow fontSize="1.1em">
          {tutorial.name}
        </Stack.Item>
        <Stack.Item>
          {tutorial.locked ? (
            <Icon name="lock" />
          ) : tutorial.completed ? (
            <Icon name="check" />
          ) : null}
        </Stack.Item>
      </Stack>
    </Button>
  );
};

export const TutorialMenu = (_props) => {
  const { act, data } = useBackend<Data>();
  const { tutorials = [], round_ready } = data;
  const firstOpen = tutorials.find((tutorial) => !tutorial.completed);
  const [selectedId, setSelectedId] = useState<string | undefined>(
    (firstOpen || tutorials[0])?.id,
  );
  const selected = tutorials.find((tutorial) => tutorial.id === selectedId);

  return (
    <Window title="Samouczek" width={640} height={400}>
      <Window.Content>
        <Stack fill>
          <Stack.Item width="40%">
            <Section fill scrollable title="Lekcje">
              <Stack vertical>
                {tutorials.map((tutorial) => (
                  <Stack.Item key={tutorial.id}>
                    <TutorialEntry
                      tutorial={tutorial}
                      selected={tutorial.id === selectedId}
                      onSelect={() => setSelectedId(tutorial.id)}
                    />
                  </Stack.Item>
                ))}
              </Stack>
            </Section>
          </Stack.Item>
          <Stack.Item grow>
            <Section fill title={selected?.name || 'Wybierz lekcję'}>
              {selected ? (
                <Stack vertical fill>
                  <Stack.Item>
                    <Box textAlign="center" my={1}>
                      <Icon name={selected.icon} size={4} color="label" />
                    </Box>
                  </Stack.Item>
                  <Stack.Item grow>
                    <Box lineHeight={1.5}>{selected.description}</Box>
                    {!!selected.completed && (
                      <Box mt={1} color="good">
                        <Icon name="check" mr={1} />
                        Ta lekcja jest już ukończona. Możesz ją powtórzyć.
                      </Box>
                    )}
                  </Stack.Item>
                  {!round_ready && (
                    <Stack.Item>
                      <NoticeBox>
                        Samouczek będzie dostępny po rozpoczęciu rundy.
                      </NoticeBox>
                    </Stack.Item>
                  )}
                  <Stack.Item>
                    <Button
                      fluid
                      icon="play"
                      textAlign="center"
                      fontSize="1.2em"
                      py={0.5}
                      disabled={!!selected.locked || !round_ready}
                      onClick={() =>
                        act('select_tutorial', {
                          tutorial_path: selected.path,
                        })
                      }
                    >
                      Rozpocznij lekcję
                    </Button>
                  </Stack.Item>
                </Stack>
              ) : (
                <Box color="label">Wybierz lekcję z listy.</Box>
              )}
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
