// AQUILA - okno roli wędrowca pustki (port z tgstation)
import { BlockQuote, Box, Section, Stack } from 'tgui-core/components';

import { Window } from '../layouts';

const tipstyle = {
  color: 'white',
};

type Power = {
  name: string;
  text: string;
};

const POWERS: Power[] = [
  {
    name: 'Nurkowanie',
    text: 'Z kosmosu możesz zanurkować pod statek: wpadnij na ścianę lub inną przytwierdzoną rzecz. Pod pokładem przechodzisz też między piętrami (w górę i w dół). Wynurzysz się tylko w kosmosie albo na mgławicowych wymiocinach.',
  },
  {
    name: 'Wysysający cios',
    text: 'Wysysasz powietrze prosto z płuc i szybko powalasz nawet najsilniejszych. Jeśli się opierają, prawy klik zadaje zwykłe obrażenia. Ręce nadają się tylko do noszenia rzeczy.',
  },
  {
    name: 'Kosmiczna fizjologia',
    text: 'W kosmosie jesteś niewidzialny i goją się twoje rany. Swobodnie przenikasz przez szkło, ale krata pod prądem cię zatrzyma.',
  },
  {
    name: 'Niepokój',
    text: 'Wpatruj się w ofiarę, która cię widzi, by ją ogłuszyć i osłabić. W ten sposób zdradzasz swoją obecność.',
  },
  {
    name: 'Kosmiczny zryw',
    text: 'Mały zasięg ataku i znikome obrażenia, ale świetny do szybkich ucieczek i zmiany pozycji.',
  },
  {
    name: 'Rozrost',
    text: 'Każda udzielona lekcja dodaje nam sił. Prawym klikiem możemy zamieniać ściany w szkło, by sięgać jeszcze dalej.',
  },
];

export const AntagInfoVoidwalker = (props) => {
  return (
    <Window width={720} height={620}>
      <Window.Content backgroundColor="#0d0d0d">
        <Stack fill>
          <Stack.Item width="50%">
            <Section fill scrollable>
              <Stack vertical>
                <Stack.Item fontSize="22px">Jesteś wędrowcem pustki</Stack.Item>
                <Stack.Item>
                  <BlockQuote>
                    Jesteś istotą z pustki między gwiazdami. Przywabiły cię
                    sygnały radiowe nadawane przez ten statek.
                  </BlockQuote>
                </Stack.Item>
                <Stack.Divider />
                <Stack.Item textColor="label">
                  <span style={tipstyle}>Przetrwaj:&ensp;</span>
                  Zostań w kosmosie, a nikt cię nie zatrzyma. Przenikasz przez
                  okna, więc trzymaj się blisko nich, by zawsze mieć drogę
                  ucieczki.
                  <br />
                  <br />
                  <span style={tipstyle}>Poluj:&ensp;</span>
                  Wybieraj nieuczciwe walki. Uderzaj w nieuważnych, gdy się tego
                  nie spodziewają.
                  <br />
                  <br />
                  <span style={tipstyle}>Porywaj:&ensp;</span>
                  Powal ofiarę wysysającym ciosem, zabierz ją w kosmos (albo na
                  mgławicowe wymiociny) i oświeć ją.
                  <br />
                  <br />
                  <span style={tipstyle}>Zbieraj plony:&ensp;</span>
                  Oświeceni wymiotują mgławicą. Z tych wymiocin możesz się
                  wynurzyć i na nich porywać, a podczas nurkowania skakać między
                  nimi.
                </Stack.Item>
              </Stack>
            </Section>
          </Stack.Item>
          <Stack.Item width="50%">
            <Section fill scrollable title="Moce">
              <Stack vertical>
                {POWERS.map((power) => (
                  <Stack.Item key={power.name}>
                    <Box bold color="#c48cff">
                      {power.name}
                    </Box>
                    <Box color="label">{power.text}</Box>
                  </Stack.Item>
                ))}
              </Stack>
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
