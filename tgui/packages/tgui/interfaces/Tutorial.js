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
        Wchodzenie na stół - Przeciągnięcie swojej postaci na stół  <br /><br />
        Rozbieranie kogoś - Przeciągnięcie czyjejś postaci na swoją <br /><br />
        Aby się ugasić, stawiać opór lub wyswobodzić się wystarczy wcisnąć przycisk <i>RESIST</i><br /><br />
        Aby zdjąć plecak lub inne obiekty w które można coś włożyć, należy przeciągnąć przedmiot do pustej ręki. <br /><br />
        Odpięcie się od pasów - Wciśnięcie przycisku <i>BUCKLED</i> w prawym górnym rogu ekranu <br /><br />
        <img src="https://nsv.beestation13.com/mediawiki2/images/f/ff/Hud-target.gif" /> Kliknięcie na określone części pozwala na wybranie jako celu określonej części ciała <br /><br />
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
        Podstawową formą interakcji w Space Station 13 jest kliknięcie w coś. Jednak to co wydarzy się po kliknięciu, zależy od tego jaką mamy intencje. W tym wprowadzeniu wyjaśnione zostaną różnice między 4 dostępnymi intencjami.<br /><br />
        Pomoc (kolor zielony) <img src="https://nsv.beestation13.com/mediawiki2/images/1/1e/Intent_Help.png" /> - Podstawowa i pozytywna intencja. Kliknięcie drugiej postaci nie wyrządzi jej szkód. Możemy też swobodnie przechodzić przez inne postaci. Powinna zawsze być domyślnie wybrana <br /><br />
        Krzywda (kolor czerwony) <img src="https://nsv.beestation13.com/mediawiki2/images/c/c4/Intent_Harm.png" /> - Wybierana wtedy, gdy chcemy zaatakować postać. Kliknięcie w kogoś zada mu obrażenia. Sprawia też, że przez postać nie będzie dało się przejść, zamiast tego będziemy ją przesuwać.<br /><br />
        Chwyt (kolor żółty) <img src="https://nsv.beestation13.com/mediawiki2/images/2/2c/Intent_Grab.png" /> - jedno kliknięcie na postać złapie ją i będziemy mogli ją ciągnąć, tak samo jak w przypadku skrótu klawiszowego CTRL + LPM. Kliknięcie drugi raz złapie postać agresywnie. Kliknięcie trzeci raz założy jej chwyt. Ostatnie, czwarte kliknięcie zacznie ją dusić. Postać puszczamy klawiszem H. <br /><br />
        Pchnięcie (kolor niebieski)  <img src="https://nsv.beestation13.com/mediawiki2/images/3/37/Intent_Disarm.png" />- używane by kogoś popchnąć. Jeśli popchniemy kogoś na inny obiekt, to upuści ona trzymany przedmiot i przewróci się. W ten sposób można kogoś rozbroić <br /><br />
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
        Najczęstszą przyczyną śmierci nowych graczy jest uduszenie się, wystawienie na działanie przestrzeni kosmicznej lub spalenie. Poniżej przedstawiony zostanie krok po kroku sposób radzenia sobie z każdym zagrożenie <br /><br />
        Duszenie się - Informowane za pomocą ikonki <img src="https://nsv.beestation13.com/mediawiki2/images/5/5d/Hud-oxy.gif" />. Każdy załogant jest wyposażony w zestaw do oddychania. Kliknij w plecak. Następnie otwórz pudełko, które się tam znajduje (ALT + LPM). Wyciągnij maskę <img src="https://nsv.beestation13.com/mediawiki2/images/0/00/BreathMask.png" /> i załóż ją na twarz <img src="https://nsv.beestation13.com/mediawiki2/images/9/9c/Hud-Mask.png" />. Następnie wyciągnij butlę z tlenem <img src="https://nsv.beestation13.com/mediawiki2/images/6/68/AirTank.png" /> i włóż ją do kieszeni. Teraz wystarczy tylko włączyć aparaturę klikając w przycisk u góry ekranu <img src="https://nsv.beestation13.com/mediawiki2/images/8/8c/Gmaskinternalsicon.gif" /> <br /><br />
        Działanie przestrzeni kosmicznej - tutaj umiera się zwykle od niskiej temperatury <img src="https://nsv.beestation13.com/mediawiki2/images/a/a3/Hud-temp.gif" /> i ciśnienia <img src="https://nsv.beestation13.com/mediawiki2/images/0/0c/Hud-pressure.gif" /> zadającego z czasem obrażenia. Rozwiązaniem jest wyciągnięcie z tego samego pudełka co tlen skafandra kosminczego. Hełm zakłada się na głowe. Skafander należy w pierwszej kolejności rozwinać za pomocą aktywacji w ręce (klawisz Z) i założyć w miejsce skafandrów <br /><br />
        Pożar - <img src="https://nsv.beestation13.com/mediawiki2/images/d/de/Hud-fire.png" /> należy opuścić płonący obszar i zacząć turlać się w celu ugaszenia płomieni (kliknięcie w przycisk RESIST) <br /><br />
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
        Nie musisz być lekarzem, by uratować swoje lub cudze życie. Poniżej przedstawione zostaną najpopularniejsze scenariusze niewymagające zaawansowanej wiedzy. <br /><br />
        Zostałeś ranny - należy wybrać obszar ciała, który jest uszkodzony, a następnie trzymając plastry <img src="https://nsv.beestation13.com/mediawiki2/images/0/0d/Bpack.png" /> lub maść <img src="https://nsv.beestation13.com/mediawiki2/images/0/09/Oint.png" /> kliknąć na swoją postać. Plastry leczą obrażenia od uderzeń, cięć, postrzałów i ciśnienia. Maść jest na oparzenia od wysokich temperatur. Leczenie kogoś wygląda tak samo. Wybiera się obszar ciała i klika na cudzą postać. <br /><br />
        Znajdujesz kogoś, kto leży - SHIFT + kliknięcie w niego, by dowiedzieć się czy żyje. Jeśli wyświetliła się informacja o tym, że nie żyje, zanieś go do najbliższego lekarza. Lepiej unikać ciągnięcia kogoś po ziemi, ponieważ traci on wtedy krew.  <br /><br />
        Chwyć poszkodowanego agresywnie (Intencja chwytu <img src="https://nsv.beestation13.com/mediawiki2/images/2/2c/Intent_Grab.png" /> i kliknięcie kogoś dwa razy) a następnie przeciągnąć jego postać na swoją postać. W ten sposób weźmie się go na plecy. Z kolei jeśli osoba żyje, to w pierwszej kolejności należy użyć medipena <img src="https://nsv.beestation13.com/mediawiki2/images/b/b7/MediPen.png" /> dostępnego w pudełku przetrwania w naszym plecaku. <br /><br />
        Następnie można przystąpić do resuscytacji (Intencja pomocy <img src="https://nsv.beestation13.com/mediawiki2/images/1/1e/Intent_Help.png" /> i klikanie w postać po wybraniu klatki piersiowej). Jeśli to nie pomaga, zanieść go do lekarza <br /><br />
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
