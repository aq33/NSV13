// AQUILA - traitor faction and backstory picker, port of BeeStation/BeeStation-Hornet#9126 (TraitorBackstoryMenu.js)
import { useBackend, useLocalState } from '../backend';
import {
  Box,
  Button,
  Dimmer,
  Flex,
  Icon,
  Section,
  Stack,
  Tabs,
  Tooltip,
} from '../components';
import { Window } from '../layouts';
import { AntagInfoTraitorContent } from './AntagInfoTraitor';

type Faction = {
  name: string;
  description: string;
  key: string;
};

type Backstory = {
  name: string;
  description: string;
  path: string;
  allowed_factions: string[];
  motivations: string[];
};

type Data = {
  all_factions: Record<string, Faction>;
  all_backstories: Record<string, Backstory>;
  all_motivations: string[];
  allowed_factions: string[];
  allowed_backstories: string[];
  recommended_factions: string[];
  recommended_backstories: string[];
  faction?: string;
  backstory?: string;
};

const MOTIVATION_ICONS: Record<string, string> = {
  'Forced Into It': 'user-alt-slash',
  'Not Forced Into It': 'user-check',
  Money: 'dollar-sign',
  Political: 'peace',
  Love: 'heart',
  Reputation: 'comments-dollar',
  'Death Threat': 'skull',
  Authority: 'users',
  Fun: 'grin-tongue-wink',
};

const MOTIVATION_NAMES: Record<string, string> = {
  'Forced Into It': 'Zmuszony',
  'Not Forced Into It': 'Z własnej woli',
  Money: 'Pieniądze',
  Political: 'Polityka',
  Love: 'Miłość',
  Reputation: 'Reputacja',
  'Death Threat': 'Groźba śmierci',
  Authority: 'Władza',
  Fun: 'Zabawa',
};

export const TraitorBackstoryMenu = (_props) => {
  const { data } = useBackend<Data>();
  const { all_backstories = {}, all_factions = {}, backstory, faction } = data;
  const has_backstory = !!backstory && !!all_backstories[backstory];
  const has_faction = !!faction && !!all_factions[faction];
  const [ui_phase, set_ui_phase] = useLocalState(
    'traitor_ui_phase',
    has_faction ? 2 : 0,
  );
  const [tabIndex, setTabIndex] = useLocalState('traitor_selected_tab', 1);
  const [selected_faction, set_selected_faction_backend] = useLocalState(
    'traitor_selected_faction',
    'syndicate',
  );
  const [selected_backstory, set_selected_backstory] = useLocalState<
    string | null
  >('traitor_selected_backstory', null);
  const set_selected_faction = (new_faction: string) => {
    set_selected_faction_backend(new_faction);
    if (
      selected_backstory &&
      !all_backstories[selected_backstory]?.allowed_factions?.includes(
        new_faction,
      )
    ) {
      set_selected_backstory(null);
    }
  };
  let windowTitle = 'Historia zdrajcy';
  if (ui_phase === 0) {
    windowTitle = 'Historia zdrajcy: wstęp';
  } else if (ui_phase === 1) {
    windowTitle = 'Historia zdrajcy: wybór frakcji';
  } else if (has_faction && tabIndex === 1) {
    windowTitle = 'Zdrajca';
  }
  const info_ui = ui_phase === 2 && has_faction;
  const menuProps = {
    set_ui_phase,
    selected_faction,
    set_selected_faction,
    selected_backstory,
    set_selected_backstory,
  };
  return (
    <Window
      theme={faction === 'syndicate' ? 'syndicate' : 'neutral'}
      width={650}
      height={info_ui ? 650 : 500}
      title={windowTitle}
    >
      <Window.Content scrollable>
        {ui_phase === 0 && <IntroductionMenu set_ui_phase={set_ui_phase} />}
        {ui_phase === 1 && (
          <SelectFactionMenu
            set_ui_phase={set_ui_phase}
            selected_faction={selected_faction}
            set_selected_faction={set_selected_faction}
          />
        )}
        {ui_phase === 2 && !has_faction && (
          <SelectBackstoryMenu {...menuProps} show_nav />
        )}
        {ui_phase === 2 && has_faction && (
          <>
            <Tabs p={1} pb={0.25}>
              <Button
                mr={1}
                fontSize="15px"
                color="bad"
                icon="arrow-left"
                content="Wstecz"
                onClick={() => set_ui_phase(ui_phase - 1)}
              />
              <Tabs.Tab
                selected={tabIndex === 1}
                onClick={() => setTabIndex(1)}
              >
                Informacje
              </Tabs.Tab>
              <Tabs.Tab
                selected={tabIndex === 2}
                onClick={() => setTabIndex(2)}
              >
                Historia
              </Tabs.Tab>
            </Tabs>
            <Box height="calc(100vh - 90px)">
              {tabIndex === 1 ? (
                <AntagInfoTraitorContent />
              ) : has_backstory ? (
                <BackstorySection
                  fill
                  backstory={all_backstories[backstory as string]}
                />
              ) : (
                <SelectBackstoryMenu {...menuProps} />
              )}
            </Box>
          </>
        )}
      </Window.Content>
    </Window>
  );
};

