// AQUILA - program PDA „Książka kucharska”: lista przepisów po miejscu przygotowania i kategorii
import { useState } from 'react';
import {
  Box,
  Collapsible,
  Input,
  NoticeBox,
  Section,
  Tabs,
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
  desc: string | null;
  method: string;
  ingredients: Ingredient[];
  tools: string[];
  category: string | null;
  learned: boolean;
  amount?: number;
};

type Data = {
  recipes: CookRecipe[];
};

const METHOD_ORDER = [
  'Stół',
  'Procesor',
  'Mikrofalówka',
  'Grill',
  'Piekarnik',
  'Krojenie',
  'Mieszanki',
];

const METHOD_HINTS: Record<string, string> = {
  Stół: 'Połóż składniki na stole i wybierz danie w menu craftingu.',
  Procesor: 'Wrzuć składnik do procesora kuchennego i go włącz.',
  Mikrofalówka: 'Włóż do mikrofalówki i włącz.',
  Grill: 'Połóż na rozgrzanym grillu i poczekaj, nie dłużej, bo się spali.',
  Piekarnik: 'Połóż na blasze w piekarniku i poczekaj.',
  Krojenie: 'Użyj narzędzia na składniku, najlepiej leżącym na stole.',
  Mieszanki: 'Wlej składniki do jednego zbiornika (miski, zlewki).',
};

const byName = (a: CookRecipe, b: CookRecipe) => a.name.localeCompare(b.name);

const listIngredients = (ingredients: Ingredient[]) =>
  ingredients
    .map((i) =>
      i.reagent ? `${i.amount}u ${i.name}` : `${i.amount}× ${i.name}`,
    )
    .join(', ');

export const NtosCookbook = (props) => {
  const { data } = useBackend<Data>();
  const recipes = data.recipes || [];
  const [query, setQuery] = useState('');
  const [tab, setTab] = useState(METHOD_ORDER[0]);

  const methods = METHOD_ORDER.filter((m) =>
    recipes.some((r) => r.method === m),
  );
  const needle = query.trim().toLowerCase();
  const matches = (r: CookRecipe) =>
    r.name.toLowerCase().includes(needle) ||
    r.ingredients.some((i) => i.name.toLowerCase().includes(needle));

  return (
    <NtosWindow width={520} height={640}>
      <NtosWindow.Content scrollable>
        <Section>
          <Input
            fluid
            placeholder="Szukaj dania albo składnika we wszystkich zakładkach…"
            value={query}
            onInput={(e, value) => setQuery(value)}
          />
        </Section>
        {needle ? (
          <SearchResults recipes={recipes.filter(matches)} methods={methods} />
        ) : (
          <>
            <Tabs fluid>
              {methods.map((m) => (
                <Tabs.Tab
                  key={m}
                  selected={tab === m}
                  onClick={() => setTab(m)}
                >
                  {m}
                </Tabs.Tab>
              ))}
            </Tabs>
            <MethodList
              method={tab}
              recipes={recipes.filter((r) => r.method === tab)}
            />
          </>
        )}
      </NtosWindow.Content>
    </NtosWindow>
  );
};

const SearchResults = (props: { recipes: CookRecipe[]; methods: string[] }) => {
  const { recipes, methods } = props;
  if (recipes.length === 0) {
    return <NoticeBox>Nic nie znaleziono.</NoticeBox>;
  }
  return (
    <>
      {methods.map((m) => {
        const inMethod = recipes.filter((r) => r.method === m).sort(byName);
        if (inMethod.length === 0) {
          return null;
        }
        return (
          <Section key={m} title={`${m} (${inMethod.length})`}>
            {inMethod.map((recipe) => (
              <RecipeRow key={recipe.id} recipe={recipe} />
            ))}
          </Section>
        );
      })}
    </>
  );
};

const MethodList = (props: { method: string; recipes: CookRecipe[] }) => {
  const { method, recipes } = props;
  const categories = Array.from(
    new Set(recipes.map((r) => r.category).filter((c): c is string => !!c)),
  ).sort((a, b) => a.localeCompare(b));

  return (
    <Section>
      <Box color="label" mb={1}>
        {METHOD_HINTS[method]}
      </Box>
      {categories.length > 0
        ? categories.map((category) => {
            const inCategory = recipes
              .filter((r) => r.category === category)
              .sort(byName);
            return (
              <Collapsible
                key={category}
                title={`${category} (${inCategory.length})`}
              >
                <Box ml={1}>
                  {inCategory.map((recipe) => (
                    <RecipeRow key={recipe.id} recipe={recipe} />
                  ))}
                </Box>
              </Collapsible>
            );
          })
        : [...recipes]
            .sort(byName)
            .map((recipe) => <RecipeRow key={recipe.id} recipe={recipe} />)}
    </Section>
  );
};

const RecipeRow = (props: { recipe: CookRecipe }) => {
  const { recipe } = props;
  return (
    <Box
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
        {recipe.learned && (
          <Box inline color="average" ml={1} style={{ fontWeight: 'normal' }}>
            (trzeba się nauczyć)
          </Box>
        )}
      </Box>
      {!!recipe.desc && <Box color="label">{recipe.desc}</Box>}
      <Box mt={0.5}>
        <Box inline color="good">
          Z:
        </Box>{' '}
        {listIngredients(recipe.ingredients)}
      </Box>
      {recipe.tools.length > 0 && (
        <Box color="label">Potrzebne: {recipe.tools.join(', ')}</Box>
      )}
    </Box>
  );
};
