// AQUILA - konsola kart ID i konsole działowe (aquila/code/game/machinery/computer/card_ui.dm)
import {
  Box,
  Button,
  LabeledList,
  NoticeBox,
  Section,
  Stack,
  Table,
  Tabs,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

const MODE_CARD = 0;
const MODE_MANIFEST = 1;
const MODE_JOBS = 2;
const MODE_PAY = 3;

type Access = {
  id: number;
  desc: string;
  granted: boolean;
};

type Region = {
  name: string;
  accesses: Access[];
};

type JobGroup = {
  name: string;
  jobs: string[];
};

type Job = {
  title: string;
  current: number;
  total: number;
  can_open: number;
  can_close: number;
  prioritized: boolean;
};

type Jobs = {
  can_edit: boolean;
  cooldown: number;
  prioritized_count: number;
  list: Job[];
};

type Account = {
  holder: string;
  job: string;
  pay: number;
  bonus: number;
};

type Data = {
  mode: number;
  authenticated: number;
  department_console: boolean;
  centcom: boolean;
  scan_name: string | null;
  modify_name: string | null;
  modify_owner: string | null;
  modify_rank: string;
  printing: boolean;
  manifest?: { name: string; rank: string }[];
  jobs?: Jobs;
  accounts?: Account[];
  regions?: Region[];
  assignable_jobs?: JobGroup[];
};

export const IdentificationConsole = (_) => {
  const { act, data } = useBackend<Data>();
  const { mode, authenticated, department_console } = data;
  return (
    <Window width={820} height={620}>
      <Window.Content scrollable>
        <CardSlots />
        <Tabs>
          <Tabs.Tab
            icon="id-card"
            selected={mode === MODE_CARD}
            onClick={() => act('mode', { mode: MODE_CARD })}
          >
            Karta
          </Tabs.Tab>
          <Tabs.Tab
            icon="users"
            selected={mode === MODE_MANIFEST}
            onClick={() => act('mode', { mode: MODE_MANIFEST })}
          >
            Manifest załogi
          </Tabs.Tab>
          {!department_console && (
            <Tabs.Tab
              icon="briefcase"
              selected={mode === MODE_JOBS}
              onClick={() => act('mode', { mode: MODE_JOBS })}
            >
              Wakaty
            </Tabs.Tab>
          )}
          <Tabs.Tab
            icon="money-bill"
            selected={mode === MODE_PAY}
            onClick={() => act('mode', { mode: MODE_PAY })}
          >
            Wypłaty
          </Tabs.Tab>
        </Tabs>
        {mode === MODE_CARD &&
          (authenticated ? <CardEditor /> : <LoginScreen />)}
        {mode === MODE_MANIFEST && <Manifest />}
        {mode === MODE_JOBS && <JobManagement />}
        {mode === MODE_PAY && <Paychecks />}
      </Window.Content>
    </Window>
  );
};

const CardSlots = () => {
  const { act, data } = useBackend<Data>();
  const { scan_name, modify_name, authenticated } = data;
  return (
    <Section
      title="Karty"
      buttons={
        !!authenticated && (
          <Button icon="sign-out-alt" onClick={() => act('logout')}>
            Wyloguj
          </Button>
        )
      }
    >
      <LabeledList>
        <LabeledList.Item label="Twoja karta">
          <Button icon="id-badge" onClick={() => act('scan_slot')}>
            {scan_name || 'Włóż kartę'}
          </Button>
        </LabeledList.Item>
        <LabeledList.Item label="Karta do zmiany">
          <Button icon="id-card" onClick={() => act('modify_slot')}>
            {modify_name || 'Włóż kartę'}
          </Button>
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};

const LoginScreen = () => {
  const { act } = useBackend<Data>();
  return (
    <Section>
      <NoticeBox info>
        Włóż swoją kartę i kartę, którą chcesz zmienić, a potem się zaloguj.
      </NoticeBox>
      <Button fluid icon="sign-in-alt" onClick={() => act('login')}>
        Zaloguj
      </Button>
    </Section>
  );
};

const CardEditor = () => {
  const { act, data } = useBackend<Data>();
  const {
    authenticated,
    modify_name,
    modify_owner,
    modify_rank,
    regions = [],
    assignable_jobs = [],
  } = data;
  if (!modify_name) {
    return (
      <Section>
        <NoticeBox>Włóż kartę, którą chcesz zmienić.</NoticeBox>
      </Section>
    );
  }
  return (
    <>
      <Section title="Właściciel">
        <LabeledList>
          <LabeledList.Item
            label="Nazwisko"
            buttons={
              authenticated === 2 && (
                <Button icon="pen" onClick={() => act('rename')}>
                  Zmień
                </Button>
              )
            }
          >
            {modify_owner || '--------'}
          </LabeledList.Item>
          <LabeledList.Item
            label="Stanowisko"
            buttons={
              authenticated !== 2 && (
                <Button icon="user-minus" onClick={() => act('demote')}>
                  Zdegraduj
                </Button>
              )
            }
          >
            {modify_rank}
          </LabeledList.Item>
        </LabeledList>
      </Section>
      {authenticated === 2 && (
        <Section title="Przypisz stanowisko">
          {assignable_jobs.map((group) => (
            <Stack key={group.name} mb={0.5} align="baseline">
              <Stack.Item width="110px" color="label">
                {group.name}
              </Stack.Item>
              <Stack.Item grow>
                {group.jobs.map((job) => (
                  <Button
                    key={job}
                    selected={job === modify_rank}
                    onClick={() => act('assign', { job })}
                  >
                    {job === 'Custom'
                      ? 'Własne...'
                      : job === 'Unassigned'
                        ? 'Brak'
                        : job}
                  </Button>
                ))}
              </Stack.Item>
            </Stack>
          ))}
        </Section>
      )}
      <Section title="Dostępy">
        <Stack wrap>
          {regions.map((region) => (
            <Stack.Item key={region.name} width="190px" mb={1}>
              <Box bold mb={0.5}>
                {region.name}
              </Box>
              {region.accesses.map((access) => (
                <Button.Checkbox
                  key={access.id}
                  fluid
                  checked={access.granted}
                  onClick={() =>
                    act('access', {
                      access: access.id,
                      allowed: !access.granted,
                    })
                  }
                >
                  {access.desc}
                </Button.Checkbox>
              ))}
            </Stack.Item>
          ))}
        </Stack>
      </Section>
    </>
  );
};

const Manifest = () => {
  const { act, data } = useBackend<Data>();
  const { manifest = [], printing } = data;
  return (
    <Section
      title="Manifest załogi"
      buttons={
        <Button icon="print" disabled={printing} onClick={() => act('print')}>
          {printing ? 'Drukuje...' : 'Drukuj'}
        </Button>
      }
    >
      <Box color="label" mb={1}>
        Wpisy zmienia się w konsoli rekordów ochrony.
      </Box>
      <Table>
        {manifest.map((member, index) => (
          <Table.Row key={index} className="candystripe">
            <Table.Cell>{member.name}</Table.Cell>
            <Table.Cell>{member.rank}</Table.Cell>
          </Table.Row>
        ))}
      </Table>
    </Section>
  );
};

const formatCooldown = (seconds: number) =>
  `${Math.floor(seconds / 60)}:${String(seconds % 60).padStart(2, '0')}`;

const JobManagement = () => {
  const { act, data } = useBackend<Data>();
  const jobs = data.jobs;
  if (!jobs) {
    return null;
  }
  const denied = (state: number) =>
    state === -2 ? `Odczekaj ${formatCooldown(jobs.cooldown)}` : 'Zabronione';
  return (
    <Section title="Wakaty">
      {!jobs.can_edit && (
        <NoticeBox>
          Zmiany wymagają karty z dostępem do zmiany kart ID.
        </NoticeBox>
      )}
      <Table>
        <Table.Row header>
          <Table.Cell>Stanowisko</Table.Cell>
          <Table.Cell collapsing>Miejsca</Table.Cell>
          <Table.Cell collapsing>Otwórz</Table.Cell>
          <Table.Cell collapsing>Zamknij</Table.Cell>
          <Table.Cell collapsing>Priorytet</Table.Cell>
        </Table.Row>
        {jobs.list.map((job) => (
          <Table.Row key={job.title} className="candystripe">
            <Table.Cell>{job.title}</Table.Cell>
            <Table.Cell collapsing textAlign="center">
              {job.current}/{job.total}
            </Table.Cell>
            <Table.Cell collapsing>
              <Button
                icon="plus"
                disabled={!jobs.can_edit || job.can_open !== 1}
                tooltip={job.can_open !== 1 ? denied(job.can_open) : undefined}
                onClick={() => act('open_job', { job: job.title })}
              />
            </Table.Cell>
            <Table.Cell collapsing>
              <Button
                icon="minus"
                disabled={!jobs.can_edit || job.can_close !== 1}
                tooltip={
                  job.can_close !== 1 ? denied(job.can_close) : undefined
                }
                onClick={() => act('close_job', { job: job.title })}
              />
            </Table.Cell>
            <Table.Cell collapsing>
              <Button.Checkbox
                checked={job.prioritized}
                disabled={
                  !jobs.can_edit ||
                  job.total === 0 ||
                  (!job.prioritized && jobs.prioritized_count >= 5)
                }
                onClick={() => act('prioritize_job', { job: job.title })}
              />
            </Table.Cell>
          </Table.Row>
        ))}
      </Table>
    </Section>
  );
};

const Paychecks = () => {
  const { act, data } = useBackend<Data>();
  const { accounts = [], scan_name } = data;
  return (
    <Section title="Wypłaty">
      {!scan_name && (
        <NoticeBox>Włóż kartę szefa działu, żeby zobaczyć konta.</NoticeBox>
      )}
      {!!scan_name && accounts.length === 0 && (
        <Box color="label">Twoja karta nie pozwala zmieniać żadnych wypłat.</Box>
      )}
      {accounts.length > 0 && (
        <Table>
          <Table.Row header>
            <Table.Cell>Pracownik</Table.Cell>
            <Table.Cell>Stanowisko</Table.Cell>
            <Table.Cell collapsing>Pensja</Table.Cell>
            <Table.Cell collapsing>Premia</Table.Cell>
          </Table.Row>
          {accounts.map((account) => (
            <Table.Row key={account.holder} className="candystripe">
              <Table.Cell>{account.holder}</Table.Cell>
              <Table.Cell>{account.job}</Table.Cell>
              <Table.Cell collapsing>
                <Button
                  onClick={() =>
                    act('adjust_pay', { account: account.holder })
                  }
                >
                  ${account.pay}
                </Button>
              </Table.Cell>
              <Table.Cell collapsing>
                <Button
                  color={account.bonus < 0 ? 'bad' : undefined}
                  onClick={() =>
                    act('adjust_bonus', { account: account.holder })
                  }
                >
                  ${account.bonus}
                </Button>
              </Table.Cell>
            </Table.Row>
          ))}
        </Table>
      )}
    </Section>
  );
};
