import { useState } from 'react';
import {
  Box,
  Button,
  Collapsible,
  Input,
  LabeledList,
  NoticeBox,
  Section,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { Grid } from '../components';
import { Window } from '../layouts';

type Data = {
  beaker_empty: any;
  blood: any;
  has_beaker: any;
  has_blood: any;
  is_ready: any;
  resistances: any;
  viruses: any;
  symptom_catalog: CatalogSymptom[];
};

type CatalogSymptom = {
  id: string;
  name: string;
  desc: string;
  threshold_desc: string;
  level: number;
  severity: number;
  stealth: number;
  resistance: number;
  stage_speed: number;
  transmission: number;
  natural: boolean;
  sources: string[];
};

export const PandemicBeakerDisplay = (props) => {
  const { act, data } = useBackend<Data>();

  const { has_beaker, beaker_empty, has_blood, blood } = data;

  const cant_empty = !has_beaker || beaker_empty;

  return (
    <Section
      title="Beaker"
      buttons={
        <>
          <Button
            icon="times"
            content="Empty and Eject"
            color="bad"
            disabled={cant_empty}
            onClick={() => act('empty_eject_beaker')}
          />
          <Button
            icon="trash"
            content="Empty"
            disabled={cant_empty}
            onClick={() => act('empty_beaker')}
          />
          <Button
            icon="eject"
            content="Eject"
            disabled={!has_beaker}
            onClick={() => act('eject_beaker')}
          />
        </>
      }
    >
      {has_beaker ? (
        !beaker_empty ? (
          has_blood ? (
            <LabeledList>
              <LabeledList.Item label="Blood DNA">
                {(blood && blood.dna) || 'Unknown'}
              </LabeledList.Item>
              <LabeledList.Item label="Blood Type">
                {(blood && blood.type) || 'Unknown'}
              </LabeledList.Item>
            </LabeledList>
          ) : (
            <Box color="bad">No blood detected</Box>
          )
        ) : (
          <Box color="bad">Beaker is empty</Box>
        )
      ) : (
        <NoticeBox>No beaker loaded</NoticeBox>
      )}
    </Section>
  );
};

export const PandemicDiseaseDisplay = (props) => {
  const { act, data } = useBackend<Data>();

  const { is_ready } = data;

  const viruses = data.viruses || [];

  return viruses.map((virus) => {
    const symptoms = virus.symptoms || [];
    return (
      <Section
        key={virus.name}
        title={
          virus.can_rename ? (
            <Input
              value={virus.name}
              onChange={(e, value) =>
                act('rename_disease', {
                  index: virus.index,
                  name: value,
                })
              }
            />
          ) : (
            virus.name
          )
        }
        buttons={
          <Button
            icon="flask"
            content="Create culture bottle"
            disabled={!is_ready}
            onClick={() =>
              act('create_culture_bottle', {
                index: virus.index,
              })
            }
          />
        }
      >
        <Grid>
          <Grid.Column>{virus.description}</Grid.Column>
          <Grid.Column>
            <LabeledList>
              <LabeledList.Item label="Agent">{virus.agent}</LabeledList.Item>
              <LabeledList.Item label="Spread">{virus.spread}</LabeledList.Item>
              <LabeledList.Item label="Danger">{virus.danger}</LabeledList.Item>
              <LabeledList.Item label="Possible Cure">
                {virus.cure}
              </LabeledList.Item>
            </LabeledList>
          </Grid.Column>
        </Grid>
        {!!virus.is_adv && (
          <>
            <Section title="Statistics">
              <Grid>
                <Grid.Column>
                  <LabeledList>
                    <LabeledList.Item label="Resistance">
                      {virus.resistance}
                    </LabeledList.Item>
                    <LabeledList.Item label="Stealth">
                      {virus.stealth}
                    </LabeledList.Item>
                  </LabeledList>
                </Grid.Column>
                <Grid.Column>
                  <LabeledList>
                    <LabeledList.Item label="Stage speed">
                      {virus.stage_speed}
                    </LabeledList.Item>
                    <LabeledList.Item label="Transmissibility">
                      {virus.transmission}
                    </LabeledList.Item>
                    <LabeledList.Item label="Severity">
                      {virus.symptom_severity}
                    </LabeledList.Item>
                  </LabeledList>
                </Grid.Column>
              </Grid>
            </Section>
            <Section title="Symptoms">
              {symptoms.map((symptom) => (
                <Collapsible key={symptom.name} title={symptom.name}>
                  <Section>
                    <PandemicSymptomDisplay symptom={symptom} />
                  </Section>
                </Collapsible>
              ))}
            </Section>
          </>
        )}
      </Section>
    );
  });
};

export const PandemicSymptomDisplay = (props) => {
  const { symptom } = props;
  const {
    name,
    desc,
    stealth,
    resistance,
    stage_speed,
    transmission,
    severity,
    level,
    neutered,
  } = symptom;

  // TODO: Needs proper porting of DM code from tg upstream.
  const thresholds_unsafe = symptom.threshold_desc;

  return (
    <Section
      title={name}
      buttons={
        !!neutered && (
          <Box bold color="bad">
            Neutered
          </Box>
        )
      }
    >
      <Grid>
        <Grid.Column size={2}>{desc}</Grid.Column>
        <Grid.Column>
          <LabeledList>
            <LabeledList.Item label="Level">{level}</LabeledList.Item>
            <LabeledList.Item label="Resistance">{resistance}</LabeledList.Item>
            <LabeledList.Item label="Stealth">{stealth}</LabeledList.Item>
            <LabeledList.Item label="Stage Speed">
              {stage_speed}
            </LabeledList.Item>
            <LabeledList.Item label="Transmission">
              {transmission}
            </LabeledList.Item>
            <LabeledList.Item label="Severity">{severity}</LabeledList.Item>
          </LabeledList>
        </Grid.Column>
      </Grid>
      {thresholds_unsafe && (
        <Section title="Thresholds">
          <div
            // eslint-disable-next-line react/no-danger
            dangerouslySetInnerHTML={{
              __html: thresholds_unsafe,
            }}
          />
        </Section>
      )}
    </Section>
  );
};

export const PandemicAntibodyDisplay = (props) => {
  const { act, data } = useBackend<Data>();

  const resistances = data.resistances || [];

  return (
    <Section title="Antibodies">
      {resistances.length > 0 ? (
        <LabeledList>
          {resistances.map((resistance) => (
            <LabeledList.Item key={resistance.name} label={resistance.name}>
              <Button
                icon="eye-dropper"
                content="Create vaccine bottle"
                disabled={!data.is_ready}
                onClick={() =>
                  act('create_vaccine_bottle', {
                    index: resistance.id,
                  })
                }
              />
            </LabeledList.Item>
          ))}
        </LabeledList>
      ) : (
        <Box bold color="bad" mt={1}>
          No antibodies detected.
        </Box>
      )}
    </Section>
  );
};

// AQUILA - lista wszystkich symptomów z wyszukiwarką i chemikaliami, które je losują
export const PandemicSymptomCatalog = (props) => {
  const { data } = useBackend<Data>();
  const [open, setOpen] = useState(false);
  const [query, setQuery] = useState('');
  const [level, setLevel] = useState<number | null>(null);
  const symptoms = data.symptom_catalog || [];
  const levels = Array.from(new Set(symptoms.map((s) => s.level))).sort(
    (a, b) => a - b,
  );
  const needle = query.trim().toLowerCase();
  const shown = symptoms
    .filter((s) => level === null || s.level === level)
    .filter(
      (s) =>
        !needle ||
        s.name.toLowerCase().includes(needle) ||
        (s.desc || '').toLowerCase().includes(needle),
    )
    .sort((a, b) => a.level - b.level || a.name.localeCompare(b.name));

  return (
    <Section
      title="Lista symptomów"
      buttons={
        <Button
          icon={open ? 'chevron-up' : 'search'}
          onClick={() => setOpen(!open)}
        >
          {open ? 'Schowaj' : 'Pokaż'}
        </Button>
      }
    >
      {open && (
        <>
          <Input
            fluid
            autoFocus
            placeholder="Szukaj symptomu…"
            value={query}
            onInput={(e, value) => setQuery(value)}
          />
          <Box mt={1} mb={1}>
            Poziom:{' '}
            <Button
              compact
              selected={level === null}
              onClick={() => setLevel(null)}
            >
              Wszystkie
            </Button>
            {levels.map((l) => (
              <Button
                compact
                key={l}
                selected={level === l}
                onClick={() => setLevel(level === l ? null : l)}
              >
                {l}
              </Button>
            ))}
          </Box>
          {shown.length === 0 && (
            <NoticeBox>Nie ma takiego symptomu.</NoticeBox>
          )}
          {shown.map((symptom) => (
            <Collapsible
              key={symptom.id}
              title={`${symptom.name} (poziom ${symptom.level})`}
            >
              <Box color="label" mb={1}>
                {symptom.natural
                  ? symptom.sources.length > 0
                    ? `Wylosujesz go, dodając do krwi z wirusem: ${symptom.sources.join(', ')}.`
                    : 'Żaden odczynnik nie losuje tego poziomu.'
                  : 'Nie losuje się chemikaliami.'}
              </Box>
              <PandemicSymptomDisplay symptom={symptom} />
            </Collapsible>
          ))}
        </>
      )}
    </Section>
  );
};

export const Pandemic = (props) => {
  const { data } = useBackend<Data>();

  return (
    <Window width={520} height={550}>
      <Window.Content scrollable>
        <PandemicBeakerDisplay />
        {!!data.has_blood && (
          <>
            <PandemicDiseaseDisplay />
            <PandemicAntibodyDisplay />
          </>
        )}
        <PandemicSymptomCatalog />
      </Window.Content>
    </Window>
  );
};
