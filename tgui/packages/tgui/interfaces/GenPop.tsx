// Adapted From NSV13
// AQ EDIT - tłumaczenie, kilka zarzutów naraz (czasy się sumują)

import { clamp, toFixed } from 'common/math';
import { Box, Button, ProgressBar, Section } from 'tgui-core/components';

import { useBackend, useSharedState } from '../backend';
import { Window } from '../layouts';

type Crime = {
  name: string;
  tooltip: string;
  colour: string;
  icon: string;
  sentence: number;
};

type Prisoner = {
  name: string;
  id: string;
  served_time: number;
  sentence: number;
  crime: string;
};

type Data = {
  allPrisoners: Prisoner[];
  canPrint: boolean;
  crime_list: Record<string, Crime[]>;
  desired_details: string;
  desired_name: string;
};

// Te same stałe co w code/modules/security/crimes.dm (decysekundy).
const PRESET_SHORT = 3000;
const PRESET_LONG = 9000;
const MAX_TIMER = 360000;

const formatSentence = (time: number) =>
  time >= MAX_TIMER ? 'dożywocie' : `${toFixed(time / 600, 1)} min`;

export const GenPop = (props) => {
  const { act, data } = useBackend<Data>();

  const { desired_details = '', crime_list = {} } = data;

  // Ręczna korekta czasu (strzałki), doliczana do sumy zarzutów.
  const [adjust, setAdjust] = useSharedState('adjust', 0);

  const [resistedMod, setResistedMod] = useSharedState('resisted', false);
  const [attemptedMod, setAttemptedMod] = useSharedState('attempted', false);
  const [elevatedMod, setElevatedMod] = useSharedState(
    'repeat_offender',
    false,
  );

  // Wybrane zarzuty (nazwy).
  const [selectedCrimes, setSelectedCrimes] = useSharedState<string[]>(
    'selectedCrimes',
    [],
  );

  // Pomijamy puste kategorie, żeby nie wywalić interfejsu.
  const categories = Object.keys(crime_list).filter(
    (category) => crime_list[category].length > 0,
  );

  const [crimeCategory, setCrimeCategory] = useSharedState<string | null>(
    'crimeCategory',
    categories.length > 0 ? categories[0] : null,
  );

  const sentenceOf = (name: string) => {
    for (const category of categories) {
      const crime = crime_list[category].find((c) => c.name === name);
      if (crime) {
        return crime.sentence;
      }
    }
    return 0;
  };

  const baseTime = selectedCrimes.reduce(
    (sum, name) => sum + sentenceOf(name),
    0,
  );

  // Ta sama reguła co calculate_sentence() w genpop.dm.
  const getProcessedTime = () => {
    let time = clamp(baseTime + adjust, 0, MAX_TIMER);
    if (attemptedMod) {
      time = time >= MAX_TIMER ? PRESET_LONG : time - PRESET_SHORT;
    }
    if (elevatedMod) {
      time = time >= PRESET_LONG ? MAX_TIMER : time + PRESET_SHORT;
    }
    if (resistedMod) {
      time *= 1.2;
    }
    return clamp(Math.round(time / 10) * 10, 0, MAX_TIMER);
  };

  const resetLocalState = () => {
    setSelectedCrimes([]);
    setAdjust(0);
    setResistedMod(false);
    setAttemptedMod(false);
    setElevatedMod(false);
  };

  const toggleCrime = (name: string) => {
    if (selectedCrimes.includes(name)) {
      setSelectedCrimes(selectedCrimes.filter((c) => c !== name));
    } else {
      setSelectedCrimes([...selectedCrimes, name]);
    }
  };

  const crimeText =
    selectedCrimes.length === 0
      ? 'brak zarzutów'
      : (attemptedMod ? 'Usiłowanie: ' : '') +
        selectedCrimes.join(', ') +
        (elevatedMod ? ' (recydywa)' : '') +
        (resistedMod ? ' (opór przy zatrzymaniu)' : '');

  const attemptedTooLow = attemptedMod && baseTime <= PRESET_SHORT;

  const adjustText =
    adjust === 0
      ? ''
      : ` (korekta ${adjust > 0 ? '+' : ''}${adjust / 600} min)`;

  return (
    <Window width={680} height={560} title="Interfejs zarządzania więźniami">
      <Window.Content scrollable>
        <Section
          title="Drukarka karty więźnia"
          buttons={
            <>
              <Button icon="id-card-alt" onClick={() => act('prisoner_name')}>
                {data.desired_name || 'Podaj imię więźnia'}
              </Button>
              <Button
                icon="print"
                tooltip={
                  attemptedTooLow
                    ? 'Usiłowanie wykroczenia karze się grzywną, nie odsiadką!'
                    : selectedCrimes.length === 0
                      ? 'Nie wybrano żadnego zarzutu.'
                      : !data.desired_name
                        ? 'Karta więźnia wymaga imienia.'
                        : null
                }
                color="good"
                disabled={
                  !data.canPrint ||
                  attemptedTooLow ||
                  selectedCrimes.length === 0 ||
                  !data.desired_name
                }
                onClick={() => {
                  act('print', {
                    crimes: selectedCrimes,
                    adjust: adjust,
                    attempted: attemptedMod,
                    elevated: elevatedMod,
                    resisted: resistedMod,
                  });
                  resetLocalState();
                }}
              >
                Wydrukuj kartę
              </Button>
            </>
          }
        >
          <Button
            icon="fast-backward"
            tooltip="-2 min"
            onClick={() => setAdjust(adjust - 1200)}
          />
          <Button
            icon="backward"
            tooltip="-1 min"
            onClick={() => setAdjust(adjust - 600)}
          />
          {' Wyrok: '}
          <b>{formatSentence(getProcessedTime())}</b>
          {adjustText}{' '}
          <Button
            icon="forward"
            tooltip="+1 min"
            onClick={() => setAdjust(adjust + 600)}
          />
          <Button
            icon="fast-forward"
            tooltip="+2 min"
            onClick={() => setAdjust(adjust + 1200)}
          />
          <Button icon="undo" onClick={resetLocalState}>
            Wyczyść
          </Button>
          <Box mt={1}>
            {categories.map((category) => (
              <Button
                key={category}
                icon={
                  crime_list[category][0].sentence >= MAX_TIMER
                    ? 'exclamation-triangle'
                    : 'hourglass-start'
                }
                color={crime_list[category][0].colour}
                selected={crimeCategory === category}
                onClick={() => setCrimeCategory(category)}
              >
                {category}
              </Button>
            ))}
          </Box>
        </Section>
        <Section title="Zarzuty (można wybrać kilka, czasy się sumują)">
          {(crimeCategory ? crime_list[crimeCategory] || [] : []).map(
            (crime) => (
              <Button
                key={crime.name}
                color={crime.colour}
                icon={crime.icon}
                tooltip={`${crime.tooltip} (${formatSentence(crime.sentence)})`}
                selected={selectedCrimes.includes(crime.name)}
                onClick={() => toggleCrime(crime.name)}
              >
                {crime.name}
              </Button>
            ),
          )}
        </Section>
        <Section title="Modyfikatory">
          <Button
            icon="hand-paper"
            color="orange"
            tooltip="-5 min, dożywocie spada do 15 min. Samo usiłowanie wykroczenia karze się grzywną."
            selected={attemptedMod}
            onClick={() => setAttemptedMod(!attemptedMod)}
          >
            Usiłowanie
          </Button>
          <Button
            icon="thumbs-down"
            color="orange"
            tooltip="+20% do całego wyroku."
            selected={resistedMod}
            onClick={() => setResistedMod(!resistedMod)}
          >
            Opór przy zatrzymaniu
          </Button>
          <Button
            icon="redo"
            color="bad"
            tooltip="Przy wyroku od 15 min dożywocie, poniżej +5 min."
            selected={elevatedMod}
            onClick={() => setElevatedMod(!elevatedMod)}
          >
            Recydywa
          </Button>
        </Section>
        <Section title="Podgląd">
          Więzień: {data.desired_name || 'nie podano imienia'} <br />
          Zarzuty: {crimeText} <br />
          Wyrok: {formatSentence(getProcessedTime())} <br />
          <Section
            title="Opis zdarzenia"
            buttons={
              <Button icon="pen" onClick={() => act('edit_details')}>
                Edytuj
              </Button>
            }
          >
            {desired_details}
          </Section>
        </Section>
        <Section title="Więźniowie">
          {(data.allPrisoners || []).map((prisoner) => (
            <Section
              key={prisoner.id}
              title={prisoner.name}
              buttons={
                <>
                  <Button
                    icon="backward"
                    tooltip="-1 min wyroku"
                    onClick={() =>
                      act('adjust_time', { adjust: -60, id: prisoner.id })
                    }
                  />
                  <Button
                    icon="forward"
                    tooltip="+1 min wyroku"
                    onClick={() =>
                      act('adjust_time', { adjust: 60, id: prisoner.id })
                    }
                  />
                  <Button
                    icon="check"
                    color="good"
                    tooltip="Wcześniejsze zwolnienie: karta od razu zalicza cały wyrok i dostaje dostęp do bramek wyjścia, a w kartotece status zmienia się na Discharged."
                    onClick={() => act('release', { id: prisoner.id })}
                  >
                    Zwolnij
                  </Button>
                  <Button
                    icon="running"
                    color="bad"
                    tooltip="Ucieczka: odsiedziany czas spada do zera, a zwolniona już karta traci dostęp i znowu liczy wyrok."
                    onClick={() => act('escaped', { id: prisoner.id })}
                  >
                    Uciekł
                  </Button>
                </>
              }
            >
              Osadzony za: {prisoner.crime} <br />
              <ProgressBar
                value={prisoner.served_time / prisoner.sentence}
                ranges={{
                  good: [0.99, Infinity],
                  average: [0.4, 0.99],
                  bad: [-Infinity, 0.4],
                }}
              >
                {toFixed(prisoner.served_time / 60)} min /{' '}
                {prisoner.sentence * 10 >= MAX_TIMER
                  ? 'dożywocie'
                  : `${toFixed(prisoner.sentence / 60)} min`}
              </ProgressBar>
            </Section>
          ))}
        </Section>
      </Window.Content>
    </Window>
  );
};
