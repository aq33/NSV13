// AQUILA - ranking zarobków wszech czasów
import {
  Box,
  Icon,
  NoticeBox,
  Section,
  Stack,
  Table,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

export type LeaderboardEntry = {
  ckey: string;
  total: number;
  best: number;
  rounds: number;
};

type Data = {
  leaderboard: LeaderboardEntry[];
  my_ckey: string;
};

const PODIUM = [
  { color: 'gold', height: 7 },
  { color: 'silver', height: 5.5 },
  { color: '#cd7f32', height: 4.5 },
];

export const EconomyLeaderboard = (props) => {
  const { data } = useBackend<Data>();
  const { leaderboard = [], my_ckey } = data;
  return (
    <Window title="Ranking zarobków" width={520} height={560}>
      <Window.Content scrollable>
        <Section>
          <Box color="label">
            Suma sald z karty ID na koniec rund, w których postać przeżyła i się
            ewakuowała - tak samo jak przy aquilosach.
          </Box>
        </Section>
        {leaderboard.length > 0 && <Podium leaderboard={leaderboard} />}
        <Section title="Top 10">
          <LeaderboardTable leaderboard={leaderboard} myCkey={my_ckey} />
        </Section>
      </Window.Content>
    </Window>
  );
};

const Podium = (props: { leaderboard: LeaderboardEntry[] }) => {
  // drugie miejsce po lewej, pierwsze w środku, trzecie po prawej
  const order = [1, 0, 2].filter((place) => props.leaderboard[place]);
  return (
    <Section>
      <Stack align="flex-end" justify="center">
        {order.map((place) => {
          const entry = props.leaderboard[place];
          return (
            <Stack.Item key={entry.ckey} grow basis={0} textAlign="center">
              <Icon
                name="crown"
                size={place === 0 ? 2 : 1.5}
                color={PODIUM[place].color}
              />
              <Box bold mt={0.5}>
                {entry.ckey}
              </Box>
              <Box color="good">{entry.total} kr</Box>
              <Box
                className="RoundEndReport__podium"
                mt={0.5}
                height={`${PODIUM[place].height}em`}
                style={{ borderColor: PODIUM[place].color }}
                fontSize={2}
                bold
                color={PODIUM[place].color}
              >
                {place + 1}
              </Box>
            </Stack.Item>
          );
        })}
      </Stack>
    </Section>
  );
};

export const LeaderboardTable = (props: {
  leaderboard: LeaderboardEntry[];
  myCkey?: string;
}) => {
  const { leaderboard, myCkey } = props;
  if (!leaderboard || leaderboard.length === 0) {
    return <NoticeBox>Ranking jest jeszcze pusty.</NoticeBox>;
  }
  return (
    <Table>
      <Table.Row header>
        <Table.Cell collapsing>#</Table.Cell>
        <Table.Cell>Gracz</Table.Cell>
        <Table.Cell textAlign="right">Suma</Table.Cell>
        <Table.Cell textAlign="right">Rekord rundy</Table.Cell>
        <Table.Cell textAlign="right">Rundy</Table.Cell>
      </Table.Row>
      {leaderboard.map((entry, index) => (
        <Table.Row
          key={entry.ckey}
          className={
            entry.ckey === myCkey ? 'RoundEndReport__mine' : 'candystripe'
          }
        >
          <Table.Cell collapsing>
            {index < 3 ? (
              <Icon name="medal" color={PODIUM[index].color} />
            ) : (
              index + 1
            )}
          </Table.Cell>
          <Table.Cell bold>{entry.ckey}</Table.Cell>
          <Table.Cell textAlign="right" bold color="good">
            {entry.total} kr
          </Table.Cell>
          <Table.Cell textAlign="right">{entry.best} kr</Table.Cell>
          <Table.Cell textAlign="right">{entry.rounds}</Table.Cell>
        </Table.Row>
      ))}
    </Table>
  );
};