const IntroductionMenu = (props: { set_ui_phase: (phase: number) => void }) => {
  const { set_ui_phase } = props;
  return (
    <Dimmer>
      <Stack align="baseline" vertical>
        <Stack.Item fontSize="14px">
          <Stack vertical textAlign="center">
            <Stack.Item fontSize="28px" mb={5} maxWidth="80vw">
              Generator historii zdrajcy
            </Stack.Item>
            <Stack.Item maxWidth="80vw">
              To narzędzie daje podstawę do motywacji twojej postaci i powodów,
              dla których została zdrajcą.
            </Stack.Item>
            <Stack.Item maxWidth="80vw">
              <strong>Wybierz frakcję</strong> - każda ma krótki opis. Po
              zatwierdzeniu historii <strong>nie</strong> zmienisz już wyboru,
              więc wybieraj rozważnie. Uplink dostaniesz dopiero po wyborze
              frakcji.
            </Stack.Item>
          </Stack>
        </Stack.Item>
        <Stack.Item>
          <Button
            mt={2}
            fontSize="15px"
            color="good"
            content="Dalej"
            onClick={() => set_ui_phase(1)}
          />
        </Stack.Item>
      </Stack>
    </Dimmer>
  );
};

const get_surrounding_factions = (
  faction_keys: string[],
  selected_faction: string,
) => {
  const max_index = faction_keys.length - 1;
  const current_index = faction_keys.indexOf(selected_faction);
  let next_index = current_index + 1;
  let prev_index = current_index - 1;
  if (next_index > max_index) {
    next_index = 0;
  }
  if (prev_index < 0) {
    prev_index = max_index;
  }
  return [faction_keys[prev_index], faction_keys[next_index]];
};

type MenuProps = {
  set_ui_phase: (phase: number) => void;
  selected_faction: string;
  set_selected_faction: (faction: string) => void;
  selected_backstory: string | null;
  set_selected_backstory: (backstory: string | null) => void;
  show_nav?: boolean;
};

type FactionMenuProps = {
  set_ui_phase: (phase: number) => void;
  selected_faction: string;
  set_selected_faction: (faction: string) => void;
};

