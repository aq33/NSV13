import { capitalize } from 'common/string';
import { useSelector } from 'tgui/backend';
import { Box, Button, Flex } from 'tgui/components';

import { Divider } from '../../tgui/components';
import {
  STAT_ATOM,
  STAT_BLANK,
  STAT_BUTTON,
  STAT_DIVIDER,
  STAT_TEXT,
} from './constants';
import { selectStatPanel } from './selectors';
import { translateTab, translateVerb } from './translations';

const sortVerbs = (verbs) =>
  Object.keys(verbs).sort((a, b) =>
    translateVerb(a).localeCompare(translateVerb(b), 'pl'),
  );

// Do wyszukiwania: bez wielkości liter i polskich znaków, żeby „pokaz”
// znalazło „Pokaż”.
export const normalizeSearch = (text) =>
  String(text)
    .toLowerCase()
    .replace(/ł/g, 'l')
    .normalize('NFD')
    .replace(/[̀-ͯ]/g, '');

const verbMatches = (verb, query) =>
  normalizeSearch(translateVerb(verb)).includes(query) ||
  normalizeSearch(verb).includes(query);

/**
 * Komendy pasujące do wyszukiwania ze wszystkich zakładek,
 * posortowane po nazwie. Każdy wpis: { tab, verb, data }.
 */
export const findVerbs = (verbData, search) => {
  const query = normalizeSearch(search.trim());
  if (!query || !verbData) {
    return [];
  }
  const results = [];
  for (const tab of Object.keys(verbData)) {
    const verbs = verbData[tab] || {};
    for (const verb of Object.keys(verbs)) {
      if (verbMatches(verb, query)) {
        results.push({ tab, verb, data: verbs[verb] });
      }
    }
  }
  return results.sort((a, b) =>
    translateVerb(a.verb).localeCompare(translateVerb(b.verb), 'pl'),
  );
};

const renderStatEntry = (key, entry) => {
  if (!entry) {
    return null;
  }
  switch (entry.type) {
    case STAT_TEXT:
      return <StatTextText key={key} title={key} text={entry.text} />;
    case STAT_BUTTON:
      return (
        <StatTextButton
          key={key}
          title={key}
          text={entry.text}
          action_id={entry.action}
          params={entry.params}
          multirow={entry.multirow}
          buttons={entry.buttons}
        />
      );
    case STAT_ATOM:
      return (
        <StatTextAtom
          key={key}
          atom_ref={key}
          atom_name={entry.text}
          atom_tag={entry.tag}
          atom_icon={entry.image}
        />
      );
    case STAT_DIVIDER:
      return <StatTextDivider key={key} />;
    case STAT_BLANK:
      return (
        <Flex.Item key={key} width="100%">
          <br />
        </Flex.Item>
      );
  }
  return null;
};

export const StatText = (props) => {
  const stat = useSelector(selectStatPanel);
  let statPanelData = stat.statInfomation;
  if (!statPanelData) {
    return (
      <Box color="red">
        Passed stat panel data was null contant coderman (or coderwoman).
      </Box>
    );
  }
  if (stat.verbSearch && stat.verbSearch.trim()) {
    return <StatVerbSearchResults />;
  }
  let verbs = {};
  if (stat.verbData !== null) {
    verbs = stat.verbData[stat.selectedTab] || {};
  }
  const keys = Object.keys(statPanelData)
    .filter((x) => x !== null && !!statPanelData[x])
    .sort(
      (a, b) =>
        StatTagToPriority(statPanelData[b].tag) -
        StatTagToPriority(statPanelData[a].tag),
    );
  const verbNames = sortVerbs(verbs);
  return (
    <div className="StatBorder">
      {keys.length > 0 && (
        <Flex direction="row" wrap className="StatInfo">
          {keys.map((key) => renderStatEntry(key, statPanelData[key]))}
        </Flex>
      )}
      {verbNames.length > 0 && (
        <div className="StatVerbGrid">
          {verbNames.map((verb) => (
            <StatTextVerb
              key={verb}
              title={verb}
              action_id={verbs[verb].action}
              params={verbs[verb].params}
            />
          ))}
        </div>
      )}
      {keys.length === 0 && verbNames.length === 0 && (
        <Box className="StatEmpty">Brak danych</Box>
      )}
    </div>
  );
};

export const StatVerbSearchResults = (props) => {
  const stat = useSelector(selectStatPanel);
  const results = findVerbs(stat.verbData, stat.verbSearch);
  if (results.length === 0) {
    return (
      <div className="StatBorder">
        <Box className="StatEmpty">
          Brak komend pasujących do „{stat.verbSearch.trim()}”.
        </Box>
      </div>
    );
  }
  return (
    <div className="StatBorder">
      <Box className="StatSearchCount">
        Znaleziono: {results.length}
      </Box>
      <div className="StatVerbGrid StatVerbGrid--search">
        {results.map((result) => (
          <StatTextVerb
            key={result.tab + '/' + result.verb}
            title={result.verb}
            tab={result.tab}
            action_id={result.data.action}
            params={result.data.params}
          />
        ))}
      </div>
    </div>
  );
};

const StatTagToPriority = (text) => {
  switch (text) {
    case 'You':
      return 11;
    case 'Human':
      return 10;
    case 'Mob':
      return 9;
    case 'Structure':
      return 8;
    case 'Machinery':
      return 7;
    case 'Item':
      return 6;
    case 'Turf':
      return 4;
  }
  return 5;
};

const StatTagToClassName = (text) => {
  switch (text) {
    case 'You':
      return 'StatAtomTag Self';
    case 'Turf':
      return 'StatAtomTag Turf';
    case 'Human':
      return 'StatAtomTag Human';
    case 'Mob':
      return 'StatAtomTag Mob';
    case 'Structure':
      return 'StatAtomTag Structure';
    case 'Machinery':
      return 'StatAtomTag Machinery';
    case 'Item':
      return 'StatAtomTag Item';
  }
  return 'StatAtomTag Other';
};

