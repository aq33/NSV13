// NSV13

import { Fragment } from 'react';
import { Button, ProgressBar, Section } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  bullets_info: any;
  capacity: any;
  loading: any;
  max_capacity: any;
};

export const GaussRack = (props) => {
  const { act, data } = useBackend<Data>();
  return (
    <Window width={560} height={600}>
      <Window.Content scrollable>
        <Section>
          <Section title="Controls:">
            <Button
              fluid
              content="Load ammunition into gun"
              icon="arrow-circle-up"
              disabled={data.loading}
              onClick={() => act('load')}
            />
            <Button
              fluid
              content="Unload all ammunition from rack"
              icon="exclamation-triangle"
              color={'average'}
              onClick={() => act('unload_all')}
            />
          </Section>
          <Section title="Loaded ammunition:">
            <ProgressBar
              value={(data.capacity / data.max_capacity) * 100 * 0.01}
              ranges={{
                good: [0.5, Infinity],
                average: [0.15, 0.5],
                bad: [-Infinity, 0.15],
              }}
            />
            <br />
            {Object.keys(data.bullets_info).map((key) => {
              let value = data.bullets_info[key];
              return (
                <Fragment key={key}>
                  <Button
                    fluid
                    content={`Unload ${value.name}`}
                    icon="eject"
                    onClick={() => act('unload', { id: value.id })}
                  />
                </Fragment>
              );
            })}
          </Section>
        </Section>
      </Window.Content>
    </Window>
  );
};
