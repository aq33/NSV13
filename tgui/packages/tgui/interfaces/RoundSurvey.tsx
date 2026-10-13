// AQUILA - end of round survey (aquila/code/modules/round_survey/round_survey.dm)
import {
  Box,
  Button,
  NoticeBox,
  Section,
  Stack,
  TextArea,
} from 'tgui-core/components';

import { useBackend, useLocalState } from '../backend';
import { Window } from '../layouts';

type Data = {
  max_text: number;
};

const FUN_LABELS = {
  1: 'Źle się bawiłem',
  2: 'Raczej słabo',
  3: 'W porządku',
  4: 'Dobrze',
  5: 'Świetnie się bawiłem',
};

export const RoundSurvey = (props) => {
  const { act, data } = useBackend<Data>();
  const { max_text } = data;
  const [fun, setFun] = useLocalState<number>('fun', 0);
  const [bugs, setBugs] = useLocalState<string>('bugs', '');
  const [comments, setComments] = useLocalState<string>('comments', '');

  return (
    <Window title="Ankieta po rundzie" width={480} height={560}>
      <Window.Content scrollable>
        <NoticeBox info>
          Runda się skończyła. Poświęć chwilę i oceń ją. Ankieta jest anonimowa
          dla innych graczy.
        </NoticeBox>
        <Section title="Wrażenia">
          <Stack>
            {[1, 2, 3, 4, 5].map((value) => (
              <Stack.Item key={value} grow>
                <Button
                  fluid
                  textAlign="center"
                  selected={fun === value}
                  tooltip={FUN_LABELS[value]}
                  onClick={() => setFun(value)}
                >
                  {value}
                </Button>
              </Stack.Item>
            ))}
          </Stack>
          <Box mt={1} color="label" textAlign="center">
            {fun
              ? FUN_LABELS[fun]
              : '1 = źle się bawiłem, 5 = dobrze się bawiłem'}
          </Box>
        </Section>
        <Section title="Czy napotkałeś jakieś błędy?">
          <TextArea
            fluid
            height={8}
            maxLength={max_text}
            value={bugs}
            onInput={(_, value) => setBugs(value)}
          />
        </Section>
        <Section title="Ogólne uwagi">
          <TextArea
            fluid
            height={8}
            maxLength={max_text}
            value={comments}
            onInput={(_, value) => setComments(value)}
          />
        </Section>
        <Button
          fluid
          icon="paper-plane"
          textAlign="center"
          disabled={!fun}
          tooltip={!fun ? 'Najpierw oceń wrażenia' : undefined}
          onClick={() => act('submit', { fun, bugs, comments })}
        >
          Wyślij
        </Button>
      </Window.Content>
    </Window>
  );
};
