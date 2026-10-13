// NSV13

import { toFixed } from 'common/math';
import {
  Button,
  ProgressBar,
  Section,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { NtosWindow } from '../layouts';

type Data = {
  control_rod_percent: any;
  heat: any;
  last_power_produced: any;
  mole_threshold_high: any;
  mole_threshold_very_high: any;
  reaction_rate: any;
  reactor_critical: any;
  reactor_hot: any;
  reactor_meltdown: any;
  rod_integrity: any;
  theoretical_maximum_power: any;
  total_moles: any;
};

export const NtosStormdriveMonitor = (props) => {
  const { act, data } = useBackend<Data>();
  return (
    <NtosWindow resizable width={440} height={650}>
      <NtosWindow.Content>
        <Section
          title="Legend:"
          buttons={
            <Button
              icon="search"
              onClick={() => act('swap_reactor')}
              content="Change Reactor"
            />
          }
        >
          Control Rod Insertion:
          <ProgressBar
            value={data.control_rod_percent}
            minValue={0}
            maxValue={100}
          />
          Temperature:
          <ProgressBar
            value={data.heat / data.reactor_meltdown}
            ranges={{
              average: [
                data.reactor_hot / data.reactor_meltdown,
                data.reactor_critical / data.reactor_meltdown,
              ],
              bad: [data.reactor_critical / data.reactor_meltdown, Infinity],
            }}
          >
            {toFixed(data.heat) + ' °C'}
          </ProgressBar>
          Rod Integrity:
          <ProgressBar
            value={(data.rod_integrity / 100) * 100 * 0.01}
            ranges={{
              average: [0.15, 0.5],
              bad: [-Infinity, 0.15],
            }}
          />
          Power Output:
          <ProgressBar
            value={data.last_power_produced / data.theoretical_maximum_power}
            ranges={{
              average: [0.08, 0.2],
              bad: [-Infinity, 0.08],
            }}
          >
            {data.last_power_produced / 1e6 + ' MW'}
          </ProgressBar>
          Reaction Rate:
          <ProgressBar
            value={data.reaction_rate * 0.05}
            ranges={{
              average: [0.1, 0.2],
              bad: [-Infinity, 0.1],
            }}
          >
            {data.reaction_rate + ' mol/s'}
          </ProgressBar>
          Fuel:
          <ProgressBar
            value={data.total_moles / data.mole_threshold_very_high}
            ranges={{
              average: [
                data.mole_threshold_high / data.mole_threshold_very_high,
                Infinity,
              ],
              bad: [
                -Infinity,
                data.reaction_rate / data.mole_threshold_very_high,
              ],
            }}
          >
            {data.total_moles + ' mol'}
          </ProgressBar>
        </Section>
      </NtosWindow.Content>
    </NtosWindow>
  );
};
