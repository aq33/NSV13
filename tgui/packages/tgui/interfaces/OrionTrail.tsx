// AQUILA - Orion Trail (aquila/code/game/machinery/computer/orion_trail_ui.dm)
import {
  Box,
  Button,
  LabeledList,
  NoticeBox,
  Section,
  Stack,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

const STATUS_START = 1;
const STATUS_GAMEOVER = 3;

type EventButton = {
  key: string;
  value: string;
  label: string;
};

type OrionEvent = {
  text: string;
  buttons: EventButton[];
};

type Data = {
  status: number;
  food: number;
  fuel: number;
  engine: number;
  hull: number;
  electronics: number;
  settlers: string[];
  turn: number;
  emagged: boolean;
  event: OrionEvent | null;
  starved?: boolean;
  out_of_fuel?: boolean;
  stop?: string;
  blurb?: string;
  black_hole?: boolean;
};

const TopicButton = (props: {
  topic: string;
  value?: string;
  label: string;
  color?: string;
  icon?: string;
}) => {
  const { act } = useBackend<Data>();
  return (
    <Button
      icon={props.icon}
      color={props.color}
      onClick={() =>
        act('topic', { key: props.topic, value: props.value || '1' })
      }
    >
      {props.label}
    </Button>
  );
};

const Supplies = () => {
  const { data } = useBackend<Data>();
  const { food, fuel, engine, hull, electronics, settlers = [] } = data;
  return (
    <Section title="Statek">
      <LabeledList>
        <LabeledList.Item label="Załoga">{settlers.join(', ')}</LabeledList.Item>
        <LabeledList.Item label="Jedzenie">
          <Box color={food < 20 ? 'bad' : undefined}>{food}</Box>
        </LabeledList.Item>
        <LabeledList.Item label="Paliwo">
          <Box color={fuel < 15 ? 'bad' : undefined}>{fuel}</Box>
        </LabeledList.Item>
        <LabeledList.Item label="Części silnika">{engine}</LabeledList.Item>
        <LabeledList.Item label="Płyty kadłuba">{hull}</LabeledList.Item>
        <LabeledList.Item label="Elektronika">{electronics}</LabeledList.Item>
      </LabeledList>
    </Section>
  );
};

export const OrionTrail = (_) => {
  const { data } = useBackend<Data>();
  const { status, event, emagged } = data;
  return (
    <Window width={440} height={600} theme={emagged ? 'syndicate' : undefined}>
      <Window.Content scrollable>
        {status === STATUS_START && <StartScreen />}
        {status === STATUS_GAMEOVER && <GameOverScreen />}
        {status !== STATUS_START && status !== STATUS_GAMEOVER && (
          <>
            {event ? <EventScreen event={event} /> : <TravelScreen />}
            <Supplies />
          </>
        )}
      </Window.Content>
    </Window>
  );
};

const StartScreen = () => (
  <Section textAlign="center">
    <Box fontSize="24px" bold mt={2}>
      The Orion Trail
    </Box>
    <Box my={2} color="label">
      Przeżyj podróż swoich przodków!
    </Box>
    <TopicButton topic="newgame" icon="rocket" label="Nowa gra" />
  </Section>
);

const GameOverScreen = () => {
  const { data } = useBackend<Data>();
  const { settlers = [], starved, out_of_fuel } = data;
  return (
    <Section title="Koniec gry">
      <Box mb={1}>
        Jak wielu przed tobą, twoja załoga nigdy nie dotarła do Oriona.
      </Box>
      {settlers.length === 0 && (
        <NoticeBox danger>
          Zginęła cała załoga, a statek dołączył do floty widm dryfujących po
          galaktyce.
        </NoticeBox>
      )}
      {settlers.length > 0 && !!starved && (
        <NoticeBox danger>Skończyło się jedzenie i załoga umarła z głodu.</NoticeBox>
      )}
      {settlers.length > 0 && !!out_of_fuel && (
        <NoticeBox danger>
          Skończyło się paliwo i statek powoli wpłynął w gwiazdę.
        </NoticeBox>
      )}
      <TopicButton topic="menu" icon="cross" label="Niech spoczywają w pokoju" />
    </Section>
  );
};

const TravelScreen = () => {
  const { data } = useBackend<Data>();
  const { stop, blurb, black_hole, turn } = data;
  return (
    <Section title={stop} buttons={<Box color="label">Etap {turn} / 9</Box>}>
      <Box mb={1}>{blurb}</Box>
      <Stack wrap>
        {black_hole ? (
          <>
            <Stack.Item>
              <TopicButton topic="pastblack" icon="route" label="Omiń" />
            </Stack.Item>
            <Stack.Item>
              <TopicButton
                topic="blackhole"
                icon="arrow-right"
                label="Leć dalej"
              />
            </Stack.Item>
          </>
        ) : (
          <Stack.Item>
            <TopicButton topic="continue" icon="arrow-right" label="Leć dalej" />
          </Stack.Item>
        )}
        <Stack.Item>
          <TopicButton
            topic="killcrew"
            icon="skull"
            color="bad"
            label="Zabij członka załogi"
          />
        </Stack.Item>
      </Stack>
    </Section>
  );
};

const EventScreen = (props: { event: OrionEvent }) => {
  const { event } = props;
  return (
    <Section>
      <Box dangerouslySetInnerHTML={{ __html: event.text }} />
      <Stack wrap mt={1}>
        {event.buttons.map((button, index) => (
          <Stack.Item key={index}>
            <TopicButton
              topic={button.key}
              value={button.value}
              label={button.label}
            />
          </Stack.Item>
        ))}
      </Stack>
    </Section>
  );
};