const SelectFactionMenu = (props: FactionMenuProps) => {
  const { set_ui_phase, selected_faction, set_selected_faction } = props;
  const { data } = useBackend<Data>();
  const {
    allowed_factions = [],
    all_factions = {},
    faction,
    recommended_factions = [],
  } = data;
  const faction_keys = Object.keys(all_factions);

  if (
    faction_keys.length === 0 ||
    faction_keys.filter((key) => allowed_factions.includes(key)).length === 0
  ) {
    return (
      <Dimmer>
        Nie znaleziono żadnej frakcji. To pewnie błąd, zamknij i otwórz okno.
      </Dimmer>
    );
  }

  const current_faction_key = faction || selected_faction;
  const current_faction = all_factions[current_faction_key];
  const allowed = allowed_factions.includes(current_faction_key);
  const recommended = recommended_factions.includes(current_faction_key);

  return (
    <Dimmer>
      <Box
        width="100%"
        textAlign="center"
        fontSize="25px"
        pb={0.75}
        style={{
          position: 'absolute',
          left: '50%',
          top: '8px',
          transform: 'translateX(-50%)',
          borderBottom: '1px solid #aa2a2a',
        }}
      >
        <strong>Wybór frakcji</strong>
      </Box>
      <Button
        fontSize="15px"
        color="bad"
        icon="arrow-left"
        content="Wstecz"
        style={{ position: 'absolute', left: '8px', top: '8px' }}
        onClick={() => set_ui_phase(0)}
      />
      <Stack align="baseline" vertical>
        <Stack.Item fontSize="14px">
          <Stack vertical textAlign="center">
            <DescriptionLines data={current_faction} />
          </Stack>
        </Stack.Item>
        <Stack.Item>
          {faction ? (
            <Button
              mt={2}
              fontSize="15px"
              content="Dalej"
              color="good"
              onClick={() => set_ui_phase(2)}
            />
          ) : allowed && recommended_factions.length !== 0 && !recommended ? (
            <Button.Confirm
              mt={2}
              fontSize="15px"
              color="bad"
              content="Wybierz"
              confirmContent="Na pewno?"
              tooltip="Ta frakcja NIE jest zalecana przy twoich celach."
              onClick={() => set_ui_phase(2)}
            />
          ) : (
            <Button
              mt={2}
              fontSize="15px"
              color={recommended_factions.length === 0 ? undefined : 'good'}
              content="Wybierz"
              disabled={!allowed}
              tooltip={
                !allowed
                  ? 'Nie możesz wybrać tej frakcji.'
                  : recommended_factions.length === 0
                    ? undefined
                    : 'Ta frakcja jest zalecana przy twoich celach.'
              }
              onClick={() => set_ui_phase(2)}
            />
          )}
        </Stack.Item>
        {(recommended_factions.length > 0 || !!faction) && (
          <Stack.Item
            mt={3}
            textColor={faction || !recommended ? 'red' : 'green'}
          >
            <strong>
              {faction
                ? 'Twoja frakcja jest już zatwierdzona.'
                : recommended
                  ? 'Ta frakcja jest zalecana przy twoich celach.'
                  : 'Ta frakcja NIE jest zalecana przy twoich celach.'}
            </strong>
          </Stack.Item>
        )}
      </Stack>
      {!faction && (
        <FactionNavigationButtons
          faction_keys={faction_keys}
          selected_faction={selected_faction}
          set_selected_faction={set_selected_faction}
          left="8px"
          right="8px"
          top="45%"
          size="18px"
        />
      )}
    </Dimmer>
  );
};

const FactionNavigationButtons = (props: {
  faction_keys: string[];
  selected_faction: string;
  set_selected_faction: (faction: string) => void;
  left: string;
  right: string;
  top: string;
  size: string;
}) => {
  const { faction_keys, selected_faction, set_selected_faction } = props;
  const [prev_faction, next_faction] = get_surrounding_factions(
    faction_keys,
    selected_faction,
  );
  return (
    <>
      <Button
        fontSize={props.size}
        icon="arrow-left"
        style={{ position: 'absolute', left: props.left, top: props.top }}
        onClick={() => set_selected_faction(prev_faction)}
      />
      <Button
        fontSize={props.size}
        icon="arrow-right"
        style={{ position: 'absolute', right: props.right, top: props.top }}
        onClick={() => set_selected_faction(next_faction)}
      />
    </>
  );
};

