// AQUILA - monitor sieci telekomunikacji (aquila/code/game/machinery/telecomms/telecomms_monitors_ui.dm)
import {
  Box,
  Button,
  LabeledList,
  NoticeBox,
  Section,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Machine = {
  id: string;
  name: string;
  ref: string;
};

type Selected = {
  id: string;
  name: string;
  on: boolean;
  links: Machine[];
};

type Data = {
  network: string;
  notice: string;
  machines: Machine[];
  selected: Selected | null;
};

const MachineList = (props: { machines: Machine[] }) => {
  const { act } = useBackend<Data>();
  return (
    <>
      {props.machines.map((machine) => (
        <Button
          key={machine.ref}
          fluid
          mb={0.5}
          icon="broadcast-tower"
          onClick={() => act('view', { ref: machine.ref })}
        >
          {machine.name} ({machine.id})
        </Button>
      ))}
    </>
  );
};

export const TelecommsMonitor = (_) => {
  const { act, data } = useBackend<Data>();
  const { network, notice, machines = [], selected } = data;
  return (
    <Window width={500} height={450}>
      <Window.Content scrollable>
        {!!notice && <NoticeBox info>{notice}</NoticeBox>}
        <Section
          title="Sieć"
          buttons={
            <Button icon="network-wired" onClick={() => act('network')}>
              Zmień sieć
            </Button>
          }
        >
          <LabeledList>
            <LabeledList.Item label="Obecna sieć">{network}</LabeledList.Item>
          </LabeledList>
        </Section>
        {selected ? (
          <Section
            title={`${selected.name} (${selected.id})`}
            buttons={
              <Button icon="arrow-left" onClick={() => act('main_menu')}>
                Wróć
              </Button>
            }
          >
            <LabeledList>
              <LabeledList.Item label="Stan">
                <Box color={selected.on ? 'good' : 'bad'}>
                  {selected.on ? 'Działa' : 'Wyłączona'}
                </Box>
              </LabeledList.Item>
            </LabeledList>
            <Box bold mt={1} mb={0.5}>
              Połączone maszyny
            </Box>
            {selected.links.length === 0 && (
              <Box color="label">Brak połączeń.</Box>
            )}
            <MachineList machines={selected.links} />
          </Section>
        ) : (
          <Section
            title="Wykryte maszyny"
            buttons={
              machines.length > 0 ? (
                <Button icon="trash" onClick={() => act('release')}>
                  Wyczyść bufor
                </Button>
              ) : (
                <Button icon="search" onClick={() => act('probe')}>
                  Skanuj sieć
                </Button>
              )
            }
          >
            {machines.length === 0 && (
              <Box color="label">Brak maszyn. Zeskanuj sieć.</Box>
            )}
            <MachineList machines={machines} />
          </Section>
        )}
      </Window.Content>
    </Window>
  );
};
