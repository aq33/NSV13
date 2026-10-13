// AQUILA - okno startowe w lobby (aquila/code/modules/mob/dead/new_player/lobby_menu.dm)
import { Box, Button, Section, Stack } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

const NOT_READY = 0;
const READY_TO_PLAY = 1;
const READY_TO_OBSERVE = 2;

type Data = {
  pregame: boolean;
  ready: number;
  polls: boolean;
  new_polls: boolean;
};

const READY_OPTIONS = [
  { value: READY_TO_PLAY, label: 'Gotowy', icon: 'check', color: 'good' },
  { value: NOT_READY, label: 'Nie gotowy', icon: 'times', color: 'bad' },
  { value: READY_TO_OBSERVE, label: 'Obserwuj', icon: 'eye', color: 'blue' },
];

export const LobbyMenu = (_) => {
  const { act, data } = useBackend<Data>();
  const { pregame, ready, polls, new_polls } = data;
  return (
    <Window width={280} height={pregame ? 250 : 290} canClose={false}>
      <Window.Content>
        <Section fill>
          <Stack vertical fill>
            <Stack.Item>
              <Button
                fluid
                icon="user-edit"
                textAlign="center"
                fontSize="14px"
                py={0.5}
                onClick={() => act('preferences')}
              >
                Ustaw postać
              </Button>
            </Stack.Item>
            {pregame ? (
              <>
                <Stack.Item mt={1}>
                  <Box textAlign="center" color="label">
                    Na początek rundy jesteś:
                  </Box>
                </Stack.Item>
                {READY_OPTIONS.map((option) => (
                  <Stack.Item key={option.value}>
                    <Button
                      fluid
                      icon={option.icon}
                      textAlign="center"
                      color={ready === option.value ? option.color : undefined}
                      onClick={() => act('ready', { ready: option.value })}
                    >
                      {option.label}
                    </Button>
                  </Stack.Item>
                ))}
              </>
            ) : (
              <>
                <Stack.Item mt={1}>
                  <Button
                    fluid
                    icon="rocket"
                    color="good"
                    textAlign="center"
                    fontSize="14px"
                    py={0.5}
                    onClick={() => act('late_join')}
                  >
                    Dołącz do gry!
                  </Button>
                </Stack.Item>
                <Stack.Item>
                  <Button
                    fluid
                    icon="users"
                    textAlign="center"
                    onClick={() => act('manifest')}
                  >
                    Lista załogi
                  </Button>
                </Stack.Item>
                <Stack.Item>
                  <Button
                    fluid
                    icon="eye"
                    textAlign="center"
                    onClick={() =>
                      act('ready', { ready: READY_TO_OBSERVE })
                    }
                  >
                    Obserwuj
                  </Button>
                </Stack.Item>
              </>
            )}
            {!!polls && (
              <Stack.Item mt={1}>
                <Button
                  fluid
                  icon="poll"
                  textAlign="center"
                  color={new_polls ? 'average' : undefined}
                  onClick={() => act('polls')}
                >
                  {new_polls ? 'Ankiety (NOWE!)' : 'Ankiety'}
                </Button>
              </Stack.Item>
            )}
          </Stack>
        </Section>
      </Window.Content>
    </Window>
  );
};
