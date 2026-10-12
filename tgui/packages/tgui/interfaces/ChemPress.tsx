import { classes } from 'common/react';
import {
  Box,
  Button,
  LabeledList,
  NumberInput,
  Section,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  chosen_pill_style: any;
  pill_name: any;
  pill_size: any;
  pill_styles: any;
};

export const ChemPress = (props) => {
  const { act, data } = useBackend<Data>();
  const { pill_size, pill_name, chosen_pill_style, pill_styles = [] } = data;
  return (
    <Window width={300} height={325}>
      <Window.Content>
        <Section>
          <LabeledList>
            <LabeledList.Item label="Pill Volume">
              <NumberInput
                value={pill_size}
                unit="u"
                width="43px"
                minValue={5}
                maxValue={50}
                step={1}
                stepPixelSize={2}
                onChange={(value) =>
                  act('change_pill_size', {
                    volume: value,
                  })
                }
              />
            </LabeledList.Item>
            <LabeledList.Item label="Pill Name">
              <Button
                icon="pencil-alt"
                content={pill_name}
                onClick={() => act('change_pill_name')}
              />
            </LabeledList.Item>
            <LabeledList.Item label="Pill Style">
              {pill_styles.map((each_style) => (
                <Button
                  key={each_style.id}
                  width="30px"
                  height="16px"
                  selected={each_style.id === chosen_pill_style}
                  textAlign="center"
                  color="transparent"
                  onClick={() =>
                    act('change_pill_style', { id: each_style.id })
                  }
                >
                  <Box
                    mx={-1}
                    className={classes([
                      'medicine_containers22x22',
                      each_style.pill_icon_name,
                    ])}
                  />
                </Button>
              ))}
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
