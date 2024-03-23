import { useBackend, useLocalState } from '../backend';
import { Box, Button, Grid, LabeledList, ProgressBar, Section, Tabs } from '../components';
import { Window } from '../layouts';

export const Tutorial = (props, context) => {
  // const { act, data };
  const [tab, setTab] = useLocalState(context, 'tab', 'Sterowanie');
  return (
    <Window
      width={1280}
      height={1024}>
      <Window.Content>
        <Section title={(
          <Box
            inline
            color={'good'}>
            {"Samouczek"}
          </Box>
        )} />
        <div className="TutorialLeft">
          <Section
            height="90%"
            overflowY="scroll">
            <Tabs>
              <Tabs.Tab
                onClick={() => setTab('Sterowanie')}>
                Sterowanie
              </Tabs.Tab>
              <Tabs.Tab
                onClick={() => setTab('Podstawy')}>
                Podstawy
              </Tabs.Tab>
              <Tabs.Tab
                onClick={() => setTab('Intents')}>
                System Zamiaru
              </Tabs.Tab>
              <Tabs.Tab
                onClick={() => setTab('Przetrwanie')}>
                Przetrwanie część pierwsza
              </Tabs.Tab>
              <Tabs.Tab
                onClick={() => setTab('Przetrwanie2')}>
                Przetrwanie część druga
              </Tabs.Tab>
              <Tabs.Tab
                onClick={() => setTab('Antagonists')}>
                Antagoniści
              </Tabs.Tab>
              <Tabs.Tab
                onClick={() => setTab('Next')}>
                Co Dalej?
              </Tabs.Tab>
            </Tabs>
          </Section>
        </div>
        {tab === 'Sterowanie' && (
          <Sterowanie />
        )}
        {tab === 'Podstawy' && (
          <Podstawy />
        )}
        {tab === 'Intents' && (
          <Intents />
        )}
        {tab === 'Przetrwanie' && (
          <Przetrwanie />
        )}
        {tab === 'Przetrwanie2' && (
          <Przetrwanie2 />
        )}
        {tab === 'Antagonists' && (
          <Antagonists />
        )}
        {tab === 'Next' && (
          <Next />
        )}
      </Window.Content>
    </Window>
  );
};




const Sterowanie = () => {
  return (
    <Section
      title="Sterowanie"
      overflowY="scroll">
      <b>
        WASD - Poruszanie się<br /><br />
        1234 - Zmiana Zamiaru (1 - Pomoc, 2 - Rozbrojenie, 3 - Chwyt, 4 - Przemoc)<br /><br />
        LPM (Lewy przycisk myszy) - Interakcja z otoczeniem<br /><br />
        PPM (Prawy przycisk myszy) - Zaawansowana Interakcja z otoczeniem (Menu rozwijania przedmiotów na naciśniętej płytce)<br /><br />
        X/ŚPM (Środkowy przycisk myszy) - Zmiana ręki<br /><br />
        T - Mówienie (Napisz przed tekstem ; by napisać na radiu)<br /><br />
        Y - Mówienie na radiu <br /><br />
        O - Mówienie na OOC <br /><br />
        L - Mówienie na LOOC (widzą tylko osoby wokół ciebie) <br /><br />
        M - Pisanie co robi twoja postać (RP) <br /><br />
        E - Zakładanie przedmiotu które obecnie jest trzymane w ręku<br /><br />
        Z - Aktywacja/Interakcja z przedmiotem obecnie trzymanym w ręku (Np: Wyjęcie magazynka z pistoletu)<br /><br />
        Q - Położenie przedmiotu obecnie trzymanego na podłogę<br /><br />
        R - Aktywacja trybu rzucania, Wciśnij jeszcze raz R by wyłączyć tryb rzucania, lub wciśnij LPM by rzucić przedmiot tam gdzie wskazuje twój kursor<br /><br />
        H - Przerwanie ciągnięcia
        V - Położenie się na ziemi
        G - Podanie komuś przedmiotu (Nie jest natychmiastowe, osoba któej podawany jest przedmiot musi go zaakceptować)
        <i>
          Zaawansowane Kombinacje
        </i><br /><br />
        CTRL + WASD - Zmiana orientacji<br /><br />
        CTRL + LPM - Chwycenie obiektu lub istoty którą można ciągnąć<br /><br />
        SHIFT + LPM - Sprawdzenie przedmiotu/obiektu/istoty<br /><br />
        SHIFT + ŚPM - Wskazanie na dany obiekt/płytkę/isotę/przedmiot<br /><br />
        ALT + LPM - Otworzenie pojemnika/Pokazanie wszystkich przedmiotów znajdujących się na wciśniętej płytce <br /><br />
      </b>
    </Section>
  );
};

const Podstawy = () => {
  return (
    <Section
      title="Podstawy"
      overflowY="scroll">
      <b>
        TBA
      </b>
    </Section>
  );
};

const Intents = () => {
  return (
    <Section
      title="System Zamiaru"
      overflowY="scroll">
      <b>
        TBA
      </b>
    </Section>
  );
};

const Przetrwanie = () => {
  return (
    <Section
      title="Podstawy Przetrwania 1/2"
      overflowY="scroll">
      <b>
        TBA
      </b>
    </Section>
  );
};

const Przetrwanie2 = () => {
  return (
    <Section
      title="Podstawy Przetrwania 2/2"
      overflowY="scroll">
      <b>
        TBA
      </b>
    </Section>
  );
};

const Antagonists = () => {
  return (
    <Section
      title="Antagoniści"
      overflowY="scroll">
      <b>
        Poradnik dla początkujących zdrajców co nie wiedzą jak się odpala uplinka (miejsce gdzie się kupuje fajne rzeczy)<br /><br />
        Wyciągnij PDA<img src="https://nsv.beestation13.com/mediawiki2/images/2/27/Normalpda.png" />- Włącz PDA - Direct Messenger - Set Ringtone - Wklep kod który Ci został podany na samym starcie.<br /><br />
        Nie zapomnij o zamknięciu uplinka gdy z nim skończysz, bo inaczej ochrona może ci zrobić jajoskręt<br /><br />
      </b>
    </Section>
  );
};

const Next = () => {
  return (
    <Section
      title="Co Dalej?"
      overflowY="scroll">
      <b>
        <a href="https://discord.com/channels/709306010912686080/819285665258405928">Na tym kanale znajdziesz pomoc dla twego problemu, Nie bój się pytać innych graczy</a><br /><br />
        <a href="https://nsv.beestation13.com/wiki/Main_Page">Link do angielskiej wikipedii kodbazy naszego serwera</a><br /><br />
        <a href="https://wiki.spacestation13.pl/Strona_g%C5%82%C3%B3wna">Link do naszej wikipedii</a><br /><br />
      </b>
    </Section>
  );
};

/*
tabs.map(tab => (
  <Table.Cell
    key={tab}
    collapsing>
    <Button
      key={tab}
      fluid
      content={tab}
      onClick={() => setSelectedTab(tab)} />
  </Table.Cell>
))}
*/


/*
        {product.img ? (
          <img
            src={`data:image/jpeg;base64,${product.img}`}
            style={{
              'vertical-align': 'middle',
              'horizontal-align': 'middle',
            }} />
        ) : (
          <span
            className={classes([
              'vending32x32',
              product.path,
            ])}
            style={{
              'vertical-align': 'middle',
              'horizontal-align': 'middle',
            }} />
        )}

*/
