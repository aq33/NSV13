// AQUILA - Psi Web darkspawna (port z Yogstation)
import { Box, Button, LabeledList, Section } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Ability = {
  name: string;
  id: string;
  desc: string;
  psi_cost: string;
  lucidity_cost: number;
  owned: boolean;
  can_purchase: boolean;
};

type Upgrade = Omit<Ability, 'psi_cost'>;

type Data = {
  lucidity: number;
  lucidity_drained: number;
  required_succs: number;
  abilities: Ability[];
  upgrades: Upgrade[];
};

export const PsiWeb = (props) => {
  const { act, data } = useBackend<Data>();
  const { abilities = [], upgrades = [] } = data;
  return (
    <Window width={900} height={480} theme="darkspawn">
      <Window.Content scrollable>
        <Section title="Sieć Psi">
          <LabeledList>
            <LabeledList.Item label="Lucidity do wydania">
              {data.lucidity}
            </LabeledList.Item>
            <LabeledList.Item label="Pożarte umysły (do Sakramentu)">
              {data.lucidity_drained} / {data.required_succs}
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section title="Zdolności">
          <LabeledList>
            {abilities.map((ability) => (
              <LabeledList.Item
                key={ability.id}
                className="candystripe"
                label={ability.name}
                buttons={
                  <Button
                    selected={ability.owned}
                    disabled={!ability.can_purchase}
                    onClick={() => act('unlock', { id: ability.id })}
                  >
                    {ability.owned
                      ? 'Odblokowane'
                      : `Odblokuj (${ability.lucidity_cost})`}
                  </Button>
                }
              >
                <Box>{ability.desc}</Box>
                <Box color="label">Koszt Psi: {ability.psi_cost}</Box>
              </LabeledList.Item>
            ))}
          </LabeledList>
        </Section>
        <Section title="Ulepszenia">
          <LabeledList>
            {upgrades.map((upgrade) => (
              <LabeledList.Item
                key={upgrade.id}
                className="candystripe"
                label={upgrade.name}
                buttons={
                  <Button
                    selected={upgrade.owned}
                    disabled={!upgrade.can_purchase}
                    onClick={() => act('upgrade', { id: upgrade.id })}
                  >
                    {upgrade.owned
                      ? 'Odblokowane'
                      : `Odblokuj (${upgrade.lucidity_cost})`}
                  </Button>
                }
              >
                {upgrade.desc}
              </LabeledList.Item>
            ))}
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
