// AQUILA - program PDA „Książka kucharska”
import { useState } from 'react';
import {
  Box,
  Button,
  Input,
  NoticeBox,
  Section,
  Stack,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { NtosWindow } from '../layouts';

type Ingredient = {
  name: string;
  amount: number;
  reagent: boolean;
};

type CookRecipe = {
  id: string;
  name: string;
  method: string;
  ingredients: Ingredient[];
  tools: string[];
  category: string;
  learned: boolean;
  amount?: number;
};

type Data = {
  recipes: CookRecipe[];
};

const MAX_SHOWN = 40;

type SearchMode = 'dish' | 'ingredient';

export const NtosCookbook = (props) => {
  const { data } = useBackend<Data>();
  const recipes = data.recipes || [];
  const [query, setQuery] = useState('');
  const [mode, setMode] = useState<SearchMode>('dish');
  const [method, setMethod] = useState<string | null>(null);

  const methods = Array.from(new Set(recipes.map((r) => r.method))).sort(
    (a, b) => a.localeCompare(b),
  );
  const makeable = new Set(recipes.map((r) => r.name.toLowerCase()));

  const needle = query.trim().toLowerCase();
  const filtered = recipes
    .filter((r) => !method || r.method === method)
    .filter((r) => {
      if (!needle) {
        return !!method;
      }
      if (mode === 'ingredient') {
        return r.ingredients.some((i) => i.name.toLowerCase().includes(needle));
      }
      return r.name.toLowerCase().includes(needle);
    })
    .sort((a, b) => a.name.localeCompare(b.name));

  const searchFor = (name: string) => {
    setMode('dish');
    setMethod(null);
    setQuery(name);
  };

  return (
    <NtosWindow width={500} height={620}>
      <NtosWindow.Content scrollable>
        <Section>
          <Stack>
            <Stack.Item grow>
              <Input
                fluid
                autoFocus
                placeholder={
                  mode === 'dish' ? 'Co chcesz ugotować?' : 'Co masz w lodówce?'
                }
                value={query}
                onInput={(e, value) => setQuery(value)}
              />
            </Stack.Item>
            <Stack.Item>
              <Button
                selected={mode === 'dish'}
                onClick={() => setMode('dish')}
              >
                Danie
              </Button>
              <Button
                selected={mode === 'ingredient'}
                onClick={() => setMode('ingredient')}
              >
                Składnik
              </Button>
            </Stack.Item>
          </Stack>
          <Box mt={1}>
            <Button
              compact
              selected={method === null}
              onClick={() => setMethod(null)}
            >
              Wszystko
            </Button>
            {methods.map((m) => (
              <Button
                compact
                key={m}
                selected={method === m}
                onClick={() => setMethod(method === m ? null : m)}
              >
                {m}
              </Button>
            ))}
          </Box>
        </Section>
        <Section>
          {!needle && !method && (
            <Box color="label">
              Wpisz danie albo składnik, albo wybierz sposób przygotowania.
              Kliknij składnik, żeby zobaczyć, jak go zrobić.
            </Box>
          )}
          {(!!needle || !!method) && filtered.length === 0 && (
            <NoticeBox>Nic nie znaleziono.</NoticeBox>
          )}
          {filtered.slice(0, MAX_SHOWN).map((recipe) => (
            <Box
              key={recipe.id}
              mb={1}
              p={1}
              style={{
                borderLeft: '3px solid rgba(255, 255, 255, 0.2)',
                background: 'rgba(0, 0, 0, 0.15)',
              }}
            >
              <Box bold>
                {recipe.amount ? `${recipe.amount}× ` : ''}
                {recipe.name}
                <Box
                  inline
                  color="label"
                  ml={1}
                  style={{ fontWeight: 'normal' }}
                >
                  ({recipe.method})
                </Box>
                {recipe.learned && (
                  <Box inline color="average" ml={1}>
                    trzeba się nauczyć
                  </Box>
                )}
              </Box>
              <Box mt={0.5}>
                {recipe.ingredients.map((ingredient) => {
                  const craftable = makeable.has(ingredient.name.toLowerCase());
                  return (
                    <Button
                      key={ingredient.name}
                      compact
                      color={craftable ? 'default' : 'transparent'}
                      tooltip={
                        craftable ? 'Pokaż, jak to zrobić' : 'Trzeba to zdobyć'
                      }
                      onClick={() => craftable && searchFor(ingredient.name)}
                    >
                      {ingredient.reagent
                        ? `${ingredient.amount}u ${ingredient.name}`
                        : `${ingredient.amount}× ${ingredient.name}`}
                    </Button>
                  );
                })}
              </Box>
              {recipe.tools.length > 0 && (
                <Box mt={0.5} color="label">
                  Potrzebne: {recipe.tools.join(', ')}
                </Box>
              )}
            </Box>
          ))}
          {filtered.length > MAX_SHOWN && (
            <Box color="label">
              …i jeszcze {filtered.length - MAX_SHOWN}. Zawęź wyszukiwanie.
            </Box>
          )}
        </Section>
      </NtosWindow.Content>
    </NtosWindow>
  );
};
