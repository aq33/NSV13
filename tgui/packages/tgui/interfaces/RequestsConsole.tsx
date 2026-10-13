// AQUILA - konsola zgłoszeń (aquila/code/game/machinery/requests_console_ui.dm)
import {
  Box,
  Button,
  LabeledList,
  NoticeBox,
  Section,
  Stack,
  Table,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

// Numery ekranów z requests_console.dm
const SCREEN_MAIN = 0;
const SCREEN_ASSISTANCE = 1;
const SCREEN_SUPPLIES = 2;
const SCREEN_RELAY = 3;
const SCREEN_SENT = 6;
const SCREEN_ERROR = 7;
const SCREEN_MESSAGES = 8;
const SCREEN_AUTHENTICATE = 9;
const SCREEN_ANNOUNCE = 10;
const SCREEN_SQUAD = 11;

const EMERGENCY_SECURITY = 1;
const EMERGENCY_ENGINEERING = 2;
const EMERGENCY_MEDICAL = 3;

type Department = {
  name: string;
  key: string;
};

type Data = {
  screen: number;
  department: string;
  new_priority: number;
  emergency: string | null;
  announcement_console: boolean;
  silent: boolean;
  hacked: boolean;
  has_squads: boolean;
  message: string;
  to_department: string;
  verified: string;
  stamped: string;
  announce_auth: boolean;
  departments: Department[];
  messages: string[];
};

const NEW_MESSAGE_NOTICE = [
  '',
  'Masz nowe wiadomości.',
  'Masz nowe wiadomości PRIORYTETOWE.',
  'Masz nowe wiadomości o SKRAJNYM priorytecie!',
];

const BackButton = (props: { label?: string }) => {
  const { act } = useBackend<Data>();
  return (
    <Button
      icon="arrow-left"
      onClick={() => act('set_screen', { screen: SCREEN_MAIN })}
    >
      {props.label || 'Wróć'}
    </Button>
  );
};

export const RequestsConsole = (_) => {
  const { data } = useBackend<Data>();
  const { screen } = data;
  return (
    <Window width={480} height={520}>
      <Window.Content scrollable>
        {screen === SCREEN_MAIN && <MainScreen />}
        {(screen === SCREEN_ASSISTANCE ||
          screen === SCREEN_SUPPLIES ||
          screen === SCREEN_RELAY) && <DepartmentScreen />}
        {screen === SCREEN_SENT && (
          <Section title="Wysłano" buttons={<BackButton />}>
            <Box color="good">Wiadomość została wysłana.</Box>
          </Section>
        )}
        {screen === SCREEN_ERROR && (
          <Section title="Błąd" buttons={<BackButton />}>
            <Box color="bad">Nie udało się wysłać wiadomości.</Box>
          </Section>
        )}
        {screen === SCREEN_MESSAGES && <MessagesScreen />}
        {(screen === SCREEN_AUTHENTICATE || screen === SCREEN_SQUAD) && (
          <AuthenticateScreen />
        )}
        {screen === SCREEN_ANNOUNCE && <AnnounceScreen />}
      </Window.Content>
    </Window>
  );
};

const MainScreen = () => {
  const { act, data } = useBackend<Data>();
  const {
    department,
    new_priority,
    emergency,
    announcement_console,
    silent,
    has_squads,
  } = data;
  return (
    <>
      {new_priority > 0 && (
        <NoticeBox danger={new_priority > 1}>
          {NEW_MESSAGE_NOTICE[new_priority]}
        </NoticeBox>
      )}
      <Section
        title={department}
        buttons={
          <Button
            icon={silent ? 'volume-mute' : 'volume-up'}
            selected={!silent}
            onClick={() => act('silent')}
          >
            Głośnik
          </Button>
        }
      >
        <Button
          fluid
          icon="envelope-open-text"
          onClick={() => act('set_screen', { screen: SCREEN_MESSAGES })}
        >
          Wiadomości
        </Button>
      </Section>
      <Section title="Wyślij">
        <Button
          fluid
          icon="hands-helping"
          onClick={() => act('set_screen', { screen: SCREEN_ASSISTANCE })}
        >
          Poproś o pomoc
        </Button>
        <Button
          fluid
          icon="box"
          onClick={() => act('set_screen', { screen: SCREEN_SUPPLIES })}
        >
          Zamów zaopatrzenie
        </Button>
        <Button
          fluid
          icon="user-secret"
          onClick={() => act('set_screen', { screen: SCREEN_RELAY })}
        >
          Przekaż anonimową informację
        </Button>
        {!!has_squads && (
          <Button fluid icon="users" onClick={() => act('write_squad')}>
            Wezwij drużynę
          </Button>
        )}
        {!!announcement_console && (
          <Button
            fluid
            icon="bullhorn"
            onClick={() => act('set_screen', { screen: SCREEN_ANNOUNCE })}
          >
            Ogłoszenie na cały statek
          </Button>
        )}
      </Section>
      <Section title="Alarm">
        {emergency ? (
          <NoticeBox danger>{emergency}: wysłano wezwanie na to miejsce.</NoticeBox>
        ) : (
          <Stack>
            <Stack.Item grow>
              <Button
                fluid
                color="bad"
                icon="shield-alt"
                onClick={() =>
                  act('emergency', { type: EMERGENCY_SECURITY })
                }
              >
                Ochrona
              </Button>
            </Stack.Item>
            <Stack.Item grow>
              <Button
                fluid
                color="bad"
                icon="wrench"
                onClick={() =>
                  act('emergency', { type: EMERGENCY_ENGINEERING })
                }
              >
                Inżynieria
              </Button>
            </Stack.Item>
            <Stack.Item grow>
              <Button
                fluid
                color="bad"
                icon="medkit"
                onClick={() => act('emergency', { type: EMERGENCY_MEDICAL })}
              >
                Medyczny
              </Button>
            </Stack.Item>
          </Stack>
        )}
      </Section>
    </>
  );
};

const DEPARTMENT_SCREEN_TITLES = {
  [SCREEN_ASSISTANCE]: 'Od którego działu potrzebujesz pomocy?',
  [SCREEN_SUPPLIES]: 'Od którego działu potrzebujesz zaopatrzenia?',
  [SCREEN_RELAY]: 'Do którego działu wysłać informację?',
};

const DepartmentScreen = () => {
  const { act, data } = useBackend<Data>();
  const { screen, departments = [], hacked } = data;
  return (
    <Section title={DEPARTMENT_SCREEN_TITLES[screen]} buttons={<BackButton />}>
      {departments.length === 0 && (
        <Box color="label">Brak działów, do których można pisać.</Box>
      )}
      <Table>
        {departments.map((department) => (
          <Table.Row key={department.key} className="candystripe">
            <Table.Cell>{department.name}</Table.Cell>
            <Table.Cell collapsing>
              <Button
                onClick={() =>
                  act('write', { department: department.key, priority: 1 })
                }
              >
                Zwykły
              </Button>
              <Button
                color="average"
                onClick={() =>
                  act('write', { department: department.key, priority: 2 })
                }
              >
                Pilny
              </Button>
              {!!hacked && (
                <Button
                  color="bad"
                  onClick={() =>
                    act('write', { department: department.key, priority: 3 })
                  }
                >
                  SKRAJNY
                </Button>
              )}
            </Table.Cell>
          </Table.Row>
        ))}
      </Table>
    </Section>
  );
};

const MessagesScreen = () => {
  const { data } = useBackend<Data>();
  const { messages = [] } = data;
  return (
    <Section title="Wiadomości" buttons={<BackButton />}>
      {messages.length === 0 && <Box color="label">Brak wiadomości.</Box>}
      {messages.map((message, index) => (
        <Section key={index}>
          <Box dangerouslySetInnerHTML={{ __html: message }} />
        </Section>
      ))}
    </Section>
  );
};

const AuthenticateScreen = () => {
  const { act, data } = useBackend<Data>();
  const { screen, message, to_department, verified, stamped } = data;
  const squad = screen === SCREEN_SQUAD;
  return (
    <Section
      title={squad ? 'Wiadomość do drużyny' : 'Potwierdzenie wiadomości'}
      buttons={<BackButton label="Odrzuć" />}
    >
      <LabeledList>
        {!squad && (
          <LabeledList.Item label="Do">{to_department}</LabeledList.Item>
        )}
        <LabeledList.Item label="Treść">{message}</LabeledList.Item>
        <LabeledList.Item label="Potwierdzone">
          {verified || <Box color="label">nie (przeciągnij kartę ID)</Box>}
        </LabeledList.Item>
        <LabeledList.Item label="Pieczątka">
          {stamped || <Box color="label">brak (przyłóż pieczątkę)</Box>}
        </LabeledList.Item>
      </LabeledList>
      <Button
        mt={1}
        fluid
        icon="paper-plane"
        onClick={() => act(squad ? 'send_squad' : 'send')}
      >
        Wyślij
      </Button>
    </Section>
  );
};

const AnnounceScreen = () => {
  const { act, data } = useBackend<Data>();
  const { message, announce_auth } = data;
  return (
    <Section title="Ogłoszenie na cały statek" buttons={<BackButton />}>
      {announce_auth ? (
        <NoticeBox info>Uprawnienia potwierdzone.</NoticeBox>
      ) : (
        <NoticeBox danger>
          Przeciągnij kartę ID, aby potwierdzić uprawnienia.
        </NoticeBox>
      )}
      <LabeledList>
        <LabeledList.Item label="Treść">
          {message || <Box color="label">brak</Box>}
        </LabeledList.Item>
      </LabeledList>
      <Stack mt={1}>
        <Stack.Item grow>
          <Button fluid icon="pen" onClick={() => act('write_announcement')}>
            {message ? 'Zmień treść' : 'Napisz'}
          </Button>
        </Stack.Item>
        <Stack.Item grow>
          <Button
            fluid
            icon="bullhorn"
            disabled={!announce_auth || !message}
            onClick={() => act('send_announcement')}
          >
            Ogłoś
          </Button>
        </Stack.Item>
      </Stack>
    </Section>
  );
};
