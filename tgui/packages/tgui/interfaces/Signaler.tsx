import { toFixed } from 'common/math';
import { Button, NumberInput, Section } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Grid } from '../components';
import { Window } from '../layouts';

type Data = {
  code: any;
  connection: any;
  frequency: any;
  maxFrequency: any;
  minFrequency: any;
};

export const Signaler = (props) => {
  return (
    <Window width={280} height={132}>
      <Window.Content>
        <SignalerContent />
      </Window.Content>
    </Window>
  );
};

export const SignalerContent = (props) => {
  const { act, data } = useBackend<Data>();
  const { code, frequency, minFrequency, maxFrequency, connection } = data;
  return (
    <Section>
      <Grid>
        <Grid.Column size={1.4} color="label">
          Frequency:
        </Grid.Column>
        <Grid.Column>
          <NumberInput
            animated
            unit="kHz"
            step={0.2}
            stepPixelSize={6}
            minValue={minFrequency / 10}
            maxValue={maxFrequency / 10}
            value={frequency / 10 || minFrequency / 10}
            format={(value) => toFixed(value, 1)}
            width="80px"
            onDrag={(value) =>
              act('freq', {
                freq: value,
              })
            }
          />
        </Grid.Column>
        <Grid.Column>
          <Button
            ml={1.3}
            icon="sync"
            content="Reset"
            onClick={() =>
              act('reset', {
                reset: 'freq',
              })
            }
          />
        </Grid.Column>
      </Grid>
      <Grid mt={0.6}>
        <Grid.Column size={1.4} color="label">
          Code:
        </Grid.Column>
        <Grid.Column>
          <NumberInput
            animated
            step={1}
            stepPixelSize={6}
            minValue={1}
            maxValue={100}
            value={code || 1}
            width="80px"
            onDrag={(value) =>
              act('code', {
                code: value,
              })
            }
          />
        </Grid.Column>
        <Grid.Column>
          <Button
            ml={1.3}
            icon="sync"
            content="Reset"
            onClick={() =>
              act('reset', {
                reset: 'code',
              })
            }
          />
        </Grid.Column>
      </Grid>
      <Grid mt={0.8}>
        <Grid.Column>
          <Button
            mb={-0.1}
            fluid
            icon="arrow-up"
            content="Send Signal"
            textAlign="center"
            disabled={!connection}
            onClick={() => act('signal')}
          />
        </Grid.Column>
      </Grid>
    </Section>
  );
};
