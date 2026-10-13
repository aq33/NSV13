// AQUILA EDIT - program nagłośnienia statku (aquila/code/modules/modular_computers/file_system/programs/jukebox_broadcast.dm)
import { Box, Button, NoticeBox, Section, Table } from 'tgui-core/components';

import { useBackend } from '../backend';
import { NtosWindow } from '../layouts';

type Jukebox = {
  ref: string;
  name: string;
  area: string;
  playing: boolean;
  title: string | null;
  shipwide: boolean;
};

type Data = {
  jukeboxes: Jukebox[];
  on_ship: boolean;
};

export const NtosJukeboxBroadcast = (_) => {
  const { act, data } = useBackend<Data>();
  const { jukeboxes = [], on_ship } = data;
  return (
    <NtosWindow width={460} height={420}>
      <NtosWindow.Content scrollable>
        <NoticeBox info>
          Nadający jukebox gra przez głośniki nagłośnienia na korytarzach; w
          pomieszczeniach i maintach słychać je przez ściany, ciszej. Na raz
          może nadawać tylko jeden. Kto jest bliżej innego grającego jukeboxa,
          słyszy ten głośniejszy.
        </NoticeBox>
        {!on_ship && (
          <NoticeBox danger>Ten komputer nie jest na żadnym statku.</NoticeBox>
        )}
        <Section title="Jukeboxy na statku">
          {jukeboxes.length === 0 && (
            <Box color="label">Brak jukeboxów na tym statku.</Box>
          )}
          {jukeboxes.length > 0 && (
            <Table>
              <Table.Row header>
                <Table.Cell>Jukebox</Table.Cell>
                <Table.Cell>Teraz gra</Table.Cell>
                <Table.Cell collapsing />
              </Table.Row>
              {jukeboxes.map((jukebox) => (
                <Table.Row key={jukebox.ref} className="candystripe">
                  <Table.Cell>
                    <Box bold>{jukebox.name}</Box>
                    <Box color="label">{jukebox.area}</Box>
                  </Table.Cell>
                  <Table.Cell>
                    {jukebox.playing ? (
                      jukebox.title || 'Łączenie...'
                    ) : (
                      <Box color="label">Cisza</Box>
                    )}
                  </Table.Cell>
                  <Table.Cell collapsing>
                    <Button
                      icon={jukebox.shipwide ? 'volume-up' : 'volume-off'}
                      selected={jukebox.shipwide}
                      tooltip={
                        jukebox.shipwide
                          ? 'Wyłącz nadawanie na cały statek'
                          : 'Puść ten jukebox na cały statek'
                      }
                      tooltipPosition="left"
                      onClick={() => act('toggle', { ref: jukebox.ref })}
                    >
                      {jukebox.shipwide ? 'Nadaje' : 'Nadawaj'}
                    </Button>
                  </Table.Cell>
                </Table.Row>
              ))}
            </Table>
          )}
        </Section>
      </NtosWindow.Content>
    </NtosWindow>
  );
};
