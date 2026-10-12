// AQUILA - magnes na asteroidy (aquila/code/modules/mining/mineral_magnet_ui.dm)
import { Box, Button, NoticeBox, Section, Table } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Asteroid = {
  name: string;
  ref: string;
  ores: string[];
};

type Data = {
  cooldown: boolean;
  has_asteroid: boolean;
  asteroids: Asteroid[];
};

export const AsteroidMagnet = (_) => {
  const { act, data } = useBackend<Data>();
  const { cooldown, has_asteroid, asteroids = [] } = data;
  return (
    <Window width={440} height={420}>
      <Window.Content scrollable>
        {!!cooldown && (
          <NoticeBox>Obwody magnesu się ładują, poczekaj chwilę.</NoticeBox>
        )}
        {has_asteroid ? (
          <Section title="Asteroida w klatce">
            <Box mb={1}>
              Asteroida jest przyciągnięta. Zanim ją wypchniesz, upewnij się,
              że nikt nie został w klatce.
            </Box>
            <Button.Confirm
              fluid
              icon="meteor"
              color="bad"
              disabled={cooldown}
              confirmContent="Na pewno? Kliknij jeszcze raz"
              onClick={() => act('push')}
            >
              Wypchnij asteroidę
            </Button.Confirm>
          </Section>
        ) : (
          <Section title="Asteroidy w zasięgu">
            {asteroids.length === 0 && (
              <Box color="label">
                W pobliżu statku nie ma asteroid. Podleć bliżej któregoś pola.
              </Box>
            )}
            {asteroids.length > 0 && (
              <Table>
                <Table.Row header>
                  <Table.Cell>Asteroida</Table.Cell>
                  <Table.Cell>Skład rdzenia</Table.Cell>
                  <Table.Cell collapsing />
                </Table.Row>
                {asteroids.map((asteroid) => (
                  <Table.Row key={asteroid.ref} className="candystripe">
                    <Table.Cell>{asteroid.name}</Table.Cell>
                    <Table.Cell color="label">
                      {asteroid.ores.join(', ')}
                    </Table.Cell>
                    <Table.Cell collapsing>
                      <Button
                        icon="magnet"
                        disabled={cooldown}
                        onClick={() => act('pull', { ref: asteroid.ref })}
                      >
                        Przyciągnij
                      </Button>
                    </Table.Cell>
                  </Table.Row>
                ))}
              </Table>
            )}
          </Section>
        )}
      </Window.Content>
    </Window>
  );
};
