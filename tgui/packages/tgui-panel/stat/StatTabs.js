import { useDispatch, useSelector } from 'tgui/backend';
import {
  Button,
  Divider,
  Flex,
  Icon,
  Input,
  ScrollableBox,
  Section,
  Tabs,
} from 'tgui/components';

import { useSettings } from '../settings';
import { selectStatPanel } from './selectors';
import { StatStatus } from './StatStatus';
import { findVerbs, StatText } from './StatText';
import { StatTicket } from './StatTicket';
import { translateTab } from './translations';

// =======================
// Flex Supported
// =======================

export const StatTabs = (props) => {
  const stat = useSelector(selectStatPanel);
  const settings = useSettings();
  let statSection = <StatText />;
  switch (stat.selectedTab) {
    case 'Status':
      statSection = <StatStatus />;
      break;
    case '(!) Admin PM':
      statSection = <StatTicket />;
      break;
  }
  return (
    <>
      <Flex.Item shrink={0}>
        <div className="StatTabBackground">
          {settings.statTabMode === 'Scroll' ? (
            <StatTabScroll />
          ) : (
            <StatTabWrap />
          )}
        </div>
      </Flex.Item>
      {stat.selectedTab !== '(!) Admin PM' && (
        <Flex.Item shrink={0}>
          <StatVerbSearch />
        </Flex.Item>
      )}
      <ScrollableBox overflowY="scroll" height="100%">
        <div className="StatBackground">
          <Flex.Item mt={1}>{statSection}</Flex.Item>
        </div>
      </ScrollableBox>
      {stat.selectedTab === '(!) Admin PM' && (
        <>
          <Divider />
          <Input
            fluid
            selfClear
            onEnter={(e, value) =>
              Byond.sendMessage('stat/pressed', {
                action_id: 'ticket_message',
                params: {
                  msg: value,
                },
              })
            }
          />
        </>
      )}
    </>
  );
};

const StatVerbSearch = (props) => {
  const stat = useSelector(selectStatPanel);
  const dispatch = useDispatch();
  const search = stat.verbSearch || '';
  const setSearch = (value) =>
    dispatch({
      type: 'stat/setVerbSearch',
      payload: value,
    });
  return (
    <div className="StatSearch">
      <Icon name="search" className="StatSearch__icon" />
      <Input
        fluid
        value={search}
        placeholder="Szukaj komendy we wszystkich zakładkach…"
        onInput={(e, value) => setSearch(value)}
        onEscape={(e) => {
          e.target.value = '';
          setSearch('');
        }}
        onEnter={(e, value) => {
          // Enter w trakcie kompozycji IME tylko zatwierdza znak.
          if (e.nativeEvent?.isComposing || e.isComposing) {
            return;
          }
          // Enter odpala komendę tylko, gdy wynik jest jednoznaczny.
          const results = findVerbs(stat.verbData, value);
          if (results.length !== 1) {
            return;
          }
          Byond.sendMessage('stat/pressed', {
            action_id: results[0].data.action,
            params: results[0].data.params || [],
          });
          e.target.value = '';
          setSearch('');
        }}
      />
      {!!search && (
        <Button
          className="StatSearch__clear"
          icon="times"
          color="transparent"
          tooltip="Wyczyść"
          onClick={() => setSearch('')}
        />
      )}
    </div>
  );
};

const selectTab = (dispatch, tab) => {
  dispatch({
    type: 'stat/setTab',
    payload: tab,
  });
  dispatch({
    type: 'stat/setVerbSearch',
    payload: '',
  });
};

export const StatTabScroll = (props) => {
  const stat = useSelector(selectStatPanel);
  const dispatch = useDispatch();
  // Map the input data into tabs, then filter out extra_data
  let statTabs = stat.statTabs;
  return (
    <Section fitted overflowX="auto">
      <Flex align="center">
        <Flex.Item>
          <Tabs textAlign="center">
            {statTabs.map((tab) => (
              <Tabs.Tab
                key={tab}
                selected={tab === stat.selectedTab}
                onClick={() => selectTab(dispatch, tab)}
              >
                {translateTab(tab)}
              </Tabs.Tab>
            ))}
          </Tabs>
        </Flex.Item>
      </Flex>
    </Section>
  );
};

export const StatTabWrap = (props) => {
  const stat = useSelector(selectStatPanel);
  const dispatch = useDispatch();
  // Map the input data into tabs, then filter out extra_data
  let statTabs = stat.statTabs;
  return (
    <Section overflowX="auto" className="StatTabWrap">
      {statTabs.map((tab) => (
        <Button
          key={tab}
          className="StatTab"
          color="transparent"
          selected={tab === stat.selectedTab}
          onClick={() => selectTab(dispatch, tab)}
        >
          {translateTab(tab)}
        </Button>
      ))}
    </Section>
  );
};
