import { classes } from 'common/react';
import { useBackend, useLocalState } from '../backend';
import { Button, Flex, LabeledList, Section, Tabs, Table,
  Box,
  Icon,
  Collapsible,
} from '../components';
import { Window } from '../layouts';
import { AdminPanel, TimePanel } from './Vote.js';

export const MapVote = (props, context) => {
  const { act, data } = useBackend(context);
  const { mode, question, lower_admin, choices, selectedChoice, mapvote_banned } = data;
  const [
    selectedChoiceIndex,
    setSelectedChoiceIndex,
  ] = useLocalState(context, 'choice');
  const [
    selectedChoiceName,
    setSelectedChoiceName,
  ] = useLocalState(context, 'choiceName');

  return (
    <Window
      theme="generic"
      title={`Vote${
        mode
          ? `: ${
            question
              ? question.replace(/^\w/, c => c.toUpperCase())
              : mode.replace(/^\w/, c => c.toUpperCase())
          }`
          : ""
      }`}
      width={800}
      height={600} >
      <Window.Content overflowY="scroll">
        {!!lower_admin && <AdminPanel />}
        <TimePanel />
        <PacePanel />
        <Flex>
          <Flex.Item mt={1} mr={1} mb={1}>
            <Section fill fitted>
              <Tabs vertical>
                {choices.map((choice, i) => (
                  <Tabs.Tab
                    key={i}
                    selected={i === selectedChoiceIndex}
                    icon={i === (selectedChoice-1) ? "vote-yea" : ""}
                    onclick={() => {
                      setSelectedChoiceIndex(i);
                      setSelectedChoiceName(choice.name);
                    }}>
                    {choice.name} ({choice.votes})
                  </Tabs.Tab>
                ))}
              </Tabs>
              <Button fluid
                disabled={mapvote_banned === 1}
                onClick={() => {
                  act("vote", {
                    index: selectedChoiceIndex+1,
                  });
                }}>
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

// AQUILA - "Dynamika rundy" vote of the weighted rotation (aquila/code/modules/weighted/weighted_pace_vote.dm)
const PACE_OPTIONS = [
  { value: -1, key: 'less', label: 'Mniej zagrożeń', icon: 'dove' },
  { value: 0, key: 'same', label: 'Jest dobrze', icon: 'thumbs-up' },
  { value: 1, key: 'more', label: 'Więcej zagrożeń', icon: 'skull' },
];

const PacePanel = (props, context) => {
  const { act, data } = useBackend(context);
  const { pace_open, pace_can_vote, pace_choice, pace_counts } = data;
  if (!pace_open) {
    return null;
  }
  return (
    <Section mt={1} title="Dynamika rundy">
      <Box mb={1}>
        Jakich następnych rund chcesz? Głos zmienia szanse spokojniejszych
        i groźniejszych trybów w kolejnych rundach.
      </Box>
      <Flex>
        {PACE_OPTIONS.map(option => (
          <Flex.Item key={option.key} grow={1} basis={0} mx={0.5}>
            <Button
              fluid
              textAlign="center"
              icon={option.icon}
              selected={pace_choice === option.value}
              disabled={!pace_can_vote}
              onClick={() => act('pace_vote', { value: option.value })}>
              {option.label} ({pace_counts ? pace_counts[option.key] : 0})
            </Button>
          </Flex.Item>
        ))}
      </Flex>
      {!pace_can_vote && (
        <Box mt={1} color="label">
          Głosować mogą tylko gracze, którzy grali postacią w tej rundzie.
        </Box>
      )}
    </Section>
  );
};

const MapData = (props, context) => {
  const { data } = useBackend(context);
  const { mapInfo } = data;
  const [
    selectedChoiceName,
    setSelectedChoiceName,
  ] = useLocalState(context, 'choiceName');
  const selectedChoiceData = mapInfo && mapInfo[selectedChoiceName] || [];

  return (
    <Flex.Item
      position="relative"
      mt={1}
      mb={1}
      grow={1}
      basis={0}>
      <Section title={!!selectedChoiceName && (selectedChoiceName + " by " + selectedChoiceData.mapper)}>
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
                        'vertical-align': 'middle',
                        'horizontal-align': 'middle',
                      }} />
                  ) : (
                    <span
                      className={classes([
                        'ship32x32',
                        selectedChoiceData.path,
                      ])}
                      style={{
                        'vertical-align': 'middle',
                        'horizontal-align': 'middle',
                      }} />
                  )}
                </Flex.Item>
                {/* Top right - class, manufacturer, design date */}
                <Flex.Item m={1} mb={5} grow={1}>
                  <LabeledList collapsing>
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
                        {selectedChoiceData.strengths.map(strength => (
                          <li key={strength}>
                            {strength}
                          </li>
                        ))}
                      </ul>
                    )}
                  </Section>
                </Table.Cell>
                <Table.Cell>
                  <Section title="Weaknesses">
                    {!!selectedChoiceData.weaknesses && (
                      <ul>
                        {selectedChoiceData.weaknesses.map(weakness => (
                          <li key={weakness}>
                            {weakness}
                          </li>
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
                    {!!selectedChoiceData.equipment && selectedChoiceData.equipment.map(thing => (
                      <>
                        {thing}<br />
                      </>
                    ))}
                  </Section>
                </Table.Cell>
                <Table.Cell>
                  <Section title="Performance History">
                    Missions completed: {selectedChoiceData.successRate}<br />
                    Ships evacuated: {selectedChoiceData.evacRate}<br />
                    On eternal patrol: {selectedChoiceData.lossRate}<br />
                    <br />
                    Engine stability: {selectedChoiceData.engineStability}<br />
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
