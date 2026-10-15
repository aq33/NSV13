// NSV13

import { toFixed } from 'common/math';
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
  available_power: any;
  goal: any;
  maxHealthPriority: any;
  maxPower: any;
  powerAlloc: any;
  progress: any;
  regenPriority: any;
};

export const ShieldGenerator = (props) => {
  const { act, data } = useBackend<Data>();
  const maxHealthPriority = data.maxHealthPriority;
  const regenPriority = data.regenPriority;
  const progress = data.progress;
  const goal = data.goal;
  const powerAlloc = data.powerAlloc;
  const maxPower = data.maxPower;
  const availablePower = data.available_power;
  return (
    <Window theme="ntos" width={600} height={660}>
      <Window.Content scrollable>
        <Section title="Shield Status:">
          Shield integrity: {progress}
          <br />
          Shield strength: {goal}
          <br />
          <ProgressBar
            value={(progress / goal) * 100 * 0.01}
            ranges={{
              good: [0.5, Infinity],
              average: [0.15, 0.5],
              bad: [-Infinity, 0.15],
            }}
          />
          <br />
          Available Power:
          <br />
          <ProgressBar
            value={availablePower}
            minValue={0}
            maxValue={powerAlloc * 1e6}
            color="yellow"
          >
            {toFixed(availablePower / 1000) + ' kW'}
          </ProgressBar>
        </Section>
        <Section
          title="Settings:"
          buttons={
            <Button
              content={data.active ? 'Lower Shields' : 'Raise Shields'}
              icon="shield-alt"
              color={data.active && 'good'}
              onClick={() => act('activeToggle')}
            />
          }
        >
          Shield Strength:
          <Slider
            value={maxHealthPriority}
            fillValue={maxHealthPriority}
            minValue={0}
            maxValue={100}
            step={1}
            stepPixelSize={1}
            onDrag={(e, value) =>
              act('maxHealth', {
                input: value,
              })
            }
          />
          Shield Regeneration:
          <Slider
            value={regenPriority}
            minValue={0}
            maxValue={100}
            step={1}
            stepPixelSize={1}
            onDrag={(e, value) =>
              act('regen', {
                input: value,
              })
            }
          />
          Power allocation (MW):
          <Slider
            value={powerAlloc}
            minValue={0}
            maxValue={maxPower}
            step={0.25}
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
