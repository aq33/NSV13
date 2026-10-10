import { Box, Button, LabeledList, Section } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  bodies: any;
};

export const BodyEntry = (props) => {
  const { body, swapFunc } = props;

  const statusMap = {
    Dead: 'bad',
    Unconscious: 'average',
    Conscious: 'good',
  };

  const occupiedMap = {
    owner: 'You Are Here',
    stranger: 'Occupied',
    available: 'Swap',
  };

  return (
    <Section
      title={
        <Box inline color={body.htmlcolor}>
          {body.name}
        </Box>
      }
      buttons={
        <Button
          content={occupiedMap[body.occupied]}
          selected={body.occupied === 'owner'}
          color={body.occupied === 'stranger' && 'bad'}
          onClick={() => swapFunc()}
        />
      }
    >
      <LabeledList>
        <LabeledList.Item label="Status" color={statusMap[body.status]}>
          {body.status}
        </LabeledList.Item>
        <LabeledList.Item label="Jelly">{body.exoticblood}</LabeledList.Item>
        <LabeledList.Item label="Location">{body.area}</LabeledList.Item>
      </LabeledList>
    </Section>
  );
};

export const SlimeBodySwapper = (props) => {
  const { act, data } = useBackend<Data>();

  const { bodies = [] } = data;

  return (
    <Window theme="generic" width={400} height={400}>
      <Window.Content scrollable>
        <Section>
          {bodies.map((body) => (
            <BodyEntry
              key={body.name}
              body={body}
              swapFunc={() => act('swap', { ref: body.ref })}
            />
          ))}
        </Section>
      </Window.Content>
    </Window>
  );
};
