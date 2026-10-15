// NSV13

import { Fragment } from 'react';
import { Button, Section } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  loaded: any;
};

export const MunitionsTrolley = (props) => {
  const { act, data } = useBackend<Data>();
  return (
    <Window theme="hackerman">
      <Window.Content scrollable>
        <Section
          title="Loaded"
          buttons={
            <Button
              content="Unload All"
              icon="eject"
              onClick={() => act('unload_all')}
            />
          }
        >
          {Object.keys(data.loaded).map((key) => {
            let value = data.loaded[key];
            return (
              <Fragment key={key}>
                <Button
                  content={`Unload ${value.name}`}
                  icon="arrow-right"
                  onClick={() => act('unload', { id: value.id })}
                />
              </Fragment>
            );
          })}
        </Section>
      </Window.Content>
    </Window>
  );
};