const DescriptionLines = (props: { data?: Faction }) => {
  const { data } = props;
  return (
    <>
      <Stack.Item fontSize="28px" mb={2} maxWidth="80vw">
        {data?.name}
      </Stack.Item>
      {data?.description?.split('\n').map((value, index) => (
        <Stack.Item
          key={'desc-' + index}
          maxWidth="70vw"
          dangerouslySetInnerHTML={{ __html: value }}
        />
      ))}
    </>
  );
};

const SelectBackstoryMenu = (props: MenuProps) => {
  const {
    set_ui_phase,
    selected_faction,
    set_selected_faction,
    selected_backstory,
    set_selected_backstory,
    show_nav,
  } = props;
  const { data } = useBackend<Data>();
  const {
    allowed_backstories = [],
    all_backstories = {},
    recommended_backstories = [],
    all_motivations = [],
    all_factions = {},
    allowed_factions = [],
    faction,
    backstory,
  } = data;

  const [motivations, set_motivations] = useLocalState<string[]>(
    'traitor_motivations',
    [],
  );

  const toggle_motivation = (name: string) => {
    let next = motivations.filter((m) => m !== name);
    if (!motivations.includes(name)) {
      if (name === 'Not Forced Into It') {
        next = next.filter((m) => m !== 'Forced Into It');
      }
      if (name === 'Forced Into It') {
        next = next.filter((m) => m !== 'Not Forced Into It');
      }
      next.push(name);
    }
    set_motivations(next);
  };

  const current_faction_key = faction || selected_faction;
  const current_faction = all_factions[current_faction_key];

  const filtered = Object.values(all_backstories).filter(
    (value) =>
      value.allowed_factions?.includes(current_faction_key) &&
      allowed_backstories.includes(value.path),
  );
  if (filtered.length === 0) {
    return (
      <Dimmer>
        Nie znaleziono żadnej historii. To pewnie błąd, zamknij i otwórz okno.
      </Dimmer>
    );
  }

  const current_backstory_key = backstory || selected_backstory;
  const current_backstory = current_backstory_key
    ? all_backstories[current_backstory_key]
    : undefined;

  return (
    <Flex height="100%" direction="column">
      <Flex.Item mb={1}>
        <Section
          fill
          title={
            <>
              <Box width="100%" textAlign="center" fontSize="20px">
                {!faction && (
                  <FactionNavigationButtons
                    faction_keys={Object.keys(all_factions).filter((v) =>
                      allowed_factions.includes(v),
                    )}
                    selected_faction={current_faction_key}
                    set_selected_faction={set_selected_faction}
                    left="28%"
                    right="28%"
                    top="8px"
                    size="13px"
                  />
                )}
                <strong>{current_faction?.name}</strong>
              </Box>
              {show_nav && (
                <Button
                  fontSize="15px"
                  color="bad"
                  icon="arrow-left"
                  content="Wstecz"
                  style={{ position: 'absolute', left: '5px', top: '5px' }}
                  onClick={() => set_ui_phase(1)}
                />
              )}
            </>
          }
        >
          <Box mb={0.5}>
            <strong>Co motywuje twoją postać?</strong>
          </Box>
          {all_motivations.map((motivation) => (
            <Button.Checkbox
              key={motivation + '-checkbox'}
              icon={
                motivations.includes(motivation)
                  ? MOTIVATION_ICONS[motivation]
                  : 'square-o'
              }
              content={MOTIVATION_NAMES[motivation] || motivation}
              onClick={() => toggle_motivation(motivation)}
              checked={motivations.includes(motivation)}
            />
          ))}
        </Section>
      </Flex.Item>
      <Flex.Item grow height="0">
        <Flex height="100%">
          <Flex.Item minWidth="180px">
            <Section fill scrollable>
              <Tabs vertical textAlign="right">
                {filtered.map((option) => {
                  const matches = option.motivations.filter((r) =>
                    motivations.includes(r),
                  ).length;
                  return (
                    <BackstoryTab
                      key={option.path}
                      path={option.path}
                      name={option.name}
                      selected={current_backstory_key === option.path}
                      set_selected_backstory={set_selected_backstory}
                      is_recommended_objectives={recommended_backstories.includes(
                        option.path,
                      )}
                      recommendation_count={matches}
                      matches_all_recommendations={
                        motivations.filter(
                          (r) => !option.motivations.includes(r),
                        ).length === 0
                      }
                    />
                  );
                })}
              </Tabs>
            </Section>
          </Flex.Item>
          <Flex.Item grow basis={0} ml={1}>
            {current_backstory ? (
              <BackstorySection
                show_button
                fill
                backstory={current_backstory}
                backstory_locked={!!backstory}
                backstory_key={current_backstory_key as string}
                faction_key={current_faction_key}
                set_ui_phase={set_ui_phase}
              />
            ) : (
              <Section fill>
                <Dimmer>Nie wybrano historii</Dimmer>
              </Section>
            )}
          </Flex.Item>
        </Flex>
      </Flex.Item>
    </Flex>
  );
};

