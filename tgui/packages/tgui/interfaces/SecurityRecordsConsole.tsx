// AQUILA - konsola rekordów ochrony (aquila/code/game/machinery/computer/security_records_ui.dm)
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
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type TopicButton = {
  params: Record<string, string>;
  label: string;
};

type Temp = {
  text: string;
  buttons: TopicButton[];
};

type RecordRow = {
  ref: string;
  name: string;
  id: string;
  rank: string;
  fingerprint: string;
  criminal: string;
};

type General = {
  name: string;
  id: string;
  gender: string;
  age: string | number;
  species: string;
  rank: string;
  fingerprint: string;
  physical: string;
  mental: string;
  photo_front: string | null;
  photo_side: string | null;
};

type Citation = {
  id: number;
  name: string;
  fine: number;
  owed: number;
  author: string;
  time: string;
};

type Crime = {
  id: number;
  name: string;
  details: string;
  author: string;
  time: string;
};

type Comment = {
  index: number;
  text: string;
  deleted: boolean;
};

type SecurityRecord = {
  criminal: string;
  notes: string;
  citations: Citation[];
  crimes: Crime[];
  comments: Comment[];
};

type Data = {
  authenticated: string | null;
  rank: string | null;
  screen: number | null;
  printing: boolean;
  sort_by: string;
  order: number;
  temp: Temp | null;
  records?: RecordRow[];
  general?: General | null;
  security?: SecurityRecord | null;
};

const STATUS_COLORS = {
  Arrest: 'bad',
  Incarcerated: 'orange',
  Search: 'purple',
  Monitor: 'bad',
  Paroled: 'average',
  Discharged: 'blue',
  None: 'good',
};

const STATUS_NAMES = {
  Arrest: 'Do aresztowania',
  Incarcerated: 'Uwięziony',
  Search: 'Do przeszukania',
  Monitor: 'Obserwacja',
  Paroled: 'Zwolniony warunkowo',
  Discharged: 'Zwolniony',
  None: 'Brak',
};

const useTopic = () => {
  const { act } = useBackend<Data>();
  return (params: Record<string, string | number>) => act('topic', params);
};

const ChoiceButton = (props: {
  choice: string;
  extra?: Record<string, string | number>;
  icon?: string;
  color?: string;
  disabled?: boolean;
  tooltip?: string;
  children?: React.ReactNode;
}) => {
  const topic = useTopic();
  return (
    <Button
      icon={props.icon}
      color={props.color}
      disabled={props.disabled}
      tooltip={props.tooltip}
      onClick={() => topic({ choice: props.choice, ...props.extra })}
    >
      {props.children}
    </Button>
  );
};

const EditField = (props: {
  field: string;
  children?: React.ReactNode;
  icon?: string;
  tooltip?: string;
}) => (
  <ChoiceButton
    choice="Edit Field"
    extra={{ field: props.field }}
    icon={props.icon || 'pen'}
    tooltip={props.tooltip}
  >
    {props.children}
  </ChoiceButton>
);

export const SecurityRecordsConsole = (_) => {
  const { data } = useBackend<Data>();
  const { authenticated, screen, temp } = data;
  return (
    <Window width={760} height={640}>
      <Window.Content scrollable>
        {!authenticated ? (
          <LoginScreen />
        ) : (
          <>
            <Header />
            {temp && <TempScreen temp={temp} />}
            {!temp && screen === 1 && <RecordList />}
            {!temp && screen === 2 && <Maintenance />}
            {!temp && screen === 3 && <RecordView />}
          </>
        )}
      </Window.Content>
    </Window>
  );
};

const LoginScreen = () => (
  <Section>
    <NoticeBox info>Zaloguj się kartą z dostępem do rekordów ochrony.</NoticeBox>
    <ChoiceButton choice="Log In" icon="sign-in-alt">
      Zaloguj
    </ChoiceButton>
  </Section>
);

