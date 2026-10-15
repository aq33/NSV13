// AQUILA - konsola zarządzania więźniami (aquila/code/game/machinery/computer/prisoner_management_ui.dm)
import {
  Box,
  Button,
  LabeledList,
  NoticeBox,
  ProgressBar,
  Section,
  Table,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type PrisonerId = {
  name: string;
  points: number;
  goal: number;
  permanent: boolean;
};

type ChemImplant = {
  name: string;
  volume: number;
  ref: string;
};

type TrackingImplant = {
  name: string;
  location: string;
  ref: string;
};

type Data = {
  logged_in: boolean;
  prisoner_id: PrisonerId | null;
  chem_implants: ChemImplant[];
  tracking_implants: TrackingImplant[];
};

export const PrisonerManagement = (_) => {
  const { act, data } = useBackend<Data>();
  const {
    logged_in,
    prisoner_id,
    chem_implants = [],
    tracking_implants = [],
  } = data;
  if (!logged_in) {
    return (
      <Window width={420} height={180}>
        <Window.Content>
          <Section fill>
            <NoticeBox>Konsola zablokowana. Wymagany dostęp do aresztu.</NoticeBox>
            <Button fluid icon="sign-in-alt" onClick={() => act('lock')}>
              Zaloguj
            </Button>
          </Section>
        </Window.Content>
      </Window>
    );
  }
  return (
    <Window width={520} height={600}>
      <Window.Content scrollable>
        <Section
          title="Karta więźnia"
          buttons={
            <Button icon="sign-out-alt" onClick={() => act('lock')}>
              Wyloguj
            </Button>
          }
        >
          {prisoner_id ? (
            <>
              <LabeledList>
                <LabeledList.Item
                  label="Karta"
                  buttons={
                    <Button
                      icon="eject"
                      onClick={() => act('id', { action: 'eject' })}
                    >
                      Wyjmij
                    </Button>
                  }
                >
                  {prisoner_id.name}
                </LabeledList.Item>
                <LabeledList.Item
                  label="Punkty"
                  buttons={
                    <Button
                      icon="undo"
                      onClick={() => act('id', { action: 'reset' })}
                    >
                      Zeruj
                    </Button>
                  }
                >
                  <ProgressBar
                    value={prisoner_id.points}
                    maxValue={Math.max(prisoner_id.goal, 1)}
                  >
                    {prisoner_id.points} / {prisoner_id.goal}
                  </ProgressBar>
                </LabeledList.Item>
                <LabeledList.Item
                  label="Cel"
                  buttons={
                    <>
                      <Button
                        icon="pen"
                        onClick={() => act('id', { action: 'setgoal' })}
                      >
                        Ustaw
                      </Button>
                      <Button
                        icon={prisoner_id.permanent ? 'lock' : 'clock'}
                        onClick={() => act('id', { action: 'setpermanent' })}
                      >
                        {prisoner_id.permanent ? 'Stała' : 'Tymczasowa'}
                      </Button>
                    </>
                  }
                >
                  {prisoner_id.goal}
                </LabeledList.Item>
              </LabeledList>
              <Box mt={1} color="label">
                Prawo Kosmiczne zaleca 100 punktów za każdą minutę, którą więzień
                spędziłby w areszcie.
              </Box>
            </>
          ) : (
            <Button
              fluid
              icon="id-card"
              onClick={() => act('id', { action: 'insert' })}
            >
              Włóż kartę więźnia
            </Button>
          )}
        </Section>
        <Section title="Implanty chemiczne">
          {chem_implants.length === 0 ? (
            <Box color="label">Brak aktywnych implantów.</Box>
          ) : (
            <Table>
              <Table.Row header>
                <Table.Cell>Nosiciel</Table.Cell>
                <Table.Cell>Zapas</Table.Cell>
                <Table.Cell collapsing>Wstrzyknij</Table.Cell>
              </Table.Row>
              {chem_implants.map((implant) => (
                <Table.Row key={implant.ref} className="candystripe">
                  <Table.Cell>{implant.name}</Table.Cell>
                  <Table.Cell>{implant.volume} j.</Table.Cell>
                  <Table.Cell collapsing>
                    {[1, 5, 10].map((amount) => (
                      <Button
                        key={amount}
                        color="bad"
                        onClick={() =>
                          act('inject', { ref: implant.ref, amount })
                        }
                      >
                        {amount}
                      </Button>
                    ))}
                  </Table.Cell>
                </Table.Row>
              ))}
            </Table>
          )}
        </Section>
        <Section title="Implanty śledzące">
          {tracking_implants.length === 0 ? (
            <Box color="label">Brak aktywnych implantów.</Box>
          ) : (
            <Table>
              <Table.Row header>
                <Table.Cell>Nosiciel</Table.Cell>
                <Table.Cell>Położenie</Table.Cell>
                <Table.Cell collapsing />
              </Table.Row>
              {tracking_implants.map((implant) => (
                <Table.Row key={implant.ref} className="candystripe">
                  <Table.Cell>{implant.name}</Table.Cell>
                  <Table.Cell>{implant.location}</Table.Cell>
                  <Table.Cell collapsing>
                    <Button
                      icon="comment"
                      onClick={() => act('warn', { ref: implant.ref })}
                    >
                      Wiadomość
                    </Button>
                  </Table.Cell>
                </Table.Row>
              ))}
            </Table>
          )}
        </Section>
      </Window.Content>
    </Window>
  );
};
