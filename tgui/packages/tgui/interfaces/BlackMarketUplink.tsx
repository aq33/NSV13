// AQUILA - uplink czarnego rynku (port z tgstation)
import {
  AnimatedNumber,
  Box,
  Button,
  Image,
  Modal,
  Section,
  Stack,
  Tabs,
} from 'tgui-core/components';
import { formatMoney } from 'tgui-core/format';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  categories: string[];
  markets: Market[];
  items: Item[];
  money: number | string;
  viewing_market: string;
  viewing_category: string;
  buying: boolean;
  ltsrbt_built: boolean;
  delivery_methods: DeliveryMethod[];
  delivery_method_description: Record<string, string>;
};

type Market = {
  id: string;
  name: string;
};

type Item = {
  id: string;
  name: string;
  desc: string;
  amount: number;
  cost: number;
  html_icon: string;
};

type DeliveryMethod = {
  name: string;
  price: number;
};

// Shipping method names as shown to the player
const delivery_method_names = {
  LTSRBT: 'LTSRBT',
  Teleport: 'Teleportacja',
  Launch: 'Zrzut z kosmosu',
  'Supply Pod': 'Kapsuła zaopatrzeniowa',
};

export const BlackMarketUplink = (props) => {
  const { act, data } = useBackend<Data>();
  const {
    categories = [],
    markets = [],
    items = [],
    money,
    viewing_market,
    viewing_category,
  } = data;
  const balance = typeof money === 'number' ? money : 0;
  return (
    <Window width={670} height={480} theme="hackerman">
      <ShipmentSelector />
      <Window.Content scrollable>
        <Section
          title="Uplink czarnego rynku"
          buttons={
            <Box inline bold>
              {typeof money === 'number' ? (
                <AnimatedNumber
                  value={money}
                  format={(value) => `${formatMoney(value)} kr`}
                />
              ) : (
                'Brak karty z kontem'
              )}
            </Box>
          }
        />
        <Tabs>
          {markets.map((market) => (
            <Tabs.Tab
              key={market.id}
              selected={market.id === viewing_market}
              onClick={() =>
                act('set_market', {
                  market: market.id,
                })
              }
            >
              {market.name}
            </Tabs.Tab>
          ))}
        </Tabs>
        <Stack>
          <Stack.Item>
            <Tabs vertical>
              {categories.map((category) => (
                <Tabs.Tab
                  key={category}
                  mt={0.5}
                  selected={viewing_category === category}
                  onClick={() =>
                    act('set_category', {
                      category: category,
                    })
                  }
                >
                  {category}
                </Tabs.Tab>
              ))}
            </Tabs>
          </Stack.Item>
          <Stack.Item grow>
            {items.map((item) => (
              <Box key={item.id} className="candystripe" p={1} pb={2}>
                <Stack align="baseline">
                  <Stack.Item grow>
                    <Stack align="center">
                      {!!item.html_icon && (
                        <Stack.Item>
                          <Image
                            m={1}
                            src={`data:image/jpeg;base64,${item.html_icon}`}
                            height="64px"
                            width="64px"
                          />
                        </Stack.Item>
                      )}
                      <Stack.Item grow bold>
                        {item.name}
                      </Stack.Item>
                    </Stack>
                  </Stack.Item>
                  <Stack.Item color="label">
                    {item.amount ? `${item.amount} w magazynie` : 'Wyprzedane'}
                  </Stack.Item>
                  <Stack.Item>{`${formatMoney(item.cost)} kr`}</Stack.Item>
                  <Stack.Item>
                    <Button
                      disabled={!item.amount || item.cost > balance}
                      onClick={() =>
                        act('select', {
                          item: item.id,
                        })
                      }
                    >
                      Kup
                    </Button>
                  </Stack.Item>
                </Stack>
                {item.desc}
              </Box>
            ))}
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const ShipmentSelector = (props) => {
  const { act, data } = useBackend<Data>();
  const { buying, ltsrbt_built, money } = data;
  if (!buying) {
    return null;
  }
  const balance = typeof money === 'number' ? money : 0;
  const deliveryMethods = data.delivery_methods.map((method) => {
    const description = data.delivery_method_description[method.name];
    return {
      ...method,
      description,
    };
  });
  return (
    <Modal textAlign="center">
      <Stack mb={1}>
        {deliveryMethods.map((method) => {
          if (method.name === 'LTSRBT' && !ltsrbt_built) {
            return null;
          }
          return (
            <Stack.Item key={method.name} mx={1} width="17.5rem">
              <Box fontSize="30px">
                {delivery_method_names[method.name] || method.name}
              </Box>
              <Box mt={1}>{method.description}</Box>
              <Button
                mt={2}
                disabled={balance < method.price}
                onClick={() =>
                  act('buy', {
                    method: method.name,
                  })
                }
              >
                {`${formatMoney(method.price)} kr`}
              </Button>
            </Stack.Item>
          );
        })}
      </Stack>
      <Button color="bad" onClick={() => act('cancel')}>
        Anuluj
      </Button>
    </Modal>
  );
};
