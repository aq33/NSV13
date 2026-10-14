// AQUILA - terminal restauracji/baru z robotami-turystami (aquila/code/modules/restaurant/terminal.dm)
import {
  Box,
  Button,
  LabeledList,
  NoticeBox,
  ProgressBar,
  Section,
  Stack,
  Table,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Guest = {
  name: string;
  order: string | null;
  status: string;
  patience: number;
  waiting: boolean;
};

type Data = {
  venue_name: string;
  open: boolean;
  has_portal: boolean;
  has_access: boolean;
  served: number;
  lost: number;
  income: number;
  seats_total: number;
  seats_free: number;
  max_guests: number;
  projector_out: boolean;
  guests: Guest[];
};

export const RestaurantTerminal = (props) => {
  const { act, data } = useBackend<Data>();
  const {
    venue_name,
    open,
    has_portal,
    has_access,
    served,
    lost,
    income,
    seats_total,
    seats_free,
    max_guests,
    projector_out,
    guests = [],
  } = data;

  return (
    <Window title={venue_name} width={460} height={540}>
      <Window.Content scrollable>
        {!has_portal && (
          <NoticeBox danger>
            Brak portalu dla gości. Bez niego lokalu nie da się otworzyć.
          </NoticeBox>
        )}
        {!has_access && (
          <NoticeBox warning>
            Potrzebna jest karta z dostępem do tego lokalu.
          </NoticeBox>
        )}
        <Section
          title="Lokal"
          buttons={
            <Button
              icon={open ? 'door-closed' : 'door-open'}
              color={open ? 'bad' : 'good'}
              disabled={!has_access || (!open && !has_portal)}
              onClick={() => act('toggle')}
            >
              {open ? 'Zamknij lokal' : 'Otwórz lokal'}
            </Button>
          }
        >
          <LabeledList>
            <LabeledList.Item label="Stan">
              <Box color={open ? 'good' : 'average'} bold>
                {open ? 'Otwarty, portal przyjmuje gości' : 'Zamknięty'}
              </Box>
            </LabeledList.Item>
            <LabeledList.Item label="Obsłużeni goście">
              {served}
            </LabeledList.Item>
            <LabeledList.Item label="Wyszli głodni">{lost}</LabeledList.Item>
            <LabeledList.Item label="Zarobek">{income} kr</LabeledList.Item>
          </LabeledList>
        </Section>
        <Section title="Miejsca dla gości">
          <LabeledList>
            <LabeledList.Item label="Rozstawione">
              {seats_total} (wolne: {seats_free})
            </LabeledList.Item>
            <LabeledList.Item label="Najwięcej gości naraz">
              {max_guests}
            </LabeledList.Item>
          </LabeledList>
          <Stack mt={1}>
            <Stack.Item grow>
              <Button
                fluid
                icon="chair"
                disabled={!has_access || !has_portal}
                tooltip="Stawia miejsca w pomieszczeniu z portalem: na krzesłach przy stołach, a jeśli ich nie ma, obok stołów."
                onClick={() => act('auto_seats')}
              >
                Rozstaw miejsca
              </Button>
            </Stack.Item>
            <Stack.Item grow>
              <Button
                fluid
                icon="eraser"
                disabled={!has_access || !seats_total}
                tooltip="Zdejmuje wszystkie miejsca, na których nikt nie siedzi."
                onClick={() => act('clear_seats')}
              >
                Zdejmij wolne
              </Button>
            </Stack.Item>
            <Stack.Item grow>
              <Button
                fluid
                icon="magic"
                disabled={!has_access || projector_out}
                tooltip={
                  projector_out
                    ? 'Projektor jest już wydany.'
                    : 'Ręczny projektor do stawiania i zdejmowania miejsc.'
                }
                onClick={() => act('projector')}
              >
                Wydaj projektor
              </Button>
            </Stack.Item>
          </Stack>
        </Section>
        <Section title={`Goście (${guests.length})`}>
          {guests.length === 0 ? (
            <Box color="label">
              {open ? 'Czekamy na pierwszego gościa...' : 'Lokal jest pusty.'}
            </Box>
          ) : (
            <Table>
              <Table.Row header>
                <Table.Cell>Gość</Table.Cell>
                <Table.Cell>Zamówienie</Table.Cell>
                <Table.Cell collapsing>Cierpliwość</Table.Cell>
              </Table.Row>
              {guests.map((guest, i) => (
                <Table.Row key={i} className="candystripe">
                  <Table.Cell>
                    <Box bold>{guest.name}</Box>
                    <Box color="label" fontSize="0.9em">
                      {guest.status}
                    </Box>
                  </Table.Cell>
                  <Table.Cell>{guest.order || '—'}</Table.Cell>
                  <Table.Cell collapsing>
                    {guest.waiting ? (
                      <ProgressBar
                        width="80px"
                        value={guest.patience / 100}
                        ranges={{
                          good: [0.5, Infinity],
                          average: [0.2, 0.5],
                          bad: [-Infinity, 0.2],
                        }}
                      />
                    ) : (
                      '—'
                    )}
                  </Table.Cell>
                </Table.Row>
              ))}
            </Table>
          )}
        </Section>
      </Window.Content>
    </Window>
  );
};
