// AQUILA - okno darkspawna: informacje, wybór klasy i sklep Psi Web (port z Yogstation)
import { BooleanLike } from 'common/react';

import { useBackend, useLocalState } from '../backend';
import { Box, Button, Section, Stack, Tabs } from '../components';
import { Window } from '../layouts';
import { Objective, ObjectivesSection } from './common/ObjectiveSection';

const Velvet = {
  fontWeight: 'bold',
  color: '#7264FF',
};

const Lucidity = {
  fontWeight: 'bold',
  color: '#00AAFF',
};

type Knowledge = {
  path: string;
  name: string;
  desc: string;
  lore_description: string;
  cost: number;
  disabled: BooleanLike;
  infinite: BooleanLike;
  icon?: string;
};

type Category = {
  name: string;
  knowledgeData: Knowledge[];
};

type DarkspawnClass = {
  path: string;
  name: string;
  description: string;
  long_description: string;
  color: string;
};

type Info = {
  willpower: number;
  lucidity_drained: number;
  required_succs: number;
  divulged: BooleanLike;
  ascended: BooleanLike;
  max_thralls: number;
  current_thralls: number;
  thrall_names: string[];
  has_class: BooleanLike;
  objectives: Objective[];
  categories: Category[];
  classData: DarkspawnClass[];
};

const CATEGORY_NAMES = {
  offense: 'Ofensywne',
  utility: 'Użytkowe',
  passives: 'Pasywne',
};

