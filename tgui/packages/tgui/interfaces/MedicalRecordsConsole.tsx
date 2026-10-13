// AQUILA - konsola akt medycznych (aquila/code/game/machinery/computer/medical_records_ui.dm)
import { useState } from 'react';
import {
  Box,
  Button,
  Input,
  LabeledList,
  NoticeBox,
  Section,
  Stack,
  Table,
  Tabs,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type TopicLink = {
  params: Record<string, string>;
  label: string;
};

type Temp = {
  text: string;
  buttons: TopicLink[];
};

type RecordRow = {
  name: string;
  id: string;
  rank: string;
  fingerprint: string;
  dna: string;
  blood_type: string;
  physical: string;
  mental: string;
};

type General = {
  name: string;
  id: string;
  rank: string;
  gender: string;
  sex: string;
  age: string | number;
  species: string;
  fingerprint: string;
  physical: string;
  mental: string;
  cause_of_death: string | null;
  photo_front: string | null;
  photo_side: string | null;
};

type Comment = {
  index: number;
  text: string;
  deleted: boolean;
};

type MedicalRecord = {
  blood_type: string;
  dna: string;
  mi_dis: string;
  mi_dis_d: string;
  ma_dis: string;
  ma_dis_d: string;
  alg: string;
  alg_d: string;
  cdi: string;
  cdi_d: string;
  notes: string;
  comments: Comment[];
};

type Virus = {
  name: string;
  stages: number;
  spread: string;
  cure: string;
  desc: string;
  danger: string;
  agent: string;
};

type Medbot = {
  name: string;
  x: number;
  y: number;
  area: string;
  on: boolean;
};

type Data = {
  authenticated: string | null;
  rank: string | null;
  screen: number | null;
  printing: boolean;
  temp: Temp | null;
  records?: RecordRow[];
  general?: General | null;
  medical?: MedicalRecord | null;
  viruses: Virus[];
  medbots?: Medbot[];
};

/** Statusy zostają w aktach po angielsku (czytają je HUD-y i inne konsole), tu tylko je tłumaczymy */
const STATUS_NAMES = {
  '*Deceased*': 'Zmarły',
  '*Unconscious*': 'Nieprzytomny',
  Active: 'Aktywny',
  'Physically Unfit': 'Niezdolny fizycznie',
  '*Insane*': 'Niepoczytalny',
  '*Unstable*': 'Niestabilny',
  '*Watch*': 'Obserwacja',
  Stable: 'Stabilny',
};

const STATUS_COLORS = {
  '*Deceased*': 'bad',
  '*Insane*': 'bad',
  '*Unconscious*': 'orange',
  '*Unstable*': 'orange',
  'Physically Unfit': 'blue',
  '*Watch*': 'blue',
  Active: 'good',
  Stable: 'good',
};

/** Domyślne wpisy nowych akt (code/datums/datacore.dm) */
const DEFAULT_TEXTS = {
  None: 'Brak',
  Unknown: 'Nieznane',
  'No minor disabilities have been declared.':
    'Nie zgłoszono drobnych niepełnosprawności.',
  'No minor disabilities have been diagnosed.':
    'Nie zdiagnozowano drobnych niepełnosprawności.',
  'No major disabilities have been diagnosed.':
    'Nie zdiagnozowano poważnych niepełnosprawności.',
  'No allergies have been detected in this patient.':
    'Nie wykryto u pacjenta alergii.',
  'No diseases have been diagnosed at the moment.':
    'Obecnie nie zdiagnozowano chorób.',
  'No notes.': 'Brak uwag.',
  Male: 'Mężczyzna',
  Female: 'Kobieta',
  Plural: 'Inna',
  Other: 'Inna',
};

const DANGER_NAMES = {
  Beneficial: 'Korzystna',
  Positive: 'Pozytywna',
  Harmless: 'Nieszkodliwa',
  Minor: 'Niewielkie',
  Medium: 'Średnie',
  Harmful: 'Szkodliwa',
  Dangerous: 'Niebezpieczna',
  BIOHAZARD: 'ZAGROŻENIE BIOLOGICZNE',
  PANDEMIC: 'PANDEMIA',
};

const DANGER_COLORS = {
  Beneficial: 'good',
  Positive: 'good',
  Harmless: 'label',
  Minor: 'olive',
  Medium: 'average',
  Harmful: 'orange',
  Dangerous: 'bad',
  BIOHAZARD: 'bad',
  PANDEMIC: 'bad',
};

const SPREAD_NAMES = {
  Airborne: 'Drogą powietrzną',
  Blood: 'Przez krew',
  Contact: 'Przez kontakt',
  Fluids: 'Przez płyny ustrojowe',
  'Intentional Injection': 'Celowy zastrzyk',
  None: 'Brak',
  Paranormal: 'Paranormalnie',
  Unknown: 'Nieznana',
  Acute: 'Ostra',
};

const translate = (text: string | null | undefined) =>
  (text && (STATUS_NAMES[text] || DEFAULT_TEXTS[text])) || text;

const useTopic = () => {
  const { act } = useBackend<Data>();
  return (params: Record<string, string | number>) => act('topic', params);
};

const TopicButton = (props: {
  params: Record<string, string | number>;
  icon?: string;
  color?: string;
  disabled?: boolean;
  tooltip?: string;
  fluid?: boolean;
  children?: React.ReactNode;
}) => {
  const topic = useTopic();
  return (
    <Button
      icon={props.icon}
      color={props.color}
      disabled={props.disabled}
      tooltip={props.tooltip}
      fluid={props.fluid}
      onClick={() => topic(props.params)}
    >
      {props.children}
    </Button>
  );
};

const EditField = (props: { field: string; icon?: string }) => (
  <TopicButton
    params={{ field: props.field }}
    icon={props.icon || 'pen'}
    tooltip="Zmień"
  />
);

export const MedicalRecordsConsole = (_) => {
  const { data } = useBackend<Data>();
  const { authenticated, screen, temp } = data;
  return (
    <Window width={780} height={640}>
      <Window.Content scrollable>
        {!authenticated ? (
          <LoginScreen />
        ) : (
          <>
            <Header />
            {temp && <TempScreen temp={temp} />}
            {!temp && (screen === 1 || screen === 2) && <RecordList />}
            {!temp && screen === 3 && <Maintenance />}
            {!temp && screen === 4 && <RecordView />}
            {!temp && screen === 5 && <VirusDatabase />}
            {!temp && screen === 6 && <MedbotTracking />}
          </>
        )}
      </Window.Content>
    </Window>
  );
};

const LoginScreen = () => (
  <Section title="Konsola akt medycznych">
    <NoticeBox info>
      Zaloguj się kartą z dostępem medycznym albo kryminalistycznym.
    </NoticeBox>
    <TopicButton params={{ login: 1 }} icon="sign-in-alt">
      Zaloguj
    </TopicButton>
  </Section>
);

const Header = () => {
  const { data } = useBackend<Data>();
  const { authenticated, rank, screen } = data;
  const tab = screen === 1 || screen === 4 ? 2 : screen;
  const topic = useTopic();
  return (
    <Section>
      <Stack align="center">
        <Stack.Item grow>
          <Tabs>
            <Tabs.Tab
              icon="notes-medical"
              selected={tab === 2}
              onClick={() => topic({ screen: 2 })}
            >
              Akta
            </Tabs.Tab>
            <Tabs.Tab
              icon="virus"
              selected={tab === 5}
              onClick={() => topic({ screen: 5 })}
            >
              Baza wirusów
            </Tabs.Tab>
            <Tabs.Tab
              icon="robot"
              selected={tab === 6}
              onClick={() => topic({ screen: 6 })}
            >
              Roboty medyczne
            </Tabs.Tab>
            <Tabs.Tab
              icon="tools"
              selected={tab === 3}
              onClick={() => topic({ screen: 3 })}
            >
              Konserwacja
            </Tabs.Tab>
          </Tabs>
        </Stack.Item>
        <Stack.Item color="label">
          <b>{authenticated}</b> ({rank})
        </Stack.Item>
        <Stack.Item>
          <TopicButton params={{ logout: 1 }} icon="sign-out-alt">
            Wyloguj
          </TopicButton>
        </Stack.Item>
      </Stack>
    </Section>
  );
};

const TempScreen = (props: { temp: Temp }) => {
  const topic = useTopic();
  const { temp } = props;
  return (
    <Section
      title="Wybierz"
      buttons={
        <TopicButton params={{ temp: 1 }} icon="times">
          Zamknij
        </TopicButton>
      }
    >
      <Box dangerouslySetInnerHTML={{ __html: temp.text }} />
      <Stack wrap mt={1}>
        {temp.buttons.map((button, index) => (
          <Stack.Item key={index}>
            <Button onClick={() => topic(button.params)}>
              {button.label}
            </Button>
          </Stack.Item>
        ))}
      </Stack>
    </Section>
  );
};

const SORT_KEYS = {
  name: (record: RecordRow) => record.name,
  id: (record: RecordRow) => record.id,
  rank: (record: RecordRow) => record.rank,
  blood_type: (record: RecordRow) => record.blood_type,
  physical: (record: RecordRow) => record.physical,
};

const RecordList = () => {
  const topic = useTopic();
  const { data } = useBackend<Data>();
  const { records = [] } = data;
  const [search, setSearch] = useState('');
  const [sortBy, setSortBy] = useState('name');
  const [ascending, setAscending] = useState(true);
  const query = search.toLowerCase();
  const shown = records
    .filter((record) =>
      [record.name, record.id, record.rank, record.fingerprint, record.dna]
        .join(' ')
        .toLowerCase()
        .includes(query),
    )
    .sort((a, b) => {
      const key = SORT_KEYS[sortBy];
      const result = `${key(a) || ''}`.localeCompare(`${key(b) || ''}`);
      return ascending ? result : -result;
    });

  const SortHeader = (props: { sort: string; label: string }) => {
    const active = sortBy === props.sort;
    return (
      <Button
        icon={
          active ? (ascending ? 'sort-alpha-down' : 'sort-alpha-up') : 'sort'
        }
        selected={active}
        onClick={() => {
          if (active) {
            setAscending(!ascending);
          } else {
            setSortBy(props.sort);
            setAscending(true);
          }
        }}
      >
        {props.label}
      </Button>
    );
  };

  return (
    <Section title={`Akta (${shown.length})`}>
      <Input
        fluid
        mb={1}
        placeholder="Szukaj po nazwisku, ID, stanowisku, odciskach lub DNA..."
        value={search}
        onInput={(e, value) => setSearch(value)}
      />
      <Table>
        <Table.Row header>
          <Table.Cell>
            <SortHeader sort="name" label="Nazwisko" />
          </Table.Cell>
          <Table.Cell>
            <SortHeader sort="rank" label="Stanowisko" />
          </Table.Cell>
          <Table.Cell>
            <SortHeader sort="blood_type" label="Krew" />
          </Table.Cell>
          <Table.Cell>
            <SortHeader sort="physical" label="Stan fizyczny" />
          </Table.Cell>
          <Table.Cell>Stan psychiczny</Table.Cell>
        </Table.Row>
        {shown.map((record) => (
          <Table.Row key={`${record.name}|${record.id}`} className="candystripe">
            <Table.Cell>
              <Button
                fluid
                icon="file-medical"
                onClick={() => topic({ d_rec: record.id })}
              >
                {record.name}
              </Button>
            </Table.Cell>
            <Table.Cell>{record.rank}</Table.Cell>
            <Table.Cell bold color="red">
              {translate(record.blood_type) || '—'}
            </Table.Cell>
            <Table.Cell color={STATUS_COLORS[record.physical] || 'label'}>
              {translate(record.physical)}
            </Table.Cell>
            <Table.Cell color={STATUS_COLORS[record.mental] || 'label'}>
              {translate(record.mental)}
            </Table.Cell>
          </Table.Row>
        ))}
      </Table>
      {shown.length === 0 && <Box color="label">Brak akt.</Box>}
    </Section>
  );
};

const Maintenance = () => (
  <Section title="Konserwacja akt">
    <NoticeBox>
      Usunięcie akt medycznych zostawia dane ogólne. Tego nie da się cofnąć.
    </NoticeBox>
    <TopicButton params={{ del_all: 1 }} icon="trash" color="bad">
      Usuń wszystkie akta medyczne
    </TopicButton>
  </Section>
);

const Photo = (props: { src: string | null; side: boolean }) => {
  const { src, side } = props;
  return (
    <Stack vertical align="center">
      <Stack.Item>
        {src ? (
          <img
            src={`data:image/png;base64,${src}`}
            width="96px"
            height="96px"
            style={{ imageRendering: 'pixelated', border: '2px solid #444' }}
          />
        ) : (
          <Box width="96px" height="96px" color="label" textAlign="center">
            brak zdjęcia
          </Box>
        )}
      </Stack.Item>
      <Stack.Item>
        <TopicButton
          params={{ field: side ? 'show_photo_side' : 'show_photo_front' }}
          icon="search-plus"
          disabled={!src}
        >
          {side ? 'Profil' : 'Przód'}
        </TopicButton>
      </Stack.Item>
    </Stack>
  );
};

const RecordView = () => {
  const { data } = useBackend<Data>();
  const { general, medical, printing } = data;
  return (
    <>
      <Section
        title={general ? general.name : 'Akta'}
        buttons={
          <>
            <TopicButton params={{ screen: 2 }} icon="arrow-left">
              Lista
            </TopicButton>
            <TopicButton
              params={{ print_p: 1 }}
              icon="print"
              disabled={printing}
            >
              {printing ? 'Drukowanie...' : 'Drukuj'}
            </TopicButton>
          </>
        }
      >
        {!general ? (
          <NoticeBox danger>Utracono akta ogólne!</NoticeBox>
        ) : (
          <Stack>
            <Stack.Item grow>
              <LabeledList>
                <LabeledList.Item label="ID">{general.id}</LabeledList.Item>
                <LabeledList.Item label="Stanowisko">
                  {general.rank}
                </LabeledList.Item>
                <LabeledList.Item
                  label="Płeć"
                  buttons={<EditField field="gender" icon="sync" />}
                >
                  {translate(general.gender)}
                </LabeledList.Item>
                <LabeledList.Item
                  label="Płeć biologiczna"
                  buttons={<EditField field="sex" icon="sync" />}
                >
                  {translate(general.sex)}
                </LabeledList.Item>
                <LabeledList.Item
                  label="Wiek"
                  buttons={<EditField field="age" />}
                >
                  {general.age}
                </LabeledList.Item>
                <LabeledList.Item
                  label="Gatunek"
                  buttons={<EditField field="species" />}
                >
                  {general.species}
                </LabeledList.Item>
                <LabeledList.Item
                  label="Odcisk palca"
                  buttons={<EditField field="fingerprint" />}
                >
                  {general.fingerprint}
                </LabeledList.Item>
                <LabeledList.Item
                  label="Stan fizyczny"
                  buttons={<EditField field="p_stat" icon="list" />}
                >
                  <Box bold color={STATUS_COLORS[general.physical]}>
                    {translate(general.physical)}
                  </Box>
                </LabeledList.Item>
                {general.physical === '*Deceased*' && (
                  <LabeledList.Item
                    label="Przyczyna zgonu"
                    buttons={<EditField field="cause_of_death" />}
                  >
                    {general.cause_of_death || (
                      <Box color="label">nieustalona</Box>
                    )}
                  </LabeledList.Item>
                )}
                <LabeledList.Item
                  label="Stan psychiczny"
                  buttons={<EditField field="m_stat" icon="list" />}
                >
                  <Box bold color={STATUS_COLORS[general.mental]}>
                    {translate(general.mental)}
                  </Box>
                </LabeledList.Item>
                <LabeledList.Item label="Akta ogólne">
                  <TopicButton
                    params={{ choice: 'View Past General' }}
                    icon="book"
                  >
                    Pokaż
                  </TopicButton>
                </LabeledList.Item>
              </LabeledList>
            </Stack.Item>
            <Stack.Item>
              <Photo src={general.photo_front} side={false} />
            </Stack.Item>
            <Stack.Item>
              <Photo src={general.photo_side} side />
            </Stack.Item>
          </Stack>
        )}
      </Section>
      {medical ? (
        <MedicalData medical={medical} />
      ) : (
        <Section title="Dane medyczne">
          <NoticeBox>Utracono akta medyczne!</NoticeBox>
          <TopicButton params={{ new: 1 }} icon="plus">
            Utwórz akta medyczne
          </TopicButton>
        </Section>
      )}
    </>
  );
};

const ConditionItem = (props: {
  label: string;
  field: string;
  value: string;
  details: string;
}) => (
  <>
    <LabeledList.Item
      label={props.label}
      buttons={<EditField field={props.field} />}
    >
      <Box bold>{translate(props.value)}</Box>
    </LabeledList.Item>
    <LabeledList.Item
      label="Szczegóły"
      buttons={<EditField field={`${props.field}_d`} />}
    >
      <Box color="label">{translate(props.details)}</Box>
    </LabeledList.Item>
    <LabeledList.Divider />
  </>
);

const MedicalData = (props: { medical: MedicalRecord }) => {
  const { medical } = props;
  return (
    <>
      <Section
        title="Dane medyczne"
        buttons={
          <>
            <TopicButton params={{ choice: 'View Past Medical' }} icon="book">
              Historia choroby
            </TopicButton>
            <TopicButton params={{ del_r: 1 }} icon="trash" color="bad">
              Usuń akta medyczne
            </TopicButton>
          </>
        }
      >
        <LabeledList>
          <LabeledList.Item
            label="Grupa krwi"
            buttons={<EditField field="blood_type" icon="list" />}
          >
            <Box bold color="red">
              {translate(medical.blood_type)}
            </Box>
          </LabeledList.Item>
          <LabeledList.Item label="DNA" buttons={<EditField field="b_dna" />}>
            {translate(medical.dna)}
          </LabeledList.Item>
          <LabeledList.Divider />
          <ConditionItem
            label="Drobne niepełnosprawności"
            field="mi_dis"
            value={medical.mi_dis}
            details={medical.mi_dis_d}
          />
          <ConditionItem
            label="Poważne niepełnosprawności"
            field="ma_dis"
            value={medical.ma_dis}
            details={medical.ma_dis_d}
          />
          <ConditionItem
            label="Alergie"
            field="alg"
            value={medical.alg}
            details={medical.alg_d}
          />
          <ConditionItem
            label="Obecne choroby"
            field="cdi"
            value={medical.cdi}
            details={medical.cdi_d}
          />
          <LabeledList.Item
            label="Ważne uwagi"
            buttons={<EditField field="notes" />}
          >
            {translate(medical.notes)}
          </LabeledList.Item>
        </LabeledList>
      </Section>
      <Section
        title="Komentarze i log"
        buttons={
          <TopicButton params={{ add_c: 1 }} icon="plus">
            Dodaj wpis
          </TopicButton>
        }
      >
        {medical.comments.length === 0 && (
          <Box color="label">Brak wpisów.</Box>
        )}
        {medical.comments.map((comment) =>
          comment.deleted ? (
            <Box key={comment.index} color="label" italic mb={1}>
              Wpis usunięty.
            </Box>
          ) : (
            <Section
              key={comment.index}
              buttons={
                <TopicButton
                  params={{ del_c: comment.index }}
                  icon="times"
                  color="bad"
                  tooltip="Usuń wpis"
                />
              }
            >
              <Box dangerouslySetInnerHTML={{ __html: comment.text }} />
            </Section>
          ),
        )}
      </Section>
    </>
  );
};

const VirusDatabase = () => {
  const { data } = useBackend<Data>();
  const viruses = [...(data.viruses || [])].sort((a, b) =>
    a.name.localeCompare(b.name),
  );
  const [selected, setSelected] = useState<string | null>(null);
  const [search, setSearch] = useState('');
  const shown = viruses.filter((virus) =>
    virus.name.toLowerCase().includes(search.toLowerCase()),
  );
  const virus = viruses.find((entry) => entry.name === selected);
  return (
    <Stack>
      <Stack.Item width="35%">
        <Section title="Baza wirusów">
          <Input
            fluid
            mb={1}
            placeholder="Szukaj..."
            value={search}
            onInput={(e, value) => setSearch(value)}
          />
          <Tabs vertical>
            {shown.map((entry) => (
              <Tabs.Tab
                key={entry.name}
                selected={entry.name === selected}
                onClick={() => setSelected(entry.name)}
              >
                <Box inline color={DANGER_COLORS[entry.danger]}>
                  {entry.name}
                </Box>
              </Tabs.Tab>
            ))}
          </Tabs>
        </Section>
      </Stack.Item>
      <Stack.Item grow>
        <Section title={virus ? virus.name : 'Szczegóły'}>
          {!virus ? (
            <Box color="label">Wybierz chorobę z listy.</Box>
          ) : (
            <LabeledList>
              <LabeledList.Item label="Zagrożenie">
                <Box bold color={DANGER_COLORS[virus.danger]}>
                  {DANGER_NAMES[virus.danger] || virus.danger}
                </Box>
              </LabeledList.Item>
              {!!virus.agent && (
                <LabeledList.Item label="Czynnik">{virus.agent}</LabeledList.Item>
              )}
              <LabeledList.Item label="Liczba stadiów">
                {virus.stages}
              </LabeledList.Item>
              <LabeledList.Item label="Przenoszenie">
                {SPREAD_NAMES[virus.spread] || virus.spread || 'nieznane'}
              </LabeledList.Item>
              <LabeledList.Item label="Możliwe leczenie">
                {virus.cure || 'brak'}
              </LabeledList.Item>
              <LabeledList.Item label="Opis">{virus.desc}</LabeledList.Item>
            </LabeledList>
          )}
        </Section>
      </Stack.Item>
    </Stack>
  );
};

const MedbotTracking = () => {
  const { data } = useBackend<Data>();
  const { medbots = [] } = data;
  return (
    <Section title="Roboty medyczne na tym pokładzie">
      {medbots.length === 0 ? (
        <NoticeBox>Nie wykryto robotów medycznych.</NoticeBox>
      ) : (
        <Table>
          <Table.Row header>
            <Table.Cell>Nazwa</Table.Cell>
            <Table.Cell>Miejsce</Table.Cell>
            <Table.Cell>Współrzędne</Table.Cell>
            <Table.Cell>Stan</Table.Cell>
          </Table.Row>
          {medbots.map((medbot, index) => (
            <Table.Row key={index} className="candystripe">
              <Table.Cell>{medbot.name}</Table.Cell>
              <Table.Cell>{medbot.area}</Table.Cell>
              <Table.Cell>
                {medbot.x}, {medbot.y}
              </Table.Cell>
              <Table.Cell color={medbot.on ? 'good' : 'bad'}>
                {medbot.on ? 'Włączony' : 'Wyłączony'}
              </Table.Cell>
            </Table.Row>
          ))}
        </Table>
      )}
    </Section>
  );
};