/*
 * FLEX COMPATIBLE
 */

export const StatTextText = (props) => {
  const { title, text } = props;
  return (
    <Flex.Item width="100%" className="StatInfoRow">
      <span className="StatInfoLabel">{title}</span>
      <span className="StatInfoValue">{text}</span>
    </Flex.Item>
  );
};

export const StatTextButton = (props) => {
  const {
    title,
    text,
    action_id,
    params = [],
    multirow = false,
    buttons = [],
  } = props;
  return (
    <Flex.Item mt={1} width="100%">
      <Button
        width="100%"
        overflowX="hidden"
        onClick={() =>
          Byond.sendMessage('stat/pressed', {
            action_id: action_id,
            params: params,
          })
        }
        color="transparent"
      >
        {!multirow ? (
          <Flex direction="row">
            <Flex.Item bold>{title}</Flex.Item>
            {buttons.map((buttonInfo) => (
              <Flex.Item shrink={1} key={buttonInfo}>
                <Button
                  color={buttonInfo['color']}
                  onClick={(e) => {
                    e.stopPropagation();
                    Byond.sendMessage('stat/pressed', {
                      action_id: buttonInfo['action_id'],
                      params: buttonInfo['params'],
                    });
                  }}
                >
                  {buttonInfo['title']}
                </Button>
              </Flex.Item>
            ))}
            <Flex.Item
              grow={1}
              ml={1.5}
              style={{
                whiteSpace: 'normal',
              }}
            >
              {text}
            </Flex.Item>
          </Flex>
        ) : (
          <>
            <Flex bold direction="row">
              <Flex.Item grow={1}>{title}</Flex.Item>
              {buttons.map((buttonInfo) => (
                <Flex.Item shrink={1} key={buttonInfo}>
                  <Button
                    color={buttonInfo['color']}
                    onClick={(e) => {
                      e.stopPropagation();
                      Byond.sendMessage('stat/pressed', {
                        action_id: buttonInfo['action_id'],
                        params: buttonInfo['params'],
                      });
                    }}
                  >
                    {buttonInfo['title']}
                  </Button>
                </Flex.Item>
              ))}
            </Flex>
            <Box
              style={{
                whiteSpace: 'normal',
              }}
            >
              {text}
            </Box>
          </>
        )}
      </Button>
    </Flex.Item>
  );
};

let janky_storage = null; // Because IE sucks
const storeAtomRef = (value) => {
  janky_storage = value;
};
const retrieveAtomRef = () => janky_storage;

export const StatTextAtom = (props) => {
  const { atom_name, atom_ref, atom_tag, atom_icon } = props;

  storeAtomRef(null);

  return (
    <Flex.Item mt={0.5} width={'33%'}>
      <Button
        height="100%"
        pl={0}
        width="100%"
        overflowX="hidden"
        draggable
        onDragStart={(e) => {
          // e.dataTransfer.setData("text", atom_ref);
          /*
          Apparently can't use "text/plain" because IE, this took me way too
          long to figure out.

          Apparently, even if you do "text", IE will also put the stored data
          into your clipboard, overriding whatever was there. Fuck this.
          Leaving it here for reference, in case somebody smarter than me
          knows a way to fix it
          */
          storeAtomRef(atom_ref);
        }}
        onDragOver={(e) => {
          e.preventDefault();
        }}
        onDrop={(e) => {
          // let other_atom_ref = e.dataTransfer.getData("text");
          let other_atom_ref = retrieveAtomRef();
          if (other_atom_ref) {
            e.preventDefault();
            storeAtomRef(null);
            Byond.sendMessage('stat/pressed', {
              action_id: 'atomDrop',
              params: {
                ref: atom_ref,
                ref_other: other_atom_ref,
              },
            });
          }
        }}
        onDragEnd={(e) => {
          storeAtomRef(null);
        }}
        onClick={(e) =>
          Byond.sendMessage('stat/pressed', {
            action_id: 'atomClick',
            params: {
              ref: atom_ref,
            },
          })
        }
        color="transparent"
      >
        <div className="StatAtomElement">
          <Flex direction="row" wrap="wrap">
            {
              <Flex.Item mr={1}>
                <img width="32px" height="32px" src={atom_icon} />
              </Flex.Item>
            }
            <Flex.Item grow={1} className="StatWordWrap">
              {capitalize(atom_name)}
            </Flex.Item>
          </Flex>
        </div>
      </Button>
    </Flex.Item>
  );
};

export const StatTextDivider = (props) => {
  return (
    <Flex.Item width="100%">
      <Divider />
    </Flex.Item>
  );
};

export const StatTextVerb = (props) => {
  const { title, tab, action_id, params = [] } = props;
  const name = translateVerb(title);
  const hint = name === title ? name : name + ' (' + title + ')';
  const onClick = () =>
    Byond.sendMessage('stat/pressed', {
      action_id: action_id,
      params: params,
    });
  if (!tab) {
    return (
      <div className="StatVerb">
        <Button
          tooltip={hint}
          ellipsis
          onClick={onClick}
          color="transparent"
          fluid
        >
          {name}
        </Button>
      </div>
    );
  }
  return (
    <div className="StatVerb StatVerb--tagged">
      <Button
        tooltip={translateTab(tab) + ' › ' + hint}
        onClick={onClick}
        color="transparent"
        fluid
      >
        <span className="StatVerbName">{name}</span>
        <span className="StatVerbTab">{translateTab(tab)}</span>
      </Button>
    </div>
  );
};
