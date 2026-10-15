// AQUILA - lista zleceń szpiega (port z tgstation)
import {
  BlockQuote,
  Box,
  Dimmer,
  Icon,
  Section,
  Stack,
} from 'tgui-core/components';
import { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Bounty = {
  name: string;
  help: string;
  difficulty: string;
  reward: string;
  claimed: BooleanLike;
  can_claim: BooleanLike;
};

type Data = {
  time_left: number;
  bounties: Bounty[];
};

const difficulty_to_color = {
  easy: 'good',
  medium: 'average',
  hard: 'bad',
};

const difficulty_to_name = {
  easy: 'łatwe',
  medium: 'średnie',
  hard: 'trudne',
};

const BountyDimmer = (props: { text: string; color: string }) => {
  return (
    <Dimmer>
      <Stack>
        <Stack.Item>
          <Icon name="user-secret" size={2} color={props.color} />
        </Stack.Item>
        <Stack.Item align={'center'} italic>
          {props.text}
        </Stack.Item>
      </Stack>
    </Dimmer>
  );
};

const BountyDisplay = (props: { bounty: Bounty }) => {
  const { bounty } = props;
  const difficulty = bounty.difficulty.toLowerCase();

  return (
    <Section>
      {!!bounty.claimed && <BountyDimmer color="bad" text="Wykonane!" />}
      {!bounty.can_claim && !bounty.claimed && (
        <BountyDimmer
          color="average"
          text="Twoi mocodawcy uważają, że to zlecenie nie jest dla ciebie."
        />
      )}
      <Stack vertical ml={1}>
        <Stack.Item>
          <Box
            style={{
              textTransform: 'capitalize',
            }}
            color={difficulty_to_color[difficulty]}
          >
            {bounty.name}
          </Box>
        </Stack.Item>
        <Stack.Item>
          <BlockQuote italic>{bounty.help}</BlockQuote>
        </Stack.Item>
        <Stack.Item italic>
          Trudność: {difficulty_to_name[difficulty] || bounty.difficulty}.
          Nagroda: {bounty.reward}
        </Stack.Item>
      </Stack>
    </Section>
  );
};

// Formats a number of deciseconds into a string minutes:seconds
const format_deciseconds = (deciseconds: number) => {
  const seconds = Math.floor(deciseconds / 10);
  const minutes = Math.floor(seconds / 60);

  const seconds_left = seconds % 60;
  const minutes_left = minutes % 60;

  const seconds_string = seconds_left.toString().padStart(2, '0');
  const minutes_string = minutes_left.toString().padStart(2, '0');

  return `${minutes_string}:${seconds_string}`;
};

export const SpyUplink = () => {
  const { data } = useBackend<Data>();
  const { bounties = [], time_left } = data;

  return (
    <Window width={450} height={615} theme="ntos_darkmode">
      <Window.Content
        style={{
          backgroundImage: 'none',
        }}
      >
        <Section
          fill
          title="Zlecenia szpiega"
          scrollable
          buttons={
            <Box mt={0.4}>Odświeżenie za: {format_deciseconds(time_left)}</Box>
          }
        >
          <Stack vertical fill>
            <Stack.Item>
              {bounties.map((bounty) => (
                <Stack.Item key={bounty.name} className="candystripe">
                  <BountyDisplay bounty={bounty} />
                </Stack.Item>
              ))}
            </Stack.Item>
          </Stack>
        </Section>
      </Window.Content>
    </Window>
  );
};
