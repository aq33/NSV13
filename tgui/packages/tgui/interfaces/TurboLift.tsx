import { Fragment } from 'react';
import { Button, NoticeBox, Section } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  current: any;
  decks: any;
  online: any;
};

export const TurboLift = (props) => {
  const { act, data } = useBackend<Data>();

  let currentdeck;
  for (let value of Object.values(data.decks) as any[]) {
    if (value.z === data.current) {
      currentdeck = value.deck;
    }
  }

  return (
    <Window width={300} height={300}>
      <Window.Content scrollable>
        <NoticeBox>
          {(data.online &&
            ((currentdeck && `Currently at deck ${currentdeck}`) ||
              `Unable to determine current deck.`)) || (
            <>
              This lift is currently offline. Please contact a Nanotrasen lift
              repair technician.
            </>
          )}
        </NoticeBox>
        <Section title="Lift panel">
          {Object.keys(data.decks).map((key) => {
            let value = data.decks[key];
            return (
              <Button
                key={key}
                fluid
                color={
                  (data.current === value.z && 'blue') ||
                  (value.queued && 'good') ||
                  'normal'
                }
                content={`Deck ${value.deck}: ${value.name}`}
                bold={data.current === value.z}
                disabled={!data.online}
                onClick={() => {
                  if (data.current === value.z) {
                    return;
                  }
                  if (value.queued) {
                    return;
                  }
                  act('goto', { deck: key });
                }}
              />
            );
          })}
        </Section>
      </Window.Content>
    </Window>
  );
};
