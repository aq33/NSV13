// AQUILA - okno sejfu (aquila/code/game/objects/structures/safe.dm)
import {
  Box,
  Button,
  LabeledList,
  NoticeBox,
  ProgressBar,
  Section,
  Stack,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type SafeItem = {
  name: string;
  ref: string;
};

type Data = {
  open: boolean;
  dial: number;
  broken: boolean;
  space: number;
  max_space: number;
  contents: SafeItem[];
};

const DIAL_STEPS = [-10, -5, -1, 1, 5, 10];

export const Safe = (_) => {
  const { act, data } = useBackend<Data>();
  const { open, dial, broken, space, max_space, contents = [] } = data;
  return (
    <Window width={360} height={open ? 420 : 230}>
      <Window.Content scrollable>
        {!!broken && <NoticeBox>Zamek jest rozbity.</NoticeBox>}
        <Section
          title="Pokrętło"
          buttons={
            <Button
              icon={open ? 'lock' : 'lock-open'}
              onClick={() => act('open')}
            >
              {open ? 'Zamknij' : 'Otwórz'}
            </Button>
          }
        >
          <Box textAlign="center" fontSize="32px" bold mb={1}>
            {dial}
          </Box>
          <Stack justify="center">
            {DIAL_STEPS.map((steps) => (
              <Stack.Item key={steps}>
                <Button
                  width="44px"
                  textAlign="center"
                  icon={steps < 0 ? 'undo' : 'redo'}
                  tooltip={`Obróć o ${Math.abs(steps)} ${steps < 0 ? 'w lewo' : 'w prawo'}`}
                  onClick={() => act('turn', { steps })}
                >
                  {Math.abs(steps)}
                </Button>
              </Stack.Item>
            ))}
          </Stack>
          <Box mt={1} color="label" textAlign="center">
            Słuchawki lekarskie w ręce pozwalają usłyszeć zapadki.
          </Box>
        </Section>
        {!!open && (
          <Section title="Zawartość">
            <LabeledList>
              <LabeledList.Item label="Miejsce">
                <ProgressBar value={space} maxValue={max_space}>
                  {space} / {max_space}
                </ProgressBar>
              </LabeledList.Item>
            </LabeledList>
            {contents.length === 0 && (
              <Box mt={1} color="label">
                Sejf jest pusty.
              </Box>
            )}
            {contents.map((item) => (
              <Button
                key={item.ref}
                fluid
                mt={0.5}
                icon="hand-paper"
                onClick={() => act('retrieve', { ref: item.ref })}
              >
                {item.name}
              </Button>
            ))}
          </Section>
        )}
      </Window.Content>
    </Window>
  );
};
