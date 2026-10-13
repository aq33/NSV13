// AQUILA - menu zdolności demona impulsu (port z ParadiseSS13), w stylu emporium changelinga
import {
  Box,
  Button,
  LabeledList,
  NoticeBox,
  NumberInput,
  Section,
  Stack,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Ability = {
  id: number;
  name: string;
  desc: string;
  owned: boolean;
  unlock_cost: number;
  upgrade_cost: number;
  level: number;
  level_max: number;
  cast_cost: string | null;
  cooldown: string | null;
  requires_area: boolean;
};

type BodyUpgrade = {
  name: string;
  desc: string;
  cost: number;
};

type Data = {
  apcs_remaining: number;
  hijacked_apcs: number;
  charge: string;
  maxcharge: string;
  power_status: string;
  controlling_area: string | null;
  drain_rate: number;
  max_drain_rate: number;
  do_drain: boolean;
  show_cables: boolean;
  abilities: Ability[];
  body_upgrades: BodyUpgrade[];
};

export const PulseDemonMenu = (props) => {
  const { act, data } = useBackend<Data>();
  const {
    apcs_remaining,
    hijacked_apcs,
    charge,
    maxcharge,
    power_status,
    controlling_area,
    drain_rate,
    max_drain_rate,
    do_drain,
    show_cables,
    abilities = [],
    body_upgrades = [],
  } = data;
  return (
    <Window theme="hackerman" width={760} height={640}>
      <Window.Content scrollable>
        <Section title="Stan">
          <LabeledList>
            <LabeledList.Item label="APC do wydania">
              <Box bold color={apcs_remaining > 0 ? 'good' : 'label'}>
                {apcs_remaining}
              </Box>
            </LabeledList.Item>
            <LabeledList.Item label="Przejęte APC">
              {hijacked_apcs}
            </LabeledList.Item>
            <LabeledList.Item label="Energia">
              {charge} / {maxcharge}
            </LabeledList.Item>
            <LabeledList.Item label="Zasilanie">
              {power_status}
            </LabeledList.Item>
            <LabeledList.Item label="Kontrolowany obszar">
              {controlling_area || 'brak (wejdź do przejętego APC)'}
            </LabeledList.Item>
            <LabeledList.Item
              label="Tempo wysysania (W)"
              buttons={
                <Button
                  icon="plug"
                  selected={show_cables}
                  onClick={() => act('toggle_cables')}
                >
                  Podgląd kabli
                </Button>
              }
            >
              <NumberInput
                value={drain_rate}
                minValue={1000}
                maxValue={max_drain_rate}
                step={1000}
                stepPixelSize={2}
                width="90px"
                onChange={(value) => act('drain_rate', { rate: value })}
              />{' '}
              <Box inline color={do_drain ? 'good' : 'bad'}>
                {do_drain ? 'wysysanie włączone' : 'wysysanie wyłączone'}
              </Box>
            </LabeledList.Item>
          </LabeledList>
        </Section>
        {apcs_remaining === 0 && hijacked_apcs === 0 && (
          <NoticeBox info>
            Punkty zdobywasz, przejmując APC: wejdź po kablu na pole z APC i
            odczekaj, aż pasek się zapełni.
          </NoticeBox>
        )}
        <Section title="Zdolności">
          <LabeledList>
            {abilities.map((ability) => (
              <LabeledList.Item
                key={ability.id}
                className="candystripe"
                label={ability.name}
                buttons={
                  ability.owned ? (
                    ability.level < ability.level_max ? (
                      <Button
                        icon="arrow-up"
                        disabled={apcs_remaining < ability.upgrade_cost}
                        onClick={() => act('upgrade', { id: ability.id })}
                      >
                        Ulepsz ({ability.upgrade_cost} APC)
                      </Button>
                    ) : (
                      <Button selected>
                        {ability.level_max ? 'Maks. poziom' : 'Kupione'}
                      </Button>
                    )
                  ) : (
                    <Button
                      icon="bolt"
                      disabled={apcs_remaining < ability.unlock_cost}
                      onClick={() => act('buy', { id: ability.id })}
                    >
                      Kup ({ability.unlock_cost} APC)
                    </Button>
                  )
                }
              >
                <Stack vertical>
                  <Stack.Item>{ability.desc}</Stack.Item>
                  <Stack.Item>
                    <Box color="label">
                      {ability.cast_cost &&
                        `Koszt użycia: ${ability.cast_cost}. `}
                      {ability.cooldown && `Odnowienie: ${ability.cooldown}. `}
                      {ability.requires_area &&
                        'Działa tylko z przejętego APC, na jego pomieszczenie. '}
                      {ability.owned &&
                        ability.level_max > 0 &&
                        `Poziom ${ability.level + 1}/${ability.level_max + 1}.`}
                    </Box>
                  </Stack.Item>
                </Stack>
              </LabeledList.Item>
            ))}
          </LabeledList>
        </Section>
        <Section title="Ulepszenia ciała">
          <LabeledList>
            {body_upgrades.map((upgrade) => (
              <LabeledList.Item
                key={upgrade.name}
                className="candystripe"
                label={upgrade.name}
                buttons={
                  upgrade.cost === -1 ? (
                    <Button selected>Maks.</Button>
                  ) : (
                    <Button
                      icon="arrow-up"
                      disabled={apcs_remaining < upgrade.cost}
                      onClick={() => act('body', { name: upgrade.name })}
                    >
                      Ulepsz ({upgrade.cost} APC)
                    </Button>
                  )
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
