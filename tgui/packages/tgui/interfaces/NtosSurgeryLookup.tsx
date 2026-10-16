// AQUILA - program PDA „Operacje”: spis operacji z krokami i narzędziami
import { useState } from 'react';
import {
  Box,
  Button,
  Collapsible,
  Input,
  NoticeBox,
  Section,
  Stack,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { NtosWindow } from '../layouts';

type SurgeryTool = {
  name: string;
  chance: number;
};

type SurgeryStep = {
  name: string;
  tools: SurgeryTool[];
  time: number;
  repeatable: boolean;
  chems: string[];
  allChems: boolean;
};

type Surgery = {
  id: string;
  name: string;
  desc: string | null;
  locations: string[];
  targets: string[];
  bodypart: string;
  missingLimb: boolean;
  requiresTech: boolean;
  replacedBy: string | null;
  lying: boolean;
  selfOperable: boolean;
  ignoreClothes: boolean;
  steps: SurgeryStep[];
};

type Data = {
  surgeries: Surgery[];
};

export const NtosSurgeryLookup = (props) => {
  const { data } = useBackend<Data>();
  const surgeries = data.surgeries || [];
  const [query, setQuery] = useState('');
  const [location, setLocation] = useState<string | null>(null);

  const locations = Array.from(
    new Set(surgeries.flatMap((surgery) => surgery.locations)),
  ).sort((a, b) => a.localeCompare(b));

  const needle = query.trim().toLowerCase();
  const filtered = surgeries
    .filter((surgery) => !location || surgery.locations.includes(location))
    .filter(
      (surgery) =>
        !needle ||
        surgery.name.toLowerCase().includes(needle) ||
        (surgery.desc || '').toLowerCase().includes(needle) ||
        surgery.steps.some((step) =>
          step.tools.some((tool) => tool.name.toLowerCase().includes(needle)),
        ),
    )
    .sort((a, b) => a.name.localeCompare(b.name));

  return (
    <NtosWindow width={520} height={640}>
      <NtosWindow.Content scrollable>
        <Section>
          <Input
            fluid
            autoFocus
            placeholder="Szukaj operacji albo narzędzia…"
            value={query}
            onInput={(e, value) => setQuery(value)}
          />
          <Box mt={1}>
            <Button
              compact
              selected={location === null}
              onClick={() => setLocation(null)}
            >
              Wszędzie
            </Button>
            {locations.map((name) => (
              <Button
                compact
                key={name}
                selected={location === name}
                onClick={() => setLocation(location === name ? null : name)}
              >
                {name}
              </Button>
            ))}
          </Box>
        </Section>
        <Section title={`Operacje (${filtered.length})`}>
          {filtered.length === 0 && (
            <NoticeBox>Nie ma takiej operacji.</NoticeBox>
          )}
          {filtered.map((surgery) => (
            <SurgeryEntry key={surgery.id} surgery={surgery} />
          ))}
        </Section>
      </NtosWindow.Content>
    </NtosWindow>
  );
};

const SurgeryEntry = (props: { surgery: Surgery }) => {
  const { surgery } = props;
  const notes: string[] = [];
  if (surgery.requiresTech) {
    notes.push('wymaga zbadania technologii albo dysku z operacją');
  }
  if (surgery.replacedBy) {
    notes.push(`znika, gdy znasz: ${surgery.replacedBy}`);
  }
  if (surgery.bodypart !== 'dowolna') {
    notes.push(`kończyna ${surgery.bodypart}`);
  }
  if (surgery.missingLimb) {
    notes.push('na miejscu brakującej kończyny');
  }
  if (!surgery.lying) {
    notes.push('pacjent nie musi leżeć');
  }
  if (surgery.selfOperable) {
    notes.push('można zrobić samemu sobie');
  }
  if (surgery.ignoreClothes) {
    notes.push('nie trzeba zdejmować ubrania');
  }
  return (
    <Collapsible title={surgery.name}>
      <Box ml={1} mb={1}>
        {!!surgery.desc && <Box mb={1}>{surgery.desc}</Box>}
        <Box color="label">
          Miejsce: {surgery.locations.join(', ') || '—'} · Pacjenci:{' '}
          {surgery.targets.join(', ')}
        </Box>
        {notes.length > 0 && (
          <Box color="average" mt={0.5}>
            {notes.join(' · ')}
          </Box>
        )}
        <Box mt={1}>
          {surgery.steps.map((step, index) => (
            <SurgeryStepRow key={index} step={step} index={index + 1} />
          ))}
        </Box>
      </Box>
    </Collapsible>
  );
};

const SurgeryStepRow = (props: { step: SurgeryStep; index: number }) => {
  const { step, index } = props;
  const tools = [...step.tools].sort((a, b) => b.chance - a.chance);
  return (
    <Stack mb={0.5}>
      <Stack.Item width="1.5em" color="label" textAlign="right">
        {index}.
      </Stack.Item>
      <Stack.Item grow>
        <Box bold>
          {step.name}
          <Box inline color="label" ml={1} style={{ fontWeight: 'normal' }}>
            {step.time} s{step.repeatable && ' · powtarzalny'}
          </Box>
        </Box>
        <Box>
          {tools.map((tool, toolIndex) => (
            <Box
              inline
              key={tool.name}
              color={toolIndex === 0 ? 'good' : 'label'}
              bold={toolIndex === 0}
              mr={1}
            >
              {tool.name}
              {tool.chance < 100 && ` (${tool.chance}%)`}
              {toolIndex < tools.length - 1 && ','}
            </Box>
          ))}
        </Box>
        {step.chems.length > 0 && (
          <Box color="teal">
            We krwi pacjenta {step.allChems ? 'wszystkie' : 'jedno z'}:{' '}
            {step.chems.join(', ')}
          </Box>
        )}
      </Stack.Item>
    </Stack>
  );
};
