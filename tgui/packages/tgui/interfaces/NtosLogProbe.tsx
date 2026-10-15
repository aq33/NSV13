// AQUILA EDIT - czytnik logów dostępu (aquila/code/modules/modular_computers/file_system/programs/logprobe.dm)
import {
  Box,
  Button,
  LabeledList,
  NoticeBox,
  Section,
  Table,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { NtosWindow } from '../layouts';

type LogEntry = {
  time: string;
  name: string;
  action: string;
};

type Data = {
  device: string | null;
  area: string | null;
  scan_time: string | null;
  entries: LogEntry[];
  logging_disabled: boolean;
  damaged: boolean;
};

export const NtosLogProbe = (_) => {
  const { act, data } = useBackend<Data>();
  const {
    device,
    area,
    scan_time,
    entries = [],
    logging_disabled,
    damaged,
  } = data;
  return (
    <NtosWindow width={480} height={520}>
      <NtosWindow.Content scrollable>
        {!device ? (
          <NoticeBox info>
            Kliknij tabletem w drzwi albo zamykaną szafkę, żeby skopiować log
            dostępu z jej czytnika ID. Program musi być uruchomiony.
          </NoticeBox>
        ) : (
          <>
            <Section
              title="Urządzenie"
              buttons={
                <>
                  <Button icon="print" onClick={() => act('print')}>
                    Drukuj
                  </Button>
                  <Button icon="trash" onClick={() => act('clear')}>
                    Wyczyść
                  </Button>
                </>
              }
            >
              <LabeledList>
                <LabeledList.Item label="Nazwa">{device}</LabeledList.Item>
                <LabeledList.Item label="Miejsce">{area}</LabeledList.Item>
                <LabeledList.Item label="Odczyt">{scan_time}</LabeledList.Item>
              </LabeledList>
            </Section>
            {!!logging_disabled && (
              <NoticeBox warning>
                Czytnik ID jest odłączony. Logowanie nie działa.
              </NoticeBox>
            )}
            {!!damaged && (
              <NoticeBox danger>
                Czytnik ID nosi ślady zwarcia. Pamięć logu jest pusta.
              </NoticeBox>
            )}
            <Section title={`Wpisy (${entries.length})`}>
              {entries.length === 0 ? (
                <Box color="label">Brak wpisów.</Box>
              ) : (
                <Table>
                  <Table.Row header>
                    <Table.Cell collapsing>#</Table.Cell>
                    <Table.Cell collapsing>Czas</Table.Cell>
                    <Table.Cell>Kto</Table.Cell>
                    <Table.Cell collapsing>Akcja</Table.Cell>
                  </Table.Row>
                  {entries.map((entry, index) => (
                    <Table.Row key={index} className="candystripe">
                      <Table.Cell collapsing color="label">
                        {index + 1}.
                      </Table.Cell>
                      <Table.Cell collapsing>{entry.time}</Table.Cell>
                      <Table.Cell>{entry.name}</Table.Cell>
                      <Table.Cell collapsing color="label">
                        {entry.action}
                      </Table.Cell>
                    </Table.Row>
                  ))}
                </Table>
              )}
            </Section>
          </>
        )}
      </NtosWindow.Content>
    </NtosWindow>
  );
};