const Header = () => {
  const { data } = useBackend<Data>();
  const { authenticated, rank, screen } = data;
  return (
    <Section>
      <Stack align="center">
        <Stack.Item grow>
          Zalogowano: <b>{authenticated}</b> ({rank})
        </Stack.Item>
        {screen !== 1 && (
          <Stack.Item>
            <ChoiceButton choice="Return" icon="arrow-left">
              Lista rekordów
            </ChoiceButton>
          </Stack.Item>
        )}
        <Stack.Item>
          <ChoiceButton choice="Log Out" icon="sign-out-alt">
            Wyloguj
          </ChoiceButton>
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
        <ChoiceButton choice="Clear Screen" icon="times">
          Zamknij
        </ChoiceButton>
      }
    >
      <Box dangerouslySetInnerHTML={{ __html: temp.text }} />
      <Stack wrap mt={1}>
        {temp.buttons.map((button, index) => (
          <Stack.Item key={index}>
            <Button onClick={() => topic(button.params)}>
              {STATUS_NAMES[button.label] || button.label}
            </Button>
          </Stack.Item>
        ))}
      </Stack>
    </Section>
  );
};

const SortHeader = (props: { sort: string; label: string }) => {
  const { data } = useBackend<Data>();
  const { sort_by, order } = data;
  const active = sort_by === props.sort;
  return (
    <ChoiceButton
      choice="Sorting"
      extra={{ sort: props.sort }}
      icon={active ? (order === 1 ? 'sort-alpha-down' : 'sort-alpha-up') : 'sort'}
    >
      {props.label}
    </ChoiceButton>
  );
};

const RecordList = () => {
  const topic = useTopic();
  const { data } = useBackend<Data>();
  const { records = [] } = data;
  const [search, setSearch] = useState('');
  const query = search.toLowerCase();
  const shown = records.filter((record) =>
    [record.name, record.id, record.rank, record.fingerprint]
      .join(' ')
      .toLowerCase()
      .includes(query),
  );
  return (
    <Section
      title="Rekordy"
      buttons={
        <>
          <ChoiceButton choice="New Record (General)" icon="plus">
            Nowy rekord
          </ChoiceButton>
          <ChoiceButton choice="Record Maintenance" icon="tools">
            Konserwacja
          </ChoiceButton>
        </>
      }
    >
      <Input
        fluid
        mb={1}
        placeholder="Szukaj po nazwisku, ID, stanowisku lub odciskach..."
        value={search}
        onInput={(e, value) => setSearch(value)}
      />
      <Table>
        <Table.Row header>
          <Table.Cell>
            <SortHeader sort="name" label="Nazwisko" />
          </Table.Cell>
          <Table.Cell>
            <SortHeader sort="id" label="ID" />
          </Table.Cell>
          <Table.Cell>
            <SortHeader sort="rank" label="Stanowisko" />
          </Table.Cell>
          <Table.Cell>
            <SortHeader sort="fingerprint" label="Odciski" />
          </Table.Cell>
          <Table.Cell>Status</Table.Cell>
        </Table.Row>
        {shown.map((record) => (
          <Table.Row key={record.ref} className="candystripe">
            <Table.Cell>
              <Button
                fluid
                onClick={() =>
                  topic({ choice: 'Browse Record', d_rec: record.ref })
                }
              >
                {record.name}
              </Button>
            </Table.Cell>
            <Table.Cell>{record.id}</Table.Cell>
            <Table.Cell>{record.rank}</Table.Cell>
            <Table.Cell>{record.fingerprint}</Table.Cell>
            <Table.Cell color={STATUS_COLORS[record.criminal] || 'label'}>
              {STATUS_NAMES[record.criminal] || 'Brak rekordu'}
            </Table.Cell>
          </Table.Row>
        ))}
      </Table>
    </Section>
  );
};

const Maintenance = () => (
  <Section title="Konserwacja rekordów">
    <ChoiceButton choice="Delete All Records" icon="trash" color="bad">
      Usuń wszystkie rekordy ochrony
    </ChoiceButton>
  </Section>
);

