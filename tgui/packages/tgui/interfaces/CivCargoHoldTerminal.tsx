// AQUILA - konsola zleceń cywilnych, port z tgstation
import { BooleanLike } from 'common/react';
import { useState } from 'react';
import {
  Box,
  Button,
  LabeledList,
  NoticeBox,
  ProgressBar,
  Section,
  Stack,
  Tabs,
  Tooltip,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type BountyPick = {
  name: string;
  description: string;
  value: number;
};

type SingleBounty = {
  name: string;
  description: string;
  reward: number;
  shipped: number;
  claimed: BooleanLike;
  maximum: number;
  priority: BooleanLike;
  unique: BooleanLike;
  ref: string;
};

type Data = {
  pad: BooleanLike;
  sending: BooleanLike;
  status_report: string;
  picking: BooleanLike;
  id_inserted: BooleanLike;
  id_bounty_info?: string;
  id_bounty_value?: number;
  id_bounty_num?: string;
  id_bounty_picks?: BountyPick[];
  listBounty: SingleBounty[];
  claimed_bounties: number;
  cut_percent: number;
};

export const CivCargoHoldTerminal = (props) => {
  const { data } = useBackend<Data>();
  const { id_inserted } = data;
  const [tab, setTab] = useState('personal');

  return (
    <Window title="Zlecenia cywilne" width={620} height={420}>
      <Window.Content scrollable>
        <Section>
          <Tabs fluid>
            <Tabs.Tab
              icon="user"
              selected={tab === 'personal'}
              onClick={() => setTab('personal')}
            >
              Zlecenia osobiste
            </Tabs.Tab>
            <Tabs.Tab
              icon="space-shuttle"
              selected={tab === 'station'}
              onClick={() => setTab('station')}
            >
              Zlecenia statku
            </Tabs.Tab>
          </Tabs>
        </Section>
        <NoticeBox color={id_inserted ? 'blue' : undefined}>
          {id_inserted
            ? 'Witaj, ceniony pracowniku.'
            : 'Aby zacząć, włóż kartę identyfikacyjną do konsoli.'}
        </NoticeBox>
        {tab === 'personal' ? <PersonalBountyBlock /> : <GlobalBountyBlock />}
      </Window.Content>
    </Window>
  );
};

const PersonalBountyBlock = (props) => {
  const { act, data } = useBackend<Data>();
  const { pad, sending, status_report, id_inserted, id_bounty_info, picking } =
    data;
  return (
    <>
      <Section
        title="Pad zleceń"
        buttons={
          <>
            <Button
              icon="sync"
              tooltip="Sprawdź zawartość padu"
              disabled={!pad || !id_inserted}
              onClick={() => act('recalc')}
            />
            <Button
              icon={sending ? 'times' : 'arrow-up'}
              tooltip={sending ? 'Przerwij wysyłkę' : 'Wyślij przedmioty'}
              selected={sending}
              disabled={!pad || !id_inserted}
              onClick={() => act(sending ? 'stop' : 'send')}
            />
            <Button
              icon={id_bounty_info ? 'recycle' : 'pen'}
              color={id_bounty_info ? 'green' : undefined}
              tooltip={id_bounty_info ? 'Zmień zlecenie' : 'Nowe zlecenie'}
              disabled={!id_inserted}
              onClick={() => act('bounty')}
            />
            <Button
              icon="eject"
              disabled={!id_inserted}
              onClick={() => act('eject')}
            >
              Wyjmij kartę
            </Button>
          </>
        }
      >
        <LabeledList>
          <LabeledList.Item label="Status" color={pad ? 'good' : 'bad'}>
            {pad ? 'Połączono' : 'Nie znaleziono padu'}
          </LabeledList.Item>
          <LabeledList.Item label="Raport">{status_report}</LabeledList.Item>
        </LabeledList>
      </Section>
      {picking ? <BountyPickBox /> : <BountyTextBox />}
    </>
  );
};

const BountyTextBox = (props) => {
  const { data } = useBackend<Data>();
  const { id_bounty_info, id_bounty_value, id_bounty_num } = data;
  return (
    <Section title="Twoje zlecenie">
      <LabeledList>
        <LabeledList.Item label="Opis">
          {id_bounty_info ? (
            <Box dangerouslySetInnerHTML={{ __html: id_bounty_info }} />
          ) : (
            'Brak, weź nowe zlecenie.'
          )}
        </LabeledList.Item>
        <LabeledList.Item label="Postęp">
          {id_bounty_info ? id_bounty_num : '-'}
        </LabeledList.Item>
        <LabeledList.Item label="Twoja wypłata">
          {id_bounty_info ? `${id_bounty_value} kr` : '-'}
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};

const BountyPickBox = (props) => {
  const { act, data } = useBackend<Data>();
  const picks = data.id_bounty_picks || [];
  return (
    <Section title="Wybierz zlecenie:" textAlign="center">
      <Stack>
        {picks.map((pick, index) => (
          <Stack.Item key={index} grow basis={0}>
            <Button
              fluid
              color="green"
              onClick={() => act('pick', { value: index + 1 })}
              style={{ whiteSpace: 'normal' }}
            >
              <Box bold>{pick.name}</Box>
              <Box
                textAlign="left"
                color="black"
                backgroundColor="linen"
                lineHeight="1.2em"
                p={1}
              >
                <Box dangerouslySetInnerHTML={{ __html: pick.description }} />
              </Box>
              <Box>Wypłata: {pick.value} kr</Box>
            </Button>
          </Stack.Item>
        ))}
      </Stack>
    </Section>
  );
};

const GlobalBountyBlock = (props) => {
  const { act, data } = useBackend<Data>();
  const {
    listBounty = [],
    sending,
    pad,
    id_inserted,
    claimed_bounties,
    cut_percent,
  } = data;
  const [selectedRef, setSelectedRef] = useState<string | null>(null);
  const selected = listBounty.find((bounty) => bounty.ref === selectedRef);

  return (
    <Stack>
      <Stack.Item width="35%">
        <Tabs vertical fluid>
          {listBounty.length < 1 ? (
            <Tabs.Tab icon="sync" onClick={() => act('update_list')}>
              Pobierz listę zleceń
            </Tabs.Tab>
          ) : (
            <Tabs.Tab>
              <Tooltip content="Co 3 ukończone zlecenia statku lista rośnie o jedno zlecenie!">
                <Box>Ukończone zlecenia: {claimed_bounties}</Box>
              </Tooltip>
            </Tabs.Tab>
          )}
          <Tabs.Tab icon="print" onClick={() => act('print')}>
            Wydrukuj listę
          </Tabs.Tab>
          {listBounty.map((bounty) => (
            <Tabs.Tab
              key={bounty.ref}
              icon={
                bounty.priority ? 'star' : bounty.unique ? 'gem' : undefined
              }
              color={
                bounty.priority ? 'yellow' : bounty.unique ? 'teal' : undefined
              }
              selected={bounty.ref === selectedRef}
              onClick={() => setSelectedRef(bounty.ref)}
            >
              {bounty.name}
            </Tabs.Tab>
          ))}
        </Tabs>
      </Stack.Item>
      <Stack.Item grow>
        {selected ? (
          <Section title={selected.name}>
            <ProgressBar value={selected.shipped} maxValue={selected.maximum}>
              {selected.shipped} / {selected.maximum} wysłano
            </ProgressBar>
            <Box
              p={1}
              dangerouslySetInnerHTML={{ __html: selected.description }}
            />
            <Box p={1} my={1} backgroundColor="green" color="white">
              <Tooltip
                content={`Wykonawcy dostaną ${Math.round(
                  (selected.reward * cut_percent) / 100,
                )} kr.`}
              >
                <b>Nagroda:</b> {selected.reward} kr
              </Tooltip>
            </Box>
            <Button
              fluid
              icon={sending ? 'times' : 'arrow-up'}
              selected={sending}
              disabled={!pad || !id_inserted}
              onClick={() => act(sending ? 'stop' : 'send_global')}
            >
              {sending ? 'Przerwij wysyłkę' : 'Wyślij i odbierz'}
            </Button>
          </Section>
        ) : (
          <NoticeBox>Wybierz zlecenie z listy.</NoticeBox>
        )}
      </Stack.Item>
    </Stack>
  );
};
