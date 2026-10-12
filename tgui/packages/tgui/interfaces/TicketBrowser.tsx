import { capitalize } from 'common/string';
import {
  BlockQuote,
  Box,
  Button,
  Section,
  Table,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  admin_ckey: any;
  closed_tickets: any;
  open_tickets: any;
  resolved_tickets: any;
  unclaimed_tickets: any;
};

export const TicketBrowser = (props) => {
  const { data } = useBackend<Data>();
  const {
    unclaimed_tickets = [],
    open_tickets = [],
    closed_tickets = [],
    resolved_tickets = [],
    admin_ckey,
  } = data;
  return (
    <Window theme="admin" width={720} height={480}>
      <Window.Content scrollable>
        <Section
          title={
            <Table>
              <Table.Row>
                <Table.Cell inline>Administrator : {admin_ckey}</Table.Cell>
              </Table.Row>
            </Table>
          }
        />
        <Section>
          <TicketMenu
            ticket_list={unclaimed_tickets}
            name={'Unclaimed Tickets'}
            actions={[
              ['flw', 'blue'],
              ['claim', 'good'],
              ['reject', 'bad'],
              ['ic', 'label'],
              ['mhelp', 'label'],
            ]}
          />
          <TicketMenu
            ticket_list={open_tickets}
            name={'Claimed Tickets'}
            actions={[
              ['flw', 'blue'],
              ['claim', 'average'],
              ['resolve', 'good'],
              ['reject', 'bad'],
              ['close', 'label'],
              ['mhelp', 'label'],
              ['ic', 'label'],
            ]}
          />
          <TicketMenu
            ticket_list={resolved_tickets}
            name={'Resolved Tickets'}
            actions={[
              ['flw', 'blue'],
              ['reopen', 'good'],
            ]}
          />
          <TicketMenu
            ticket_list={closed_tickets}
            name={'Closed Tickets'}
            actions={[
              ['flw', 'blue'],
              ['reopen', 'good'],
            ]}
          />
        </Section>
      </Window.Content>
    </Window>
  );
};

export const TicketMenu = (props) => {
  const { ticket_list, name, actions = [] } = props;
  const { act } = useBackend<Data>();
  return (
    <Section title={name}>
      <Table>
        {ticket_list.map((ticket) => (
          <Section key={ticket.name}>
            <Table.Row>
              <Table.Cell bold collapsing>
                <Button
                  color="transparent"
                  onClick={() =>
                    act('view', {
                      id: ticket.id,
                    })
                  }
                >
                  <u>{'#' + ticket.id}</u>
                </Button>
              </Table.Cell>
              <Table.Cell>
                <Button
                  color={ticket.disconnected ? 'bad' : 'transparent'}
                  onClick={() =>
                    act('pm', {
                      id: ticket.id,
                    })
                  }
                >
                  <u>
                    {ticket.initiator_key_name} \
                    {ticket.disconnected ? '[DC]' : ''}
                  </u>
                </Button>
              </Table.Cell>
              {actions.map((action) => (
                <Table.Cell key={action[0]} collapsing>
                  <Button
                    content={capitalize(action[0])}
                    onClick={() =>
                      act(action[0], {
                        id: ticket.id,
                      })
                    }
                    color={action[1]}
                  />
                </Table.Cell>
              ))}
            </Table.Row>
            <BlockQuote>{ticket.name}</BlockQuote>
            <Box color={ticket.claimed_key_name ? 'good' : 'bad'}>
              {ticket.claimed_key_name
                ? ticket.state < 3
                  ? 'Claimed by ' + ticket.claimed_key_name
                  : ticket.state === 3
                    ? 'Closed by ' + ticket.claimed_key_name
                    : 'Resolved by ' + ticket.claimed_key_name
                : 'UNCLAIMED'}
            </Box>
          </Section>
        ))}
      </Table>
    </Section>
  );
};
