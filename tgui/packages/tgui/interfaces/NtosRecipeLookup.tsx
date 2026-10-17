// AQUILA - program PDA „Receptury”
import { Section } from 'tgui-core/components';

import { useBackend } from '../backend';
import { NtosWindow } from '../layouts';
import { Recipe, RecipeLookup } from './common/RecipeLookup';

type Data = {
  recipeCatalog: Recipe[];
};

export const NtosRecipeLookup = (props) => {
  const { data } = useBackend<Data>();
  return (
    <NtosWindow width={500} height={600}>
      <NtosWindow.Content scrollable>
        <Section title="Receptury">
          <RecipeLookup recipes={data.recipeCatalog || []} />
        </Section>
      </NtosWindow.Content>
    </NtosWindow>
  );
};
