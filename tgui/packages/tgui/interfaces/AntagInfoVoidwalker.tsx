// AQUILA - okno roli wędrowca pustki (port z tgstation)
import { BlockQuote, LabeledList, Section, Stack } from 'tgui-core/components';

import { Window } from '../layouts';

const tipstyle = {
  color: 'white',
};

export const AntagInfoVoidwalker = (props) => {
  return (
    <Window width={660} height={660}>
      <Window.Content backgroundColor="#0d0d0d">
        <Stack fill>
          <Stack.Item width="50%">
            <Section fill>
              <Stack vertical fill>
                <Stack.Item fontSize="25px">Jesteś wędrowcem pustki</Stack.Item>
                <Stack.Item>
                  <BlockQuote>
                    Jesteś istotą z pustki między gwiazdami. Przywabiły cię
                    sygnały radiowe nadawane przez ten statek.
                  </BlockQuote>
                </Stack.Item>
                <Stack.Divider />
                <Stack.Item textColor="label">
                  <span style={tipstyle}>Przetrwaj:&ensp;</span>
                  Masz niezrównaną swobodę. Zostań w kosmosie, a nikt cię nie
                  zatrzyma. Przenikasz przez okna, więc trzymaj się blisko nich,
                  by zawsze mieć drogę ucieczki.
                  <br />
                  <br />
                  <span style={tipstyle}>Poluj:&ensp;</span>
                  Wybieraj nieuczciwe walki. Szukaj nieuważnych ofiar i uderzaj,
                  gdy się tego nie spodziewają.
                  <br />
                  <br />
                  <span style={tipstyle}>Porywaj:&ensp;</span>
                  Niepokój ogłusza i wyczerpuje ofiary. Powal je wysysającym
                  ciosem, zabierz w kosmos (albo na mgławicowe wymiociny) i
                  oświeć je.
                  <br />
                  <br />
                  <span style={tipstyle}>Zbieraj plony:&ensp;</span>
                  Nasi uczniowie regularnie wydalają naszą esencję. Dzięki niej
                  dotrzemy tam, gdzie inaczej byśmy nie mogli, ale pochłaniamy
                  ją z powrotem, gdy jej użyjemy. (Możesz zanurkować w
                  mgławicowych wymiocinach.)
                </Stack.Item>
              </Stack>
            </Section>
          </Stack.Item>
          <Stack.Item width="50%">
            <Section fill title="Moce">
              <LabeledList>
                <LabeledList.Item label="Nurkowanie">
                  Z kosmosu możesz zanurkować pod statek: wpadnij na ścianę lub
                  inną przytwierdzoną rzecz. Wynurzysz się tylko w kosmosie albo
                  na mgławicowych wymiocinach. Używaj tego, by polować i
                  docierać do odciętych fragmentów kosmosu.
                </LabeledList.Item>
                <LabeledList.Item label="Wysysający cios">
                  Wysysasz powietrze prosto z płuc i szybko powalasz nawet
                  najsilniejszych. Jeśli się opierają, prawy klik zadaje zwykłe
                  obrażenia. Twoje ręce poza tym nie są zbyt zręczne i nadają
                  się tylko do noszenia rzeczy.
                </LabeledList.Item>
                <LabeledList.Item label="Kosmiczna fizjologia">
                  Naturalny kamuflaż czyni cię niewidzialnym w kosmosie, gdzie
                  też goją się twoje rany. Swobodnie przenikasz przez szkło, ale
                  krata pod prądem cię zatrzyma.
                </LabeledList.Item>
                <LabeledList.Item label="Niepokój">
                  Wpatruj się w ofiarę, która cię widzi, by ją ogłuszyć i
                  osłabić. Pamiętaj, że w ten sposób zdradzasz swoją obecność.
                </LabeledList.Item>
                <LabeledList.Item label="Kosmiczny zryw">
                  Mały zasięg ataku i znikome obrażenia, ale świetny do szybkich
                  ucieczek i zmiany pozycji.
                </LabeledList.Item>
                <LabeledList.Item label="Rozrost">
                  Każda udzielona lekcja dodaje nam sił. Prawym klikiem możemy
                  zamieniać ściany w szkło, by sięgać jeszcze dalej.
                </LabeledList.Item>
              </LabeledList>
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
