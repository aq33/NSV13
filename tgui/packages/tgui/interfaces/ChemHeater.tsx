import { round, toFixed } from 'common/math';
import {
  AnimatedNumber,
  Box,
  Button,
  LabeledList,
  NumberInput,
  Section,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { BeakerContents } from './common/BeakerContents';

type Data = {
  beakerContents: any;
  beakerCurrentVolume: any;
  beakerMaxVolume: any;
  currentTemp: any;
  isActive: any;
  isBeakerLoaded: any;
  targetTemp: any;
};

export const ChemHeater = (props) => {
  const { act, data } = useBackend<Data>();
  const {
    targetTemp,
    isActive,
    isBeakerLoaded,
    currentTemp,
    beakerCurrentVolume,
    beakerMaxVolume,
    beakerContents = [],
  } = data;
  return (
    <Window width={275} height={320}>
      <Window.Content scrollable>
        <Section
          title="Thermostat"
          buttons={
            <Button
              icon={isActive ? 'power-off' : 'times'}
              selected={isActive}
              content={isActive ? 'On' : 'Off'}
              onClick={() => act('power')}
            />
          }
        >
          <LabeledList>
            <LabeledList.Item label="Target">
              <NumberInput
                width="65px"
                unit="K"
                step={10}
                stepPixelSize={3}
                value={round(targetTemp, 0)}
                minValue={0}
                maxValue={1000}
                onDrag={(value) =>
                  act('temperature', {
                    target: value,
                  })
                }
              />
            </LabeledList.Item>
            <LabeledList.Item label="Reading">
              <Box width="60px" textAlign="right">
                {(isBeakerLoaded && (
                  <AnimatedNumber
                    value={currentTemp}
                    format={(value) => toFixed(value) + ' K'}
                  />
                )) ||
                  '—'}
              </Box>
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section
          title="Beaker"
          buttons={
            !!isBeakerLoaded && (
              <>
                <Box inline color="label" mr={2}>
                  {beakerCurrentVolume} / {beakerMaxVolume} units
                </Box>
                <Button
                  icon="eject"
                  content="Eject"
                  onClick={() => act('eject')}
                />
              </>
            )
          }
        >
          <BeakerContents
            beakerLoaded={isBeakerLoaded}
            beakerContents={beakerContents}
          />
        </Section>
      </Window.Content>
    </Window>
  );
};
