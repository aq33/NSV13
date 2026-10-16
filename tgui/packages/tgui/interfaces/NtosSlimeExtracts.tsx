// AQUILA - program PDA „Ekstrakty”: co daje każdy ekstrakt szlamu i czym go aktywować
import { useState } from 'react';
import {
  Box,
  Collapsible,
  Input,
  NoticeBox,
  Section,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { NtosWindow } from '../layouts';
import { RecipeReagent } from './common/RecipeLookup';

type ExtractReaction = {
  id: string;
  name: string;
  reagents: RecipeReagent[];
  results: RecipeReagent[];
};

type Extract = {
  id: string;
  name: string;
  reactions: ExtractReaction[];
};

type Data = {
  extracts: Extract[];
};

const listReagents = (reagents: RecipeReagent[]) =>
  reagents.map((r) => `${r.amount}× ${r.name}`).join(' + ');

export const NtosSlimeExtracts = (props) => {
  const { data } = useBackend<Data>();
  const extracts = [...(data.extracts || [])].sort((a, b) =>
    a.name.localeCompare(b.name),
  );
  const [query, setQuery] = useState('');
  const needle = query.trim().toLowerCase();

  const reactionMatches = (reaction: ExtractReaction) =>
    reaction.name.toLowerCase().includes(needle) ||
    reaction.reagents.some((r) => r.name.toLowerCase().includes(needle)) ||
    reaction.results.some((r) => r.name.toLowerCase().includes(needle));

  const shown = extracts
    .map((extract) => ({
      ...extract,
      reactions:
        !needle || extract.name.toLowerCase().includes(needle)
          ? extract.reactions
          : extract.reactions.filter(reactionMatches),
    }))
    .filter((extract) => extract.reactions.length > 0);

  return (
    <NtosWindow width={480} height={600}>
      <NtosWindow.Content scrollable>
        <Section>
          <Input
            fluid
            autoFocus
            placeholder="Kolor ekstraktu, odczynnik albo efekt…"
            value={query}
            onInput={(e, value) => setQuery(value)}
          />
          <Box color="label" mt={1}>
            Ekstrakt aktywujesz, wstrzykując do niego odczynnik strzykawką.
            Zwykły ekstrakt działa raz, wzmacniacz (enhancer) dodaje mu użycia.
          </Box>
        </Section>
        {shown.length === 0 && <NoticeBox>Nic nie znaleziono.</NoticeBox>}
        {shown.map((extract) => (
          <Collapsible
            key={extract.id}
            title={`${extract.name} (${extract.reactions.length})`}
            open={!!needle}
          >
            <Box ml={1} mb={1}>
              {extract.reactions.map((reaction) => (
                <Box key={reaction.id} mb={0.5}>
                  <Box inline bold color="good" mr={1}>
                    {listReagents(reaction.reagents)}
                  </Box>
                  → {reaction.name}
                  {reaction.results.length > 0 && (
                    <Box inline color="label" ml={1}>
                      ({listReagents(reaction.results)})
                    </Box>
                  )}
                </Box>
              ))}
            </Box>
          </Collapsible>
        ))}
      </NtosWindow.Content>
    </NtosWindow>
  );
};
