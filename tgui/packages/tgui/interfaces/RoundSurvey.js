// AQUILA - end of round survey (aquila/code/modules/round_survey/round_survey.dm)
import { useBackend, useLocalState } from '../backend';
import { Box, Button, NoticeBox, Section, Stack, TextArea } from '../components';
import { Window } from '../layouts';

const FUN_LABELS = {
  1: 'Źle się bawiłem',
  2: 'Raczej słabo',
  3: 'W porządku',
  4: 'Dobrze',
  5: 'Świetnie się bawiłem',
};

export const RoundSurvey = (props, context) => {
  const { act, data } = useBackend(context);
  const { max_text } = data;
  const [fun, setFun] = useLocalState(context, 'fun', 0);
  const [bugs, setBugs] = useLocalState(context, 'bugs', '');
  const [comments, setComments] = useLocalState(context, 'comments', '');

  return (
    <Window title="Ankieta po rundzie" width={480} height={560}>
      <Window.Content scrollable>
        <NoticeBox info>
          Runda się skończyła. Poświęć chwilę i oceń ją. Ankieta jest
          anonimowa dla innych graczy.
        </NoticeBox>
        <Section title="Wrażenia">
          <Stack>
            {[1, 2, 3, 4, 5].map(value => (
              <Stack.Item key={value} grow>
                <Button
                  fluid
                  textAlign="center"
                  selected={fun === value}
                  tooltip={FUN_LABELS[value]}
                  onClick={() => setFun(value)}>
                  {value}
                </Button>
              </Stack.Item>
            ))}
          </Stack>
          <Box mt={1} color="label" textAlign="center">
            {fun ? FUN_LABELS[fun] : '1 = źle się bawiłem, 5 = dobrze się bawiłem'}
          </Box>
        </Section>
        <Section title="Czy napotkałeś jakieś błędy?">
          <TextArea
            fluid
            height={8}
            maxLength={max_text}
            value={bugs}
            onInput={(e, value) => setBugs(value)} />
        </Section>
        <Section title="Ogólne uwagi">
          <TextArea
            fluid
            height={8}
            maxLength={max_text}
            value={comments}
            onInput={(e, value) => setComments(value)} />
        </Section>
        <Button
          fluid
          icon="paper-plane"
          textAlign="center"
          disabled={!fun}
          tooltip={!fun ? 'Najpierw oceń wrażenia' : null}
          onClick={() => act('submit', { fun, bugs, comments })}>
          Wyślij
        </Button>
      </Window.Content>
    </Window>
  );
};
