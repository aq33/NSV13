import { Box, Button, ProgressBar, Section, Table } from 'tgui-core/components';

import { BooleanLike } from '../../common/react';
import { useBackend } from '../backend';
import { Window } from '../layouts';

type BroadSideShellPackerData = {
  casing_amount: number;
  load_amount: number;
  amount_to_pack: number;
  plasma: BooleanLike;
  gunpowder: BooleanLike;
  full: BooleanLike;
};

export const BroadSideShellPacker = (props) => {
  const { act, data } = useBackend<BroadSideShellPackerData>();
  const {
    casing_amount,
    load_amount,
    amount_to_pack,
    plasma,
    gunpowder,
    full,
  } = data;

  return (
    <Window width={560} height={600}>
      <Window.Content scrollable>
        <Section>
          <Table.Row>
            <Table.Cell collapsing>
              <Section title="Casings:">
                <ProgressBar
                  value={(casing_amount / amount_to_pack) * 100 * 0.01}
                  ranges={{
                    good: [0.5, Infinity],
                    average: [0.15, 0.5],
                    bad: [-Infinity, 0.15],
                  }}
                />
                <br />
                <Box bold textAlign={'center'}>
                  {casing_amount}/{amount_to_pack}
                </Box>
              </Section>
            </Table.Cell>
            <Table.Cell collapsing>
              <Section title="Projectile Loads:">
                <ProgressBar
                  value={(load_amount / amount_to_pack) * 100 * 0.01}
                  ranges={{
                    good: [0.5, Infinity],
                    average: [0.15, 0.5],
                    bad: [-Infinity, 0.15],
                  }}
                />
                <br />
                <Box bold textAlign={'center'}>
                  {load_amount}/{amount_to_pack}
                </Box>
              </Section>
            </Table.Cell>
          </Table.Row>
          <Section title="Powder Type:">
            <Table.Row>
              <Table.Cell collapsing>
                <Button
                  fluid
                  ellipsis
                  textAlign="center"
                  color={plasma ? 'good' : 'bad'}
                >
                  Plasma Charge
                </Button>
                <Button
                  fluid
                  ellipsis
                  textAlign="center"
                  icon="eject"
                  disabled={!plasma}
                  onClick={() => act('eject_plasma')}
                >
                  Eject Plasma Charge
                </Button>
              </Table.Cell>
              <Table.Cell collapsing>
                <Button
                  fluid
                  ellipsis
                  textAlign="center"
                  color={gunpowder ? 'good' : 'bad'}
                >
                  Gunpowder Charge
                </Button>
                <Button
                  fluid
                  ellipsis
                  textAlign="center"
                  icon="eject"
                  disabled={!gunpowder}
                  onClick={() => act('eject_gunpowder')}
                >
                  Eject Gunpowder Charge
                </Button>
              </Table.Cell>
            </Table.Row>
          </Section>
          <Section title="Controls:">
            <Table.Row>
              <Table.Cell collapsing>
                <Button
                  fluid
                  ellipsis
                  textAlign="center"
                  color={full ? 'good' : 'bad'}
                >
                  Ready to Pack
                </Button>
                <Button
                  fluid
                  ellipsis
                  textAlign="center"
                  icon="exclamation-triangle"
                  disabled={!full}
                  onClick={() => act('pack')}
                >
                  Pack Casings
                </Button>
              </Table.Cell>
            </Table.Row>
          </Section>
        </Section>
      </Window.Content>
    </Window>
  );
};