const BackstorySection = (props: {
  backstory: Backstory;
  backstory_locked?: boolean;
  show_button?: boolean;
  backstory_key?: string;
  faction_key?: string;
  set_ui_phase?: (phase: number) => void;
  fill?: boolean;
}) => {
  const {
    backstory,
    backstory_locked,
    show_button,
    backstory_key,
    faction_key,
    set_ui_phase,
    fill,
  } = props;
  const { act } = useBackend();
  if (!backstory) {
    return null;
  }
  return (
    <Section
      fill={fill}
      title={
        <Box inline fontSize={1.8}>
          {backstory.name}
        </Box>
      }
      fontSize={1.25}
      buttons={
        <>
          {Object.entries(MOTIVATION_ICONS)
            .filter(([k]) => backstory.motivations?.includes(k))
            .map(([motivation, icon]) => (
              <Tooltip
                key={'icon-motivation-tooltip-' + motivation}
                content={MOTIVATION_NAMES[motivation] || motivation}
              >
                <Icon
                  fontSize={1.75}
                  mr={1}
                  mt={1}
                  pr={0.5}
                  pl={0.5}
                  name={icon}
                />
              </Tooltip>
            ))}
          {show_button &&
            (backstory_locked ? (
              <Button
                fontSize={1.4}
                content="Dalej"
                color="good"
                onClick={() => set_ui_phase?.(2)}
              />
            ) : (
              <Button.Confirm
                fontSize={1.4}
                confirmContent="Zatwierdzić?"
                tooltip="Po zatwierdzeniu nie zmienisz już wyboru."
                content="Wybierz"
                onClick={() =>
                  act('select_backstory', {
                    faction: faction_key,
                    backstory: backstory_key,
                  })
                }
              />
            ))}
        </>
      }
    >
      <Box inline dangerouslySetInnerHTML={{ __html: backstory.description }} />
    </Section>
  );
};

const BackstoryTab = (props: {
  path: string;
  name: string;
  selected: boolean;
  is_recommended_objectives: boolean;
  recommendation_count: number;
  matches_all_recommendations: boolean;
  set_selected_backstory: (backstory: string | null) => void;
}) => {
  const {
    path,
    name,
    selected,
    is_recommended_objectives,
    recommendation_count,
    matches_all_recommendations,
    set_selected_backstory,
  } = props;
  return (
    <Tabs.Tab
      fontSize={1.05}
      selected={selected}
      onClick={() => set_selected_backstory(selected ? null : path)}
    >
      {name}
      {is_recommended_objectives && (
        <Tooltip content="Ta historia jest zalecana, bo twoje cele są krwawe.">
          <Icon name="crosshairs" color="red" fontSize={1} ml={1} />
        </Tooltip>
      )}
      {recommendation_count > 0 && (
        <Tooltip content="Ta historia pasuje do wybranych motywacji.">
          <Icon
            fontSize={1.25}
            name="star"
            color={
              matches_all_recommendations
                ? 'yellow'
                : recommendation_count > 1
                  ? 'silver'
                  : 'brown'
            }
            ml={1}
          />
        </Tooltip>
      )}
    </Tabs.Tab>
  );
};
