// NSV13
// AQUILA: okno przetłumaczone na polski

import { Fragment } from 'react';
import {
  Button,
  Section,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  already_loaned: any;
  kits: any;
  user_name: any;
};

export const SquadVendor = (props) => {
  const { act, data } = useBackend<Data>();
  return (
    <Window theme="ntos" width={600} height={800}>
      <Window.Content scrollable>
        <br />
        {!!data.already_loaned && (
          <Section
            title="Masz już pobrany zestaw"
            buttons={
              <>
                <Button
                  color="average"
                  content="Zwróć wypożyczony sprzęt"
                  tooltip="Włóż cały wypożyczony sprzęt do plecaka i kliknij, żeby go zwrócić."
                  onClick={() => act('return_gear')}
                />
                <Button
                  color="average"
                  content="Zapłać za zgubione przedmioty"
                  onClick={() => act('pay_fine')}
                />
              </>
            }
          />
        )}
        <Section title="Dostępne zestawy:">
          {'Witaj, ' + data.user_name}
          <br />
          {Object.keys(data.kits).map((key) => {
            let value = data.kits[key];
            return (
              <Section
                key={key}
                title={value.name}
                buttons={
                  <Button
                    disabled={!!data.already_loaned}
                    content="Wydaj"
                    icon="eject"
                    onClick={() => act('vend', { item_id: value.id })}
                  />
                }
              >
                {value.desc}
              </Section>
            );
          })}
        </Section>
      </Window.Content>
    </Window>
  );
};
