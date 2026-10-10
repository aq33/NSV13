// NSV13

import { Fragment } from 'react';
import {
  Button,
  Section,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  launchers_info: any;
};

export const FighterLauncher = (props) => {
  const { act, data } = useBackend<Data>();
  return (
    <Window theme="retro" width={500} height={600}>
      <Window.Content scrollable>
        <Section>
          {Object.keys(data.launchers_info).map((key) => {
            let value = data.launchers_info[key];
            return (
              <Fragment key={key}>
                <Section title={`${value.name}`}>
                  {!!value.mag_locked && (
                    <>
                      <Button
                        content={`Launch ${value.mag_locked}`}
                        icon="arrow-right"
                        color={'good'}
                        disabled={!value.can_launch}
                        onClick={() => act('launch', { id: value.id })}
                      />
                      <Button
                        content={`Release ${value.mag_locked}`}
                        icon="eject"
                        color={'average'}
                        onClick={() => act('release', { id: value.id })}
                      />
                    </>
                  )}
                  {!!value.pilot_id && (
                    <Button
                      content={`Message ${value.pilot}`}
                      icon="comments"
                      disabled={!value.msg_cooldown}
                      onClick={() =>
                        act('message', { pilot_id: value.pilot_id })
                      }
                    />
                  )}
                </Section>
              </Fragment>
            );
          })}
        </Section>
      </Window.Content>
    </Window>
  );
};
