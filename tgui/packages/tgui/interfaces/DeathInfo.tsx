// AQUILA - "Nie żyjesz" window shown on death (aquila/code/modules/mob/living/death.dm)
import { ReactNode } from 'react';
import { Box, Icon, NoticeBox, Section, Stack } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  defib_minutes: number;
  norespawn: boolean;
};

type WayProps = {
  icon: string;
  name: string;
  children: ReactNode;
};

const Way = (props: WayProps) => {
  const { icon, name, children } = props;
  return (
    <Stack.Item>
      <Stack align="baseline">
        <Stack.Item width="20px" textAlign="center">
          <Icon name={icon} color="label" />
        </Stack.Item>
        <Stack.Item grow>
          <b>{name}</b> – {children}
        </Stack.Item>
      </Stack>
    </Stack.Item>
  );
};

export const DeathInfo = (props) => {
  const { data } = useBackend<Data>();
  const { defib_minutes, norespawn } = data;

  return (
    <Window title="Nie żyjesz" width={500} height={680}>
      <Window.Content scrollable>
        <NoticeBox danger>
          <Box fontSize="1.4em" bold>
            Nie żyjesz.
          </Box>
          To jeszcze nie koniec rundy dla ciebie. Do gry możesz wrócić na kilka
          sposobów.
        </NoticeBox>
        <Section title="Ożywienie twojego ciała">
          <Stack vertical>
            <Way icon="heartbeat" name="Defibrylator">
              działa do {defib_minutes} minut od śmierci, jeśli ciało nie jest
              zbyt zniszczone.
            </Way>
            <Way icon="flask" name="Strange Reagent">
              ożywia ciało, które nie ma ciężkich obrażeń ani nie jest
              wyschnięte (husk).
            </Way>
            <Way icon="dna" name="Klonowanie">
              jeśli medbay ma cię w bazie skanów.
            </Way>
            <Way icon="brain" name="MMI">
              twój mózg można włożyć do cyborga, mecha albo rdzenia AI.
            </Way>
          </Stack>
          <Box mt={1} color="label">
            Gdy ktoś cię ożywi, wróć do ciała przyciskiem <b>Reenter corpse</b>.
            Nie klikaj <b>Do Not Resuscitate</b>, bo wtedy nie da się cię już
            ożywić.
          </Box>
        </Section>
        <Section title="Nowa postać jako duch">
          <Stack vertical>
            <Way icon="ghost" name="Spawners Menu">
              (przycisk na ekranie ducha) lista wolnych ról dla duchów.
            </Way>
            <Way icon="robot" name="pAI Setup">
              zgłoś się jako osobisty asystent AI.
            </Way>
            <Way icon="microchip" name="Positroniczny mózg">
              kliknij go jako duch, gdy ktoś go aktywuje.
            </Way>
            <Way icon="paw" name="Possess a mouse">
              zostań myszą na statku.
            </Way>
            <Way icon="bell" name="Wydarzenia">
              w trakcie rundy mogą pojawiać się okienka z propozycją roli
              (abordaż, piraci, obce formy życia i inne). Włącz je w
              preferencjach.
            </Way>
          </Stack>
        </Section>
        <Section title="Posiłki wzywane przez załogę">
          <Stack vertical>
            <Way icon="shield-alt" name="Drużyna szybkiej reakcji (ERT)">
              kapitan, szef ochrony albo AI mogą poprosić o nią w konsoli
              komunikacyjnej. Jeśli Centrala ją wyśle, duchy dostaną okienko z
              propozycją dołączenia.
            </Way>
            <Way icon="snowflake" name="Wybudzenie załogi z kriostazy">
              te same osoby mogą w konsoli komunikacyjnej wybudzić załogę. Duchy
              dostaną wtedy okienko i mogą wrócić jako Majtek z losową postacią.
            </Way>
          </Stack>
        </Section>
        {!!norespawn && (
          <NoticeBox info>
            Powrót do lobby (respawn) jest wyłączony. Jeśli nic z powyższych nie
            zadziała, zagrasz w następnej rundzie.
          </NoticeBox>
        )}
      </Window.Content>
    </Window>
  );
};
