import {
  Button,
  ProgressBar,
  Section,
  Slider,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  active: any;
  chargeRate: any;
  goal: any;
  maxChargeRate: any;
  maxHealthPriority: any;
  maxPower: any;
  powerAlloc: any;
  progress: any;
  regenPriority: any;
};

export const EnergyWeapons = (props) => {
  const { act, data } = useBackend<Data>();
  const maxHealthPriority = data.maxHealthPriority;
  const regenPriority = data.regenPriority;
  const progress = data.progress;
  const chargeRate = data.chargeRate;
  const maxChargeRate = data.maxChargeRate;
  const goal = data.goal;
  const powerAlloc = data.powerAlloc;
  const maxPower = data.maxPower;
  return (
    <Window theme="ntos" width={600} height={350}>
      <Window.Content scrollable>
        <Section
          title="Charge Status:"
          buttons={
            <Button
              content={data.active ? 'Disable Charging' : 'Enable Charging'}
              icon="charging-station"
              color={data.active && 'good'}
              onClick={() => act('activeToggle')}
            />
          }
        >
          Power Draw:
          <br />
          <ProgressBar
            value={(chargeRate / maxChargeRate) * 100 * 0.01}
            ranges={{
              good: [-Infinity, 0.3],
              average: [0.3, 0.5],
              bad: [0.5, Infinity],
            }}
          >
            {chargeRate / 1e6 + ' mW'}
          </ProgressBar>
          <br />
          Charge:
          <br />
          <ProgressBar
            value={(progress / goal) * 100 * 0.01}
            ranges={{
              good: [0.5, Infinity],
              average: [0.15, 0.5],
              bad: [-Infinity, 0.15],
            }}
          />
        </Section>
        <Section title="Settings:">
          Power Input Level:
          <Slider
            value={powerAlloc}
            minValue={0}
            maxValue={maxPower}
            step={0.5}
            stepPixelSize={5}
            onDrag={(e, value) =>
              act('power', {
                input: value,
              })
            }
          />
        </Section>
      </Window.Content>
    </Window>
  );
};
