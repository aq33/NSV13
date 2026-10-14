// AQUILA - raport końca rundy w TGUI
import { BooleanLike } from 'common/react';
import { useState } from 'react';
import {
  Box,
  Icon,
  NoticeBox,
  Section,
  Stack,
  Table,
  Tabs,
  Tooltip,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import {
  Badge,
  LeaderboardEntry,
  LeaderboardTable,
  PlayerName,
} from './EconomyLeaderboard';

type Objective = {
  text: string;
  success: BooleanLike;
};

type Personal = {
  status:
    | 'escaped'
    | 'marooned'
    | 'survived'
    | 'transfer'
    | 'dead'
    | 'observer';
  name?: string;
  objectives: Objective[];
};

type FirstDeath = {
  name: string;
  role: string;
  area: string;
  damage: string;
  last_words?: string;
};

type Stats = {
  duration: string;
  integrity: number;
  crew: number;
  evacuated: BooleanLike;
  escapees: number;
  shuttle_escapees: number;
  survivors: number;
  first_death?: FirstDeath;
};

type Mission = {
  name: string;
  faction: string;
  objectives: Objective[];
  won: BooleanLike;
};

type ReportSection = {
  title: string;
  html: string;
};

type Earning = {
  ckey: string;
  name: string;
  job: string;
  balance: number;
  counted: BooleanLike;
  alive: BooleanLike;
  badge?: Badge | null;
};

type Data = {
  station_name: string;
  round_id?: string;
  personal: Personal;
  stats: Stats;
  mission?: Mission;
  sections: ReportSection[];
  earnings: Earning[];
  leaderboard: LeaderboardEntry[];
  my_ckey: string;
};

const STATUS_INFO = {
  escaped: {
    color: 'good',
    icon: 'space-shuttle',
    text: 'Udało ci się przetrwać',
  },
  transfer: {
    color: 'good',
    icon: 'umbrella-beach',
    text: 'Przepustka na Posterunku 45',
  },
  survived: {
    color: 'good',
    icon: 'heartbeat',
    text: 'Udało ci się przetrwać',
  },
  marooned: {
    color: 'average',
    icon: 'user-astronaut',
    text: 'Przeżywasz, ale utknąłeś',
  },
  dead: { color: 'bad', icon: 'skull', text: 'Nie udało ci się przetrwać' },
  observer: { color: 'label', icon: 'eye', text: 'Obserwowałeś zmianę' },
};

const percent = (part: number, total: number) =>
  total ? Math.round((part / total) * 100) : 0;

export const RoundEndReport = (props) => {
  const { data } = useBackend<Data>();
  const { station_name, round_id, sections = [], earnings = [] } = data;
  const [tab, setTab] = useState('summary');

  return (
    <Window title={`Koniec zmiany na ${station_name}`} width={820} height={680}>
      <Window.Content scrollable>
        <PersonalBanner />
        <Tabs fluid>
          <Tabs.Tab
            icon="flag-checkered"
            selected={tab === 'summary'}
            onClick={() => setTab('summary')}
          >
            Podsumowanie
          </Tabs.Tab>
          <Tabs.Tab
            icon="coins"
            selected={tab === 'earnings'}
            onClick={() => setTab('earnings')}
          >
            Zarobki ({earnings.length})
          </Tabs.Tab>
          <Tabs.Tab
            icon="scroll"
            selected={tab === 'details'}
            onClick={() => setTab('details')}
          >
            Szczegóły ({sections.length})
          </Tabs.Tab>
        </Tabs>
        {tab === 'summary' && (
          <>
            <StatsSection />
            <MissionSection />
          </>
        )}
        {tab === 'earnings' && <EarningsSection />}
        {tab === 'details' && <DetailsSection />}
        {!!round_id && (
          <Box color="label" textAlign="right" mt={1}>
            Runda #{round_id}
          </Box>
        )}
      </Window.Content>
    </Window>
  );
};

const PersonalBanner = (props) => {
  const { data } = useBackend<Data>();
  const { personal, station_name } = data;
  const info = STATUS_INFO[personal.status] || STATUS_INFO.observer;
  return (
    <Section>
      <Stack align="center">
        <Stack.Item>
          <Icon name={info.icon} size={3} color={info.color} mx={1} />
        </Stack.Item>
        <Stack.Item grow>
          <Box fontSize={1.6} bold color={info.color}>
            {info.text}
          </Box>
          <Box color="label">
            {personal.name
              ? `${personal.name} - ${station_name}`
              : `Zmiana na ${station_name}`}
          </Box>
        </Stack.Item>
      </Stack>
      {personal.objectives.length > 0 && (
        <Box mt={1}>
          {personal.objectives.map((objective, index) => (
            <ObjectiveLine
              key={index}
              objective={objective}
              prefix="Cel opcjonalny"
            />
          ))}
        </Box>
      )}
    </Section>
  );
};

const ObjectiveLine = (props: { objective: Objective; prefix?: string }) => {
  const { objective, prefix } = props;
  return (
    <Stack mb={0.5}>
      <Stack.Item>
        <Icon
          name={objective.success ? 'check-circle' : 'times-circle'}
          color={objective.success ? 'good' : 'bad'}
        />
      </Stack.Item>
      <Stack.Item grow>
        {prefix && <b>{prefix}: </b>}
        {objective.text}
      </Stack.Item>
    </Stack>
  );
};

const StatTile = (props: {
  icon: string;
  label: string;
  value: string | number;
  color?: string;
}) => (
  <Stack.Item grow basis={0}>
    <Box className="RoundEndReport__tile" textAlign="center" py={1} px={0.5}>
      <Icon name={props.icon} size={1.5} color={props.color || 'label'} />
      <Box fontSize={1.4} bold mt={0.5} color={props.color}>
        {props.value}
      </Box>
      <Box color="label">{props.label}</Box>
    </Box>
  </Stack.Item>
);

const StatsSection = (props) => {
  const { data } = useBackend<Data>();
  const { stats } = data;
  const integrityText =
    stats.integrity < 0 ? 'Zniszczony' : `${stats.integrity}%`;
  const integrityColor =
    stats.integrity < 0 ? 'bad' : stats.integrity >= 80 ? 'good' : 'average';
  return (
    <Section title="Zmiana">
      <Stack>
        <StatTile icon="clock" label="Czas trwania" value={stats.duration} />
        <StatTile
          icon="shield-alt"
          label="Stan statku"
          value={integrityText}
          color={integrityColor}
        />
        <StatTile icon="users" label="Załoga" value={stats.crew} />
        <StatTile
          icon="heart"
          label="Ocalali"
          value={`${stats.survivors} (${percent(stats.survivors, stats.crew)}%)`}
          color="good"
        />
        {!!stats.evacuated && (
          <StatTile
            icon="space-shuttle"
            label="Ewakuowani"
            value={`${stats.escapees} (${percent(stats.escapees, stats.crew)}%)`}
          />
        )}
      </Stack>
      <Box mt={1}>
        {stats.first_death ? (
          <Stack align="center">
            <Stack.Item>
              <Icon name="skull-crossbones" color="bad" />
            </Stack.Item>
            <Stack.Item grow>
              Pierwsza śmierć: <b>{stats.first_death.name}</b> (
              {stats.first_death.role}), {stats.first_death.area}. Obrażenia:{' '}
              {stats.first_death.damage}.
              {!!stats.first_death.last_words && (
                <Box italic color="label">
                  Ostatnie słowa: „{stats.first_death.last_words}”
                </Box>
              )}
            </Stack.Item>
          </Stack>
        ) : (
          <Box italic color="good">
            Podczas tej zmiany nikt nie zginął!
          </Box>
        )}
      </Box>
    </Section>
  );
};

const MissionSection = (props) => {
  const { data } = useBackend<Data>();
  const { mission, station_name } = data;
  if (!mission) {
    return null;
  }
  return (
    <Section
      title={`Misja: ${mission.name}`}
      buttons={
        <Box bold color={mission.won ? 'good' : 'bad'}>
          <Icon name={mission.won ? 'trophy' : 'flag'} mr={0.5} />
          {mission.won ? 'WYKONANA' : 'NIEWYKONANA'}
        </Box>
      }
    >
      {mission.objectives.map((objective, index) => (
        <ObjectiveLine key={index} objective={objective} />
      ))}
      <NoticeBox color={mission.won ? 'green' : 'red'} mt={1} mb={0}>
        Załoga {station_name} {mission.won ? 'wykonała' : 'nie wykonała'} misji
        dla frakcji {mission.faction}.
      </NoticeBox>
    </Section>
  );
};

const MEDAL_COLORS = ['gold', 'silver', '#cd7f32'];

const EarningsSection = (props) => {
  const { data } = useBackend<Data>();
  const { earnings = [], leaderboard = [], my_ckey } = data;
  return (
    <>
      <Section title="Zarobki w tej rundzie">
        <Box color="label" mb={1}>
          Saldo z karty ID na koniec rundy. Do rankingu liczą się tylko
          postacie, które przeżyły i się ewakuowały - tak samo jak przy
          aquilosach.
        </Box>
        {earnings.length === 0 ? (
          <NoticeBox>Nikt nie miał pieniędzy na koncie.</NoticeBox>
        ) : (
          <Table>
            <Table.Row header>
              <Table.Cell collapsing>#</Table.Cell>
              <Table.Cell>Gracz</Table.Cell>
              <Table.Cell>Postać</Table.Cell>
              <Table.Cell textAlign="right">Saldo</Table.Cell>
              <Table.Cell collapsing textAlign="center">
                Ranking
              </Table.Cell>
            </Table.Row>
            {earnings.map((earning, index) => (
              <Table.Row
                key={earning.ckey}
                className={
                  earning.ckey === my_ckey
                    ? 'RoundEndReport__mine'
                    : 'candystripe'
                }
              >
                <Table.Cell collapsing>
                  {index < 3 ? (
                    <Icon name="medal" color={MEDAL_COLORS[index]} />
                  ) : (
                    index + 1
                  )}
                </Table.Cell>
                <Table.Cell bold>
                  <PlayerName ckey={earning.ckey} badge={earning.badge} />
                </Table.Cell>
                <Table.Cell>
                  {earning.name}
                  {!!earning.job && <Box color="label">{earning.job}</Box>}
                </Table.Cell>
                <Table.Cell textAlign="right" bold color="good">
                  {earning.balance} kr
                </Table.Cell>
                <Table.Cell collapsing textAlign="center">
                  <Tooltip
                    content={
                      earning.counted
                        ? 'Przeżył i się ewakuował - liczy się do rankingu'
                        : earning.alive
                          ? 'Nie ewakuował się - nie liczy się do rankingu'
                          : 'Zginął - nie liczy się do rankingu'
                    }
                  >
                    <Icon
                      name={
                        earning.counted
                          ? 'check-circle'
                          : earning.alive
                            ? 'user-astronaut'
                            : 'skull'
                      }
                      color={earning.counted ? 'good' : 'bad'}
                    />
                  </Tooltip>
                </Table.Cell>
              </Table.Row>
            ))}
          </Table>
        )}
      </Section>
      <Section title="Ranking wszech czasów">
        <LeaderboardTable leaderboard={leaderboard} myCkey={my_ckey} />
      </Section>
    </>
  );
};

const DetailsSection = (props) => {
  const { data } = useBackend<Data>();
  const { sections = [] } = data;
  if (sections.length === 0) {
    return <NoticeBox>Brak dodatkowych informacji o tej rundzie.</NoticeBox>;
  }
  return (
    <>
      {sections.map((section, index) => (
        <Section key={index} title={section.title}>
          <Box
            className="RoundEndReport__html"
            dangerouslySetInnerHTML={{ __html: section.html }}
          />
        </Section>
      ))}
    </>
  );
};
