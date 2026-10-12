import { classes } from 'common/react';
import {
  Box,
  Button,
  Flex,
  LabeledList,
  Section,
  Table,
  Tabs,
} from 'tgui-core/components';

import { useBackend, useLocalState } from '../backend';
import { Window } from '../layouts';

type Data = {
  time_remaining: number;
  upper_admin: any;
  choices: any;
  lower_admin: any;
  mapInfo: any;
  mapvote_banned: any;
  mode: any;
  question: any;
  selectedChoice: any;
};

export const MapVote = (props) => {
  const { act, data } = useBackend<Data>();
  const {
    mode,
    question,
    lower_admin,
    choices,
    selectedChoice,
    mapvote_banned,
  } = data;
  const [selectedChoiceIndex, setSelectedChoiceIndex] = useLocalState<any>(
    'choice',
    undefined,
  );
  const [selectedChoiceName, setSelectedChoiceName] = useLocalState<any>(
    'choiceName',
    undefined,
  );

  return (
    <Window
      theme="generic"
      title={`Vote${
        mode
          ? `: ${
              question
                ? question.replace(/^\w/, (c) => c.toUpperCase())
                : mode.replace(/^\w/, (c) => c.toUpperCase())
            }`
          : ''
      }`}
      width={800}
      height={600}
    >
      <Window.Content overflowY="scroll">
        <TimePanel />
        <Flex>
          <Flex.Item mt={1} mr={1} mb={1}>
            <Section fill fitted>
              <Tabs vertical>
                {choices.map((choice, i) => (
                  <Tabs.Tab
                    key={i}
                    selected={i === selectedChoiceIndex}
                    icon={i === selectedChoice - 1 ? 'vote-yea' : ''}
                    onClick={() => {
                      setSelectedChoiceIndex(i);
                      setSelectedChoiceName(choice.name);
                    }}
                  >
                    {choice.name} ({choice.votes})
                  </Tabs.Tab>
                ))}
              </Tabs>
              <Button
                fluid
                disabled={mapvote_banned === 1}
                onClick={() => {
                  act('vote', {
                    index: selectedChoiceIndex + 1,
                  });
                }}
              >
                Vote
              </Button>
            </Section>
          </Flex.Item>
          <MapData />
        </Flex>
      </Window.Content>
    </Window>
  );
};

const MapData = (props) => {
  const { data } = useBackend<Data>();
  const { mapInfo } = data;
  const [selectedChoiceName, setSelectedChoiceName] = useLocalState<any>(
    'choiceName',
    undefined,
  );
  const selectedChoiceData = (mapInfo && mapInfo[selectedChoiceName]) || [];

  return (
    <Flex.Item position="relative" mt={1} mb={1} grow={1} basis={0}>
      <Section
        title={
          !!selectedChoiceName &&
          selectedChoiceName + ' by ' + selectedChoiceData.mapper
        }
      >
        {!!selectedChoiceName && (
          <>
            <Section>
              {/* Top left - Icon or image */}
              <Flex direction="row">
                <Flex.Item m={1}>
                  {selectedChoiceData.img ? (
                    <img
                      src={`data:image/jpeg;base64,${selectedChoiceData.img}`}
                      style={{
                        verticalAlign: 'middle',
                      }}
                    />
                  ) : (
                    <span
                      className={classes([
                        'ship32x32',
                        selectedChoiceData.path,
                      ])}
                      style={{
                        verticalAlign: 'middle',
                      }}
                    />
                  )}
                </Flex.Item>
                {/* Top right - class, manufacturer, design date */}
                <Flex.Item m={1} mb={5} grow={1}>
                  <LabeledList>
                    <LabeledList.Item label="Ship Class">
                      {selectedChoiceData.shipClass}
                    </LabeledList.Item>
                    <LabeledList.Item label="Manufacturer">
                      {selectedChoiceData.manufacturer}
                    </LabeledList.Item>
                    <LabeledList.Item label="Pattern Commission Date">
                      {selectedChoiceData.patternDate}
                    </LabeledList.Item>
                  </LabeledList>
                </Flex.Item>
              </Flex>
              {/* Description */}
              {selectedChoiceData.description}
            </Section>
            <Table>
              {/* Middle - pros and cons */}
              <Table.Row>
                <Table.Cell>
                  <Section title="Strengths">
                    {!!selectedChoiceData.strengths && (
                      <ul>
                        {selectedChoiceData.strengths.map((strength) => (
                          <li key={strength}>{strength}</li>
                        ))}
                      </ul>
                    )}
                  </Section>
                </Table.Cell>
                <Table.Cell>
                  <Section title="Weaknesses">
                    {!!selectedChoiceData.weaknesses && (
                      <ul>
                        {selectedChoiceData.weaknesses.map((weakness) => (
                          <li key={weakness}>{weakness}</li>
                        ))}
                      </ul>
                    )}
                  </Section>
                </Table.Cell>
              </Table.Row>
              {/* Loadout and stats */}
              <Table.Row>
                <Table.Cell>
                  <Section title="Equipment">
                    {!!selectedChoiceData.equipment &&
                      selectedChoiceData.equipment.map((thing) => (
                        <>
                          {thing}
                          <br />
                        </>
                      ))}
                  </Section>
                </Table.Cell>
                <Table.Cell>
                  <Section title="Performance History">
                    Missions completed: {selectedChoiceData.successRate}
                    <br />
                    Ships evacuated: {selectedChoiceData.evacRate}
                    <br />
                    On eternal patrol: {selectedChoiceData.lossRate}
                    <br />
                    <br />
                    Engine stability: {selectedChoiceData.engineStability}
                    <br />
                    Hull durability: {selectedChoiceData.durability}
                  </Section>
                </Table.Cell>
              </Table.Row>
            </Table>
          </>
        )}
      </Section>
    </Flex.Item>
  );
};

// AQUILA: was imported from the old Vote window, which VotePanel (BeeStation #13247) replaced
const TimePanel = (props) => {
  const { act, data } = useBackend<Data>();
  const { lower_admin, time_remaining } = data;

  return (
    <Flex.Item>
      <Section>
        <Flex justify="space-between">
          {!!lower_admin && (
            <Button onClick={() => act('cancel')} color="red">
              Cancel Vote
            </Button>
          )}
          <Box fontSize={1.5} textAlign="right">
            Time Remaining: {time_remaining}s
          </Box>
        </Flex>
      </Section>
    </Flex.Item>
  );
};
