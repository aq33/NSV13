import { Box, Icon, Section, Stack } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  help_text: string;
};

const DEFAULT_HELP = `Brak informacji! W razie potrzeby poproś o pomoc.`;

const boxHelp = [
  {
    color: 'purple',
    text: 'Zbadaj okolicę i zrób, co trzeba, żeby odzyskać skrzynię. Uważnie czytaj informacje o domenie i szukaj wskazówek.',
    icon: 'search-location',
    title: 'Szukaj',
  },
  {
    color: 'green',
    text: 'Zanieś skrzynię na wyznaczone miejsce wysyłki w kryjówce. Może wyglądać nie na miejscu. Obejrzyj kryjówkę, żeby je znaleźć.',
    icon: 'boxes',
    title: 'Odzyskaj',
  },
  {
    color: 'blue',
    text: 'Drabina to najbezpieczniejszy sposób rozłączenia przed odzyskaniem skrzyni. Jeśli połączenie zostanie zerwane, netpod ma ograniczone możliwości reanimacji.',
    icon: 'plug',
    title: 'Rozłącz',
  },
  {
    color: 'yellow',
    text: 'Po podłączeniu jesteś w miarę bezpieczny od zagrożeń otoczenia i intruzów, ale nie całkiem. Pilnuj alertów.',
    icon: 'id-badge',
    title: 'Bezpieczeństwo',
  },
  {
    color: 'gold',
    text: 'Tworzenie awatarów zżera ogromną przepustowość. Nie marnuj ich.',
    icon: 'coins',
    title: 'Ograniczone próby',
  },
  {
    color: 'red',
    text: 'Pamiętaj, że jesteś fizycznie połączony z awatarem. Jesteś ciałem obcym we wrogim środowisku, które spróbuje cię siłą wyrzucić.',
    icon: 'skull-crossbones',
    title: 'Prawdziwe zagrożenie',
  },
] as const;

export const AvatarHelp = (props) => {
  const { data } = useBackend<Data>();
  const { help_text = DEFAULT_HELP } = data;

  return (
    <Window title="Informacje o domenie" width={600} height={600}>
      <Window.Content>
        <Stack fill vertical>
          <Stack.Item grow>
            <Section
              color="good"
              fill
              scrollable
              title="Witaj w domenie wirtualnej."
            >
              {help_text}
            </Section>
          </Stack.Item>
          <Stack.Item grow={4}>
            <Stack fill vertical>
              <Stack.Item grow>
                <Stack fill>
                  {[0, 1].map((i) => (
                    <BoxHelp index={i} key={i} />
                  ))}
                </Stack>
              </Stack.Item>
              <Stack.Item grow>
                <Stack fill>
                  {[2, 3].map((i) => (
                    <BoxHelp index={i} key={i} />
                  ))}
                </Stack>
              </Stack.Item>
              <Stack.Item grow>
                <Stack fill>
                  {[4, 5].map((i) => (
                    <BoxHelp index={i} key={i} />
                  ))}
                </Stack>
              </Stack.Item>
            </Stack>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

// I wish I had media queries
const BoxHelp = (props: { index: number }) => {
  const { index } = props;

  return (
    <Stack.Item grow>
      <Section
        color="label"
        fill
        minHeight={10}
        title={
          <Stack align="center">
            <Icon
              color={boxHelp[index].color}
              mr={1}
              name={boxHelp[index].icon}
            />
            <Box>{boxHelp[index].title}</Box>
          </Stack>
        }
      >
        {boxHelp[index].text}
      </Section>
    </Stack.Item>
  );
};