export const AntagInfoDarkspawn = (_props) => {
  const { data } = useBackend<Info>();
  const { divulged, has_class } = data;
  const [currentTab, setTab] = useLocalState('darkspawnTab', 0);

  return (
    <Window width={750} height={650} theme="darkspawn">
      <Window.Content>
        <Stack vertical fill>
          <Stack.Item>
            <Tabs fluid>
              <Tabs.Tab
                icon="info"
                selected={currentTab === 0}
                onClick={() => setTab(0)}
              >
                Informacje
              </Tabs.Tab>
              {!!divulged && !!has_class && (
                <Tabs.Tab
                  icon={currentTab === 1 ? 'book-open' : 'book'}
                  selected={currentTab === 1}
                  onClick={() => setTab(1)}
                >
                  Psi Web
                </Tabs.Tab>
              )}
              {!has_class && (
                <Tabs.Tab
                  icon="users"
                  selected={currentTab === 2}
                  onClick={() => setTab(2)}
                >
                  Wybór klasy
                </Tabs.Tab>
              )}
            </Tabs>
          </Stack.Item>
          <Stack.Item grow>
            {(currentTab === 1 && !!divulged && !!has_class && (
              <ResearchInfo />
            )) ||
              (currentTab === 2 && !has_class && (
                <ClassSelection setTab={setTab} />
              )) || <IntroductionSection />}
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const IntroductionSection = (_props) => {
  const { data } = useBackend<Info>();
  const { objectives, ascended } = data;
  return (
    <Stack vertical fill>
      <Stack.Item>
        <Section title="Jesteś darkspawnem!" fontSize="14px">
          <Stack vertical>
            <FlavorSection />
            <Stack.Divider />
            <GuideSection />
            <Stack.Divider />
            <InformationSection />
          </Stack>
        </Section>
      </Stack.Item>
      {!ascended && (
        <Stack.Item grow>
          <ObjectivesSection objectives={objectives} />
        </Stack.Item>
      )}
    </Stack>
  );
};

const FlavorSection = (_props) => {
  return (
    <Stack vertical textAlign="center" fontSize="14px">
      <i>
        <Stack.Item>
          Wieczność w uśpieniu, dryfując w{' '}
          <span style={Velvet}>bezkresnej pustce</span>.
        </Stack.Item>
        <Stack.Item>
          Fale zwiastują chaos, gdy{' '}
          <span style={Lucidity}>jasne niebieskie światło</span> wyrywa cię
          ze snu.
        </Stack.Item>
        <Stack.Item>
          Wpadając w zwykłą przestrzeń, gwałtownie{' '}
          <span style={Velvet}>przeklinasz</span> istotę, która to sprawiła.
        </Stack.Item>
        <Stack.Item>
          Szybko kleisz{' '}
          <span style={{ color: '#FF0000' }}>prymitywną podróbkę</span>{' '}
          okolicznych form życia.
        </Stack.Item>
        <Stack.Item>
          Długo nie wytrzyma, ale wystarczy, żeby oszukać tych głupców.
        </Stack.Item>
      </i>
      <Stack.Item fontSize="20px">
        <b>
          <span style={Velvet}>Pustka</span> czeka na twój powrót.
        </b>
      </Stack.Item>
    </Stack>
  );
};

const GuideSection = (_props) => {
  const { data } = useBackend<Info>();
  const { divulged, has_class } = data;
  return (
    <Stack vertical fontSize="14px">
      <Stack.Item>
        - Współpracuj z innymi darkspawnami. Rozmawiasz z nimi przez Mindlink
        po :j.
      </Stack.Item>
      {!has_class && (
        <Stack.Item>
          - Wybierz klasę w zakładce wyboru klasy. Od niej zależy, jak będziesz
          grać.
        </Stack.Item>
      )}
      {!divulged && (
        <Stack.Item>
          - Gdy będziesz gotowy, schowaj się w ustronnym miejscu i zrzuć skórę
          (Divulge). Dopiero wtedy w zakładce Psi Web nauczysz się nowych
          zdolności.
        </Stack.Item>
      )}
      <Stack.Item>
        - Obezwładniaj załogę i pożeraj jej wolę, żeby zdobywać{' '}
        <span style={Lucidity}>jasność</span> i{' '}
        <span style={Velvet}>wolę</span>.
      </Stack.Item>
      <Stack.Item>
        - Wydawaj <span style={Velvet}>wolę</span> w Psi Web na nowe zdolności
        i ulepszenia.
      </Stack.Item>
      <Stack.Item>
        - Gdy zbierzesz dość <span style={Lucidity}>jasności</span>, odpraw
        Sakrament i wznieś się jako potomek.
      </Stack.Item>
    </Stack>
  );
};

const InformationSection = (_props) => {
  const { data } = useBackend<Info>();
  const {
    willpower,
    lucidity_drained,
    required_succs,
    ascended,
    current_thralls,
    max_thralls,
    thrall_names = [],
  } = data;
  return (
    <Stack vertical>
      {!!ascended && (
        <Stack.Item fontSize="24px">
          <Box inline color="yellow">
            WZNIESIONY!
          </Box>
        </Stack.Item>
      )}
      <Stack.Item>
        Masz <b>{willpower || 0}</b> <span style={Velvet}>woli</span>.
      </Stack.Item>
      <Stack.Item>
        Drużyna zebrała <b>{lucidity_drained || 0}</b> /{' '}
        <b>{required_succs || 0}</b> <span style={Lucidity}>jasności</span>.
      </Stack.Item>
      {!!max_thralls && (
        <Stack.Item>
          Thralle:{' '}
          <b>
            {current_thralls || 0}/{max_thralls}
          </b>
          {thrall_names.length > 0 && ` (${thrall_names.join(', ')})`}
        </Stack.Item>
      )}
    </Stack>
  );
};

const ResearchInfo = (_props) => {
  const { act, data } = useBackend<Info>();
  const { willpower } = data;
  const [selectedKnowledge, setSelectedKnowledge] =
    useLocalState<Knowledge | null>('darkspawnKnowledge', null);

  return (
    <Stack vertical fill>
      <Stack.Item fontSize="18px" textAlign="center">
        Masz <b>{willpower || 0}</b> <span style={Velvet}>woli</span> do
        wydania.
      </Stack.Item>
      <Stack.Item grow>
        <Stack fill>
          <Stack.Item grow basis={0}>
            <MenuTabs />
          </Stack.Item>
          <Stack.Item grow basis={0}>
            <Stack fill vertical>
              <Stack.Item grow>
                <KnowledgePreview />
              </Stack.Item>
              {!!selectedKnowledge && (
                <Stack.Item>
                  <Button
                    fluid
                    textAlign="center"
                    fontSize="16px"
                    disabled={selectedKnowledge.disabled}
                    color={selectedKnowledge.disabled ? 'grey' : 'green'}
                    onClick={() => {
                      act('purchase', {
                        upgrade_path: selectedKnowledge.path,
                      });
                      if (!selectedKnowledge.infinite) {
                        setSelectedKnowledge(null);
                      }
                    }}
                  >
                    {selectedKnowledge.disabled ? 'Za mało woli' : 'Kup'}
                  </Button>
                </Stack.Item>
              )}
            </Stack>
          </Stack.Item>
        </Stack>
      </Stack.Item>
    </Stack>
  );
};

const MenuTabs = (_props) => {
  const { data } = useBackend<Info>();
  const { categories = [] } = data;
  const [selectedCategoryName, setSelectedCategoryName] = useLocalState(
    'darkspawnCategory',
    categories[0]?.name,
  );
  const [selectedKnowledge, setSelectedKnowledge] =
    useLocalState<Knowledge | null>('darkspawnKnowledge', null);
  const selectedCategory =
    categories.find((category) => category.name === selectedCategoryName) ||
    categories[0];

  return (
    <Section fill scrollable>
      <Tabs fluid>
        {categories.map((category) => (
          <Tabs.Tab
            key={category.name}
            selected={category.name === selectedCategory?.name}
            onClick={() => setSelectedCategoryName(category.name)}
          >
            {CATEGORY_NAMES[category.name] || category.name}
          </Tabs.Tab>
        ))}
      </Tabs>
      <Tabs vertical>
        {(selectedCategory?.knowledgeData || []).map((knowledge) => (
          <Tabs.Tab
            key={knowledge.path}
            selected={selectedKnowledge?.path === knowledge.path}
            onClick={() => setSelectedKnowledge(knowledge)}
          >
            {knowledge.name} ({knowledge.cost})
          </Tabs.Tab>
        ))}
      </Tabs>
    </Section>
  );
};

const KnowledgePreview = (_props) => {
  const [selectedKnowledge] = useLocalState<Knowledge | null>(
    'darkspawnKnowledge',
    null,
  );
  if (!selectedKnowledge) {
    return (
      <Section fill>
        <Box textAlign="center" fontSize="16px" color="gold">
          Wybierz, czego chcesz się nauczyć.
        </Box>
      </Section>
    );
  }
  return (
    <Section fill scrollable title={selectedKnowledge.name}>
      <Stack vertical textAlign="center" fontSize="15px">
        <Stack.Item color="purple">
          Koszt w woli: {selectedKnowledge.cost}
        </Stack.Item>
        {!!selectedKnowledge.icon && (
          <Stack.Item>
            <Box
              as="img"
              src={`data:image/png;base64,${selectedKnowledge.icon}`}
              height="128px"
              style={{
                background:
                  'radial-gradient(circle, rgb(114, 100, 255) 0%, rgb(33, 0, 127) 100%)',
                imageRendering: 'pixelated',
              }}
            />
          </Stack.Item>
        )}
        <Stack.Item color="gold">{selectedKnowledge.desc}</Stack.Item>
        <Stack.Item style={Velvet} fontSize="13px">
          {selectedKnowledge.lore_description}
        </Stack.Item>
        {!!selectedKnowledge.infinite && (
          <Stack.Item fontSize="12px" color="purple">
            Można kupić wiele razy
          </Stack.Item>
        )}
      </Stack>
    </Section>
  );
};

type ClassSelectionProps = {
  setTab: (tab: number) => void;
};

const ClassSelection = (props: ClassSelectionProps) => {
  const { act, data } = useBackend<Info>();
  const { classData = [] } = data;
  return (
    <Stack fill align="center" justify="space-evenly">
      {classData.map((darkspawnClass) => (
        <Stack.Item key={darkspawnClass.path} grow basis={0}>
          <Section fill textAlign="center">
            <Stack vertical fill>
              <Stack.Item fontSize="20px" color={darkspawnClass.color}>
                {darkspawnClass.name}
              </Stack.Item>
              <Stack.Item fontSize="15px">
                {darkspawnClass.description}
              </Stack.Item>
              <Stack.Item grow fontSize="13px" style={Velvet}>
                {darkspawnClass.long_description}
              </Stack.Item>
              <Stack.Item>
                <Button
                  fluid
                  fontSize="18px"
                  onClick={() => {
                    act('select', { class_path: darkspawnClass.path });
                    props.setTab(0);
                  }}
                >
                  Wybierz
                </Button>
              </Stack.Item>
            </Stack>
          </Section>
        </Stack.Item>
      ))}
    </Stack>
  );
};
