// AQUILA - wyszukiwarka receptur chemicznych (dispensery i program PDA „Receptury”)
import { useState } from 'react';
import { Box, Button, Input, NoticeBox, Stack } from 'tgui-core/components';

export type RecipeReagent = {
  name: string;
  id: string;
  amount: number;
};

export type Recipe = {
  id: string;
  name: string;
  results: RecipeReagent[];
  reagents: RecipeReagent[];
  catalysts: RecipeReagent[];
  temp: number;
  cold: boolean;
  container: string | null;
};

type Props = {
  recipes: Recipe[];
  /** Id odczynników, które można wydać w tej maszynie */
  dispensable?: string[];
  /** Wydaje odczynnik o danym id (tylko w dispenserze) */
  onDispense?: (id: string) => void;
};

const MAX_SHOWN = 40;

type SearchMode = 'product' | 'ingredient';

export const RecipeLookup = (props: Props) => {
  const { recipes, dispensable, onDispense } = props;
  const [query, setQuery] = useState('');
  const [mode, setMode] = useState<SearchMode>('product');
  const [onlyHere, setOnlyHere] = useState(false);

  const canDispense = (id: string) => !!dispensable && dispensable.includes(id);
  const producible = new Set<string>();
  for (const recipe of recipes) {
    for (const result of recipe.results) {
      producible.add(result.id);
    }
  }

  const needle = query.trim().toLowerCase();
  const matches = (text: string) => text.toLowerCase().includes(needle);
  const filtered = recipes
    .filter((recipe) => {
      if (onlyHere && !recipe.reagents.every((r) => canDispense(r.id))) {
        return false;
      }
      if (!needle) {
        return onlyHere;
      }
      if (mode === 'ingredient') {
        return (
          recipe.reagents.some((r) => matches(r.name)) ||
          recipe.catalysts.some((r) => matches(r.name))
        );
      }
      return (
        matches(recipe.name) || recipe.results.some((r) => matches(r.name))
      );
    })
    .sort((a, b) => a.name.localeCompare(b.name));

  const searchFor = (name: string) => {
    setMode('product');
    setQuery(name);
  };

  return (
    <Box>
      <Stack mb={1}>
        <Stack.Item grow>
          <Input
            fluid
            autoFocus
            placeholder={
              mode === 'product' ? 'Czego szukasz?' : 'Co masz pod ręką?'
            }
            value={query}
            onInput={(e, value) => setQuery(value)}
          />
        </Stack.Item>
        <Stack.Item>
          <Button
            selected={mode === 'product'}
            tooltip="Szukaj po tym, co powstaje"
            onClick={() => setMode('product')}
          >
            Produkt
          </Button>
          <Button
            selected={mode === 'ingredient'}
            tooltip="Szukaj receptur, w których jest dany składnik"
            onClick={() => setMode('ingredient')}
          >
            Składnik
          </Button>
          {!!dispensable && (
            <Button.Checkbox
              checked={onlyHere}
              tooltip="Tylko receptury, których wszystkie składniki wyda ta maszyna"
              onClick={() => setOnlyHere(!onlyHere)}
            >
              Tylko stąd
            </Button.Checkbox>
          )}
        </Stack.Item>
      </Stack>
      {!needle && !onlyHere && (
        <Box color="label">
          Wpisz nazwę, żeby znaleźć recepturę. Kliknij składnik, żeby zobaczyć,
          jak go zrobić
          {!!onDispense && ', albo kroplę obok, żeby go wydać'}.
        </Box>
      )}
      {(!!needle || onlyHere) && filtered.length === 0 && (
        <NoticeBox>Nic nie znaleziono.</NoticeBox>
      )}
      {filtered.slice(0, MAX_SHOWN).map((recipe) => (
        <RecipeEntry
          key={recipe.id}
          recipe={recipe}
          canDispense={canDispense}
          producible={producible}
          onDispense={onDispense}
          searchFor={searchFor}
        />
      ))}
      {filtered.length > MAX_SHOWN && (
        <Box color="label" mt={1}>
          …i jeszcze {filtered.length - MAX_SHOWN}. Zawęź wyszukiwanie.
        </Box>
      )}
    </Box>
  );
};

type EntryProps = {
  recipe: Recipe;
  canDispense: (id: string) => boolean;
  producible: Set<string>;
  onDispense?: (id: string) => void;
  searchFor: (name: string) => void;
};

const RecipeEntry = (props: EntryProps) => {
  const { recipe, canDispense, producible, onDispense, searchFor } = props;
  const output = recipe.results.length
    ? recipe.results.map((r) => `${r.amount}× ${r.name}`).join(', ')
    : 'efekt bez produktu';
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
        {recipe.name}
        <Box inline color="label" ml={1} style={{ fontWeight: 'normal' }}>
          → {output}
        </Box>
      </Box>
      <Box mt={0.5}>
        {recipe.reagents.map((reagent) => (
          <ReagentChip
            key={reagent.id}
            reagent={reagent}
            canDispense={canDispense}
            producible={producible}
            onDispense={onDispense}
            searchFor={searchFor}
          />
        ))}
      </Box>
      {recipe.catalysts.length > 0 && (
        <Box mt={0.5} color="label">
          Katalizator (nie zużywa się):{' '}
          {recipe.catalysts.map((reagent) => (
            <ReagentChip
              key={reagent.id}
              reagent={reagent}
              canDispense={canDispense}
              producible={producible}
              onDispense={onDispense}
              searchFor={searchFor}
            />
          ))}
        </Box>
      )}
      {recipe.temp > 0 && (
        <Box mt={0.5} color={recipe.cold ? 'blue' : 'orange'}>
          Temperatura {recipe.cold ? 'poniżej' : 'co najmniej'} {recipe.temp} K
        </Box>
      )}
      {!!recipe.container && (
        <Box mt={0.5} color="purple">
          Tylko w: {recipe.container}
        </Box>
      )}
    </Box>
  );
};

type ChipProps = {
  reagent: RecipeReagent;
  canDispense: (id: string) => boolean;
  producible: Set<string>;
  onDispense?: (id: string) => void;
  searchFor: (name: string) => void;
};

const ReagentChip = (props: ChipProps) => {
  const { reagent, canDispense, producible, onDispense, searchFor } = props;
  const here = canDispense(reagent.id);
  const craftable = producible.has(reagent.id);
  return (
    <Box inline mr={1}>
      <Button
        compact
        color={here ? 'green' : craftable ? 'default' : 'transparent'}
        tooltip={
          craftable
            ? 'Pokaż, jak to zrobić'
            : here
              ? 'Dostępne w tej maszynie'
              : 'Brak receptury, trzeba to zdobyć'
        }
        onClick={() => craftable && searchFor(reagent.name)}
      >
        {reagent.amount}× {reagent.name}
      </Button>
      {here && !!onDispense && (
        <Button
          compact
          icon="tint"
          color="green"
          tooltip="Wydaj (ilość z przycisków powyżej)"
          onClick={() => onDispense(reagent.id)}
        />
      )}
    </Box>
  );
};
