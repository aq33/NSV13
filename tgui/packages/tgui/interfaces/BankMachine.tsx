import { Button, LabeledList, NoticeBox, Section } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  current_balance: any;
  siphoning: any;
  station_name: any;
};

export const BankMachine = (props) => {
  const { act, data } = useBackend<Data>();
  const { current_balance, siphoning, station_name } = data;
  return (
    <Window width={335} height={160}>
      <Window.Content>
        <Section title={station_name + ' Vault'}>
          <LabeledList>
            <LabeledList.Item
              label="Current Balance"
              buttons={
                <Button
                  icon={siphoning ? 'times' : 'sync'}
                  content={siphoning ? 'Stop Siphoning' : 'Siphon Credits'}
                  selected={siphoning}
                  onClick={() => act(siphoning ? 'halt' : 'siphon')}
                />
              }
            >
              {current_balance + ' cr'}
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <NoticeBox textAlign="center">Authorized personnel only</NoticeBox>
      </Window.Content>
    </Window>
  );
};
