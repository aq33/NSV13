// AQUILA - monitor serwerów telekomunikacji (aquila/code/game/machinery/telecomms/telecomms_monitors_ui.dm)
import {
  Box,
  Button,
  LabeledList,
  NoticeBox,
  Section,
  Stack,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Server = {
  id: string;
  name: string;
  ref: string;
};

type LogEntry = {
  index: number;
  name: string;
  type: string;
  source?: string;
  job?: string;
  race?: string;
  message?: string | null;
};

type Selected = {
  id: string;
  traffic: number;
  logs: LogEntry[];
};

type Data = {
  network: string;
  notice: string;
  servers: Server[];
  selected: Selected | null;
};

const formatTraffic = (traffic: number) =>
  traffic >= 1024
    ? `${Math.round(traffic / 1024)} TB`
    : `${Math.round(traffic)} GB`;

export const TelecommsLogBrowser = (_) => {
  const { act, data } = useBackend<Data>();
  const { network, notice, servers = [], selected } = data;
  return (
    <Window width={600} height={500}>
      <Window.Content scrollable>
        {!!notice && <NoticeBox info>{notice}</NoticeBox>}
        <Section
          title="Sieć"
          buttons={
            <Button icon="network-wired" onClick={() => act('network')}>
              Zmień sieć
            </Button>
          }
        >
          <LabeledList>
            <LabeledList.Item label="Obecna sieć">{network}</LabeledList.Item>
          </LabeledList>
        </Section>
        {selected ? (
          <ServerLogs selected={selected} />
        ) : (
          <Section
            title="Wykryte serwery"
            buttons={
              servers.length > 0 ? (
                <Button icon="trash" onClick={() => act('release')}>
                  Wyczyść bufor
                </Button>
              ) : (
                <Button icon="search" onClick={() => act('scan')}>
                  Skanuj
                </Button>
              )
            }
          >
            {servers.length === 0 && (
              <Box color="label">Brak serwerów. Zeskanuj sieć.</Box>
            )}
            {servers.map((server) => (
              <Button
                key={server.ref}
                fluid
                mb={0.5}
                icon="server"
                onClick={() => act('view', { ref: server.ref })}
              >
                {server.name} ({server.id})
              </Button>
            ))}
          </Section>
        )}
      </Window.Content>
    </Window>
  );
};

const ServerLogs = (props: { selected: Selected }) => {
  const { act } = useBackend<Data>();
  const { selected } = props;
  return (
    <Section
      title={`Serwer ${selected.id}`}
      buttons={
        <Button icon="arrow-left" onClick={() => act('main_menu')}>
          Wróć
        </Button>
      }
    >
      <LabeledList>
        <LabeledList.Item label="Zapisany ruch">
          {formatTraffic(selected.traffic)}
        </LabeledList.Item>
        <LabeledList.Item label="Wpisy">{selected.logs.length}</LabeledList.Item>
      </LabeledList>
      {selected.logs.map((log) => (
        <Section
          key={log.index}
          mt={1}
          title={log.name}
          buttons={
            <Button
              icon="times"
              color="bad"
              tooltip="Usuń wpis"
              onClick={() => act('delete', { index: log.index })}
            />
          }
        >
          {log.type === 'Speech File' ? (
            <LabeledList>
              <LabeledList.Item label="Źródło">
                {log.source} ({log.job})
              </LabeledList.Item>
              <LabeledList.Item label="Rasa">{log.race}</LabeledList.Item>
              <LabeledList.Item label="Treść">
                {log.message ? (
                  `"${log.message}"`
                ) : (
                  <Box italic color="label">
                    (niezrozumiałe)
                  </Box>
                )}
              </LabeledList.Item>
            </LabeledList>
          ) : log.type === 'Execution Error' ? (
            <Stack>
              <Stack.Item color="bad">Błąd:</Stack.Item>
              <Stack.Item>{log.message}</Stack.Item>
            </Stack>
          ) : (
            <LabeledList>
              <LabeledList.Item label="Typ danych">{log.type}</LabeledList.Item>
              <LabeledList.Item label="Treść">
                <Box italic color="label">
                  (niezrozumiałe)
                </Box>
              </LabeledList.Item>
            </LabeledList>
          )}
        </Section>
      ))}
    </Section>
  );
};
