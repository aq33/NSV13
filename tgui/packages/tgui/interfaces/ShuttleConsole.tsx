// AQUILA - konsola promu (aquila/code/modules/shuttle/shuttle_console_ui.dm)
import {
  Box,
  Button,
  LabeledList,
  NoticeBox,
  Section,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Destination = {
  id: string;
  name: string;
};

type Data = {
  shuttle_name: string | null;
  status: string | null;
  mode: string | null;
  custom_landing: boolean;
  admin_controlled: boolean;
  can_request: boolean;
  destinations: Destination[];
};

export const ShuttleConsole = (_) => {
  const { act, data } = useBackend<Data>();
  const {
    shuttle_name,
    status,
    custom_landing,
    admin_controlled,
    can_request,
    destinations = [],
  } = data;
  const locked = destinations.length === 0 && !custom_landing;
  return (
    <Window width={340} height={300}>
      <Window.Content scrollable>
        <Section title={shuttle_name || 'Prom'}>
          <LabeledList>
            <LabeledList.Item label="Stan">
              {status || <Box color="bad">Brak połączenia z promem</Box>}
            </LabeledList.Item>
          </LabeledList>
        </Section>
        {!!status && (
          <Section title="Cel lotu">
            {locked && (
              <NoticeBox danger>
                Prom zablokowany
                {!!admin_controlled && ' — tylko dla upoważnionego personelu'}
              </NoticeBox>
            )}
            {destinations.map((destination) => (
              <Button
                key={destination.id}
                fluid
                mb={0.5}
                icon="rocket"
                onClick={() => act('move', { id: destination.id })}
              >
                Leć do: {destination.name}
              </Button>
            ))}
            {!!custom_landing && (
              <Button
                fluid
                icon="map-marker-alt"
                onClick={() => act('designate')}
              >
                Wyznacz miejsce lądowania
              </Button>
            )}
            {locked && !!admin_controlled && !!can_request && (
              <Button fluid icon="bell" onClick={() => act('request')}>
                Poproś o autoryzację
              </Button>
            )}
          </Section>
        )}
      </Window.Content>
    </Window>
  );
};