const Photo = (props: { src: string | null; side: boolean }) => {
  const { src, side } = props;
  const suffix = side ? 'side' : 'front';
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
        <EditField field={`upd_photo_${suffix}`} icon="camera">
          Zmień
        </EditField>
        <EditField field={`print_photo_${suffix}`} icon="print">
          Drukuj
        </EditField>
      </Stack.Item>
    </Stack>
  );
};

const RecordView = () => {
  const { data } = useBackend<Data>();
  const { general, security, printing } = data;
  return (
    <>
      <Section
        title="Dane ogólne"
        buttons={
          <>
            <ChoiceButton
              choice="Print Record"
              icon="print"
              disabled={printing}
            >
              Drukuj rekord
            </ChoiceButton>
            <ChoiceButton
              choice="Print Poster"
              icon="exclamation-triangle"
              disabled={printing}
            >
              List gończy
            </ChoiceButton>
            <ChoiceButton
              choice="Print Missing"
              icon="question"
              disabled={printing}
            >
              Zaginiony
            </ChoiceButton>
          </>
        }
      >
        {!general ? (
          <NoticeBox danger>Rekord ogólny utracony.</NoticeBox>
        ) : (
          <Stack>
            <Stack.Item grow>
              <LabeledList>
                <LabeledList.Item
                  label="Nazwisko"
                  buttons={<EditField field="name" />}
                >
                  {general.name}
                </LabeledList.Item>
                <LabeledList.Item label="ID" buttons={<EditField field="id" />}>
                  {general.id}
                </LabeledList.Item>
                <LabeledList.Item
                  label="Płeć"
                  buttons={<EditField field="gender" icon="sync" />}
                >
                  {general.gender}
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
                  label="Stanowisko"
                  buttons={<EditField field="rank" />}
                >
                  {general.rank}
                </LabeledList.Item>
                <LabeledList.Item
                  label="Odciski"
                  buttons={<EditField field="fingerprint" />}
                >
                  {general.fingerprint}
                </LabeledList.Item>
                <LabeledList.Item label="Stan fizyczny">
                  {general.physical}
                </LabeledList.Item>
                <LabeledList.Item label="Stan psychiczny">
                  {general.mental}
                </LabeledList.Item>
                <LabeledList.Item label="Przeszłość">
                  <ChoiceButton choice="View Past General" icon="book">
                    Pokaż
                  </ChoiceButton>
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
      {security ? (
        <SecurityData security={security} />
      ) : (
        <Section title="Dane ochrony">
          <NoticeBox>Rekord ochrony utracony.</NoticeBox>
          <ChoiceButton choice="New Record (Security)" icon="plus">
            Utwórz rekord ochrony
          </ChoiceButton>
        </Section>
      )}
      <Section title="Usuwanie">
        <ChoiceButton choice="Delete Record (Security)" icon="trash">
          Usuń tylko dane ochrony
        </ChoiceButton>
        <ChoiceButton choice="Delete Record (ALL)" icon="trash" color="bad">
          Usuń cały rekord
        </ChoiceButton>
      </Section>
    </>
  );
};

const SecurityData = (props: { security: SecurityRecord }) => {
  const topic = useTopic();
  const { security } = props;
  return (
    <>
      <Section title="Dane ochrony">
        <LabeledList>
          <LabeledList.Item
            label="Status"
            buttons={<EditField field="criminal">Zmień</EditField>}
          >
            <Box color={STATUS_COLORS[security.criminal]} bold>
              {STATUS_NAMES[security.criminal] || security.criminal}
            </Box>
          </LabeledList.Item>
          <LabeledList.Item
            label="Ważne uwagi"
            buttons={<EditField field="notes" />}
          >
            {security.notes}
          </LabeledList.Item>
          <LabeledList.Item label="Przeszłość">
            <ChoiceButton choice="View Past Security" icon="book">
              Pokaż
            </ChoiceButton>
          </LabeledList.Item>
        </LabeledList>
      </Section>
      <Section
        title="Mandaty"
        buttons={
          <EditField field="citation_add" icon="plus">
            Dodaj
          </EditField>
        }
      >
        {security.citations.length === 0 ? (
          <Box color="label">Brak mandatów.</Box>
        ) : (
          <Table>
            <Table.Row header>
              <Table.Cell>Wykroczenie</Table.Cell>
              <Table.Cell>Kwota</Table.Cell>
              <Table.Cell>Wystawił</Table.Cell>
              <Table.Cell>Czas</Table.Cell>
              <Table.Cell>Do zapłaty</Table.Cell>
              <Table.Cell collapsing />
            </Table.Row>
            {security.citations.map((citation) => (
              <Table.Row key={citation.id} className="candystripe">
                <Table.Cell>{citation.name}</Table.Cell>
                <Table.Cell>{citation.fine} cr</Table.Cell>
                <Table.Cell>{citation.author}</Table.Cell>
                <Table.Cell>{citation.time}</Table.Cell>
                <Table.Cell>
                  {citation.owed > 0 ? (
                    <Button
                      icon="money-bill"
                      tooltip="Zapłać holoczipem trzymanym w ręce"
                      onClick={() =>
                        topic({
                          choice: 'Pay',
                          field: 'citation_pay',
                          cdataid: citation.id,
                        })
                      }
                    >
                      {citation.owed} cr
                    </Button>
                  ) : (
                    <Box color="good">Spłacony</Box>
                  )}
                </Table.Cell>
                <Table.Cell collapsing>
                  <Button
                    icon="times"
                    color="bad"
                    onClick={() =>
                      topic({
                        choice: 'Edit Field',
                        field: 'citation_delete',
                        cdataid: citation.id,
                      })
                    }
                  />
                </Table.Cell>
              </Table.Row>
            ))}
          </Table>
        )}
      </Section>
      <Section
        title="Przestępstwa"
        buttons={
          <EditField field="crim_add" icon="plus">
            Dodaj
          </EditField>
        }
      >
        {security.crimes.length === 0 ? (
          <Box color="label">Brak przestępstw.</Box>
        ) : (
          <Table>
            <Table.Row header>
              <Table.Cell>Przestępstwo</Table.Cell>
              <Table.Cell>Szczegóły</Table.Cell>
              <Table.Cell>Dodał</Table.Cell>
              <Table.Cell>Czas</Table.Cell>
              <Table.Cell collapsing />
            </Table.Row>
            {security.crimes.map((crime) => (
              <Table.Row key={crime.id} className="candystripe">
                <Table.Cell>{crime.name}</Table.Cell>
                <Table.Cell>
                  {crime.details || (
                    <Button
                      icon="plus"
                      onClick={() =>
                        topic({
                          choice: 'Edit Field',
                          field: 'add_details',
                          cdataid: crime.id,
                        })
                      }
                    >
                      Dodaj
                    </Button>
                  )}
                </Table.Cell>
                <Table.Cell>{crime.author}</Table.Cell>
                <Table.Cell>{crime.time}</Table.Cell>
                <Table.Cell collapsing>
                  <Button
                    icon="times"
                    color="bad"
                    onClick={() =>
                      topic({
                        choice: 'Edit Field',
                        field: 'crim_delete',
                        cdataid: crime.id,
                      })
                    }
                  />
                </Table.Cell>
              </Table.Row>
            ))}
          </Table>
        )}
      </Section>
      <Section
        title="Komentarze"
        buttons={
          <ChoiceButton choice="Add Entry" icon="plus">
            Dodaj
          </ChoiceButton>
        }
      >
        {security.comments.length === 0 && (
          <Box color="label">Brak komentarzy.</Box>
        )}
        {security.comments.map((comment) => (
          <Section
            key={comment.index}
            buttons={
              !comment.deleted && (
                <ChoiceButton
                  choice="Delete Entry"
                  extra={{ del_c: comment.index }}
                  icon="times"
                  color="bad"
                />
              )
            }
          >
            <Box dangerouslySetInnerHTML={{ __html: comment.text }} />
          </Section>
        ))}
      </Section>
    </>
  );
};
