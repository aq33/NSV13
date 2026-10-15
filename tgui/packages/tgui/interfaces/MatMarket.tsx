// AQUILA - galaktyczny rynek materiałów, port z tgstation
import { BooleanLike } from 'common/react';
import {
  Box,
  Button,
  Collapsible,
  Modal,
  NoticeBox,
  Section,
  Stack,
  Tooltip,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { formatMoney } from '../format';
import { Window } from '../layouts';

type Material = {
  name: string;
  quantity: number;
  rarity: number;
  trend: string;
  price: number;
  min_threshold: number;
  max_threshold: number;
  color: string;
  requested: number;
};

type Data = {
  orderingPrive: BooleanLike;
  canOrderCargo: BooleanLike;
  hasId: BooleanLike;
  creditBalance: number;
  orderBalance: number;
  materials: Material[];
  updateTime: number;
  catastrophe: BooleanLike;
};

const BUY_AMOUNTS = [1, 5, 10, 25, 50];

const TREND_TEXT = {
  up: 'rośnie',
  down: 'spada',
  neutral: 'stoi',
};

export const MatMarket = (props) => {
  const { act, data } = useBackend<Data>();
  const {
    orderingPrive,
    canOrderCargo,
    hasId,
    catastrophe,
    creditBalance,
    orderBalance,
    materials = [],
    updateTime,
  } = data;

  // zamówienia z prywatnego konta kosztują 1,1x (opłata dla zaopatrzenia)
  const multiplier = orderingPrive ? 1.1 : 1;
  const sortedMaterials = [...materials].sort((a, b) => a.rarity - b.rarity);

  return (
    <Window title="Galaktyczny rynek materiałów" width={900} height={600}>
      <Window.Content scrollable>
        {!!catastrophe && (
          <Modal textAlign="center">
            UWAGA! NA RYNKU TRWA KRACH
            <br />
            <br />
            WSZYSTKIE MATERIAŁY SĄ TERAZ BEZWARTOŚCIOWE
            <br />
            <br />
            HANDEL ZOSTAŁ WSTRZYMANY DLA WSZYSTKICH HANDLARZY
            <br />
            <br />
            <b>BEZ PANIKI, NAPRAWIAMY TO</b>
          </Modal>
        )}
        <Section
          title="Materiały na sprzedaż"
          buttons={
            !!canOrderCargo && (
              <Button.Checkbox
                checked={!orderingPrive}
                color={orderingPrive ? 'transparent' : 'green'}
                tooltip="Płać budżetem zaopatrzenia zamiast własną kartą."
                onClick={() => act('toggle_budget')}
              >
                {orderingPrive
                  ? 'Płać budżetem zaopatrzenia?'
                  : 'Płacisz budżetem zaopatrzenia'}
              </Button.Checkbox>
            )
          }
        >
          {!hasId && (
            <NoticeBox danger>
              Do handlu potrzebna jest karta identyfikacyjna z kontem bankowym.
            </NoticeBox>
          )}
          <Stack align="center">
            <Stack.Item grow>
              Saldo: <b>{formatMoney(creditBalance)}</b> kr
            </Stack.Item>
            <Stack.Item grow>
              Zamówienie: <b>{formatMoney(orderBalance)}</b> kr
            </Stack.Item>
            <Stack.Item grow color={updateTime > 150 ? 'good' : 'average'}>
              Następna zmiana cen za <b>{Math.round(updateTime / 10)} s</b>
            </Stack.Item>
            <Stack.Item>
              <Button icon="times" onClick={() => act('clear')}>
                Anuluj zamówienie
              </Button>
            </Stack.Item>
          </Stack>
        </Section>
        {sortedMaterials.map((material) => (
          <Section key={material.name}>
            <Stack align="center">
              <Stack.Item
                width="16%"
                fontSize="120%"
                textColor={material.color}
              >
                {material.name}
              </Stack.Item>
              <Stack.Item width="16%">
                <Tooltip
                  content={`Ten materiał handluje się w przedziale ${formatMoney(
                    material.min_threshold,
                  )} - ${formatMoney(material.max_threshold)} kr.`}
                >
                  <Box style={{ textDecoration: 'underline dotted' }}>
                    Cena: <b>{formatMoney(material.price)}</b> kr
                  </Box>
                </Tooltip>
              </Stack.Item>
              <Stack.Item width="24%">
                <Box textColor={material.quantity ? undefined : 'grey'}>
                  Na rynku: <b>{material.quantity}</b> ark.
                </Box>
                <Box textColor={material.requested ? 'lightblue' : undefined}>
                  Zamówione: <b>{material.requested}</b> ark.
                </Box>
              </Stack.Item>
              <Stack.Item
                width="14%"
                color={
                  material.trend === 'up'
                    ? 'good'
                    : material.trend === 'down'
                      ? 'bad'
                      : undefined
                }
              >
                Cena {TREND_TEXT[material.trend] || 'stoi'}
              </Stack.Item>
              <Stack.Item grow textAlign="right">
                {BUY_AMOUNTS.map((amount) => (
                  <Button
                    key={amount}
                    disabled={
                      !hasId ||
                      !!catastrophe ||
                      !material.price ||
                      creditBalance - orderBalance <
                        material.price * amount * multiplier ||
                      material.requested + amount > material.quantity
                    }
                    tooltip={`${formatMoney(Math.round(material.price * amount * multiplier))} kr`}
                    onClick={() =>
                      act('buy', {
                        quantity: amount,
                        material: material.name,
                      })
                    }
                  >
                    {amount === 1 ? 'Kup 1' : amount}
                  </Button>
                ))}
              </Stack.Item>
            </Stack>
          </Section>
        ))}
        <NoticeBox info>
          <Collapsible title="Instrukcja" color="blue">
            Kupione arkusze przylecą najbliższym promem zaopatrzenia. Jeden
            handlarz może mieć w zamówieniu najwyżej 10 pełnych stosów.
            <br />
            <br />
            Aby sprzedać materiał, włóż do maszyny stos arkuszy. Dostaniesz
            stock block z ceną zamrożoną na 3 minuty - wyślij go promem
            zaopatrzenia. Potem cena bloku zaczyna płynąć razem z rynkiem.
            <br />
            <br />
            Każda sprzedaż obniża cenę materiału, a każdy zakup ją podnosi.
          </Collapsible>
        </NoticeBox>
      </Window.Content>
    </Window>
  );
};
