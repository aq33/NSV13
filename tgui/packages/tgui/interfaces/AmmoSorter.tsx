import { Fragment } from 'react';
import { Button, Section } from 'tgui-core/components';

import { useBackend, useLocalState } from '../backend';
import { Window } from '../layouts';

type Data = {
  racks_info: any;
};

export const AmmoSorter = (props) => {
  const { act, data } = useBackend<Data>();
  const [settingsVisible, setSettingsVisible] = useLocalState(
    'settings',
    false,
  );
  return (
    <Window theme="hackerman">
      <Window.Content scrollable>
        <Section>
          {Object.keys(data.racks_info).map((key) => {
            let value = data.racks_info[key];
            return (
              <Fragment key={key}>
                <Section
                  title={`${value.name}`}
                  buttons={
                    <>
                      {key === '0' && (
                        <Button
                          icon={settingsVisible ? 'times' : 'cog'}
                          selected={settingsVisible}
                          onClick={() => setSettingsVisible(!settingsVisible)}
                        />
                      )}
                      {!!settingsVisible && (
                        <>
                          <Button
                            content="Rename"
                            icon="pen"
                            onClick={() => act('rename', { id: value.id })}
                          />
                          <Button
                            content="Unlink"
                            icon="trash-alt"
                            color="bad"
                            onClick={() => act('unlink', { id: value.id })}
                          />
                          <Button
                            icon="arrow-up"
                            disabled={key === '0'}
                            onClick={() => act('moveup', { id: value.id })}
                          />
                          <Button
                            icon="arrow-down"
                            disabled={key === `${data.racks_info.length - 1}`}
                            onClick={() => act('movedown', { id: value.id })}
                          />
                        </>
                      )}
                    </>
                  }
                >
                  <Button
                    content={`Unload ${value.top}`}
                    icon="sign-out-alt"
                    disabled={!value.has_loaded}
                    onClick={() => act('unload', { id: value.id })}
                  />
                </Section>
              </Fragment>
            );
          })}
        </Section>
      </Window.Content>
    </Window>
  );
};
