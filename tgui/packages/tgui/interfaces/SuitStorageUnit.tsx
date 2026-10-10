import { Fragment } from 'react';
import {
  Box,
  Button,
  Icon,
  LabeledList,
  NoticeBox,
  Section,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  helmet: any;
  locked: any;
  mask: any;
  occupied: any;
  open: any;
  safeties: any;
  storage: any;
  suit: any;
  uv_active: any;
};

export const SuitStorageUnit = (props) => {
  const { act, data } = useBackend<Data>();
  const {
    locked,
    open,
    safeties,
    uv_active,
    occupied,
    suit,
    helmet,
    mask,
    storage,
  } = data;
  return (
    <Window width={400} height={305}>
      <Window.Content>
        {!!(occupied && safeties) && (
          <NoticeBox>
            Biological entity detected in suit chamber. Please remove before
            continuing with operation.
          </NoticeBox>
        )}
        {(uv_active && (
          <NoticeBox>
            Contents are currently being decontaminated. Please wait.
          </NoticeBox>
        )) || (
          <Section
            title="Storage"
            minHeight="260px"
            buttons={
              <>
                {!open && (
                  <Button
                    icon={locked ? 'unlock' : 'lock'}
                    content={locked ? 'Unlock' : 'Lock'}
                    onClick={() => act('lock')}
                  />
                )}
                {!locked && (
                  <Button
                    icon={open ? 'sign-out-alt' : 'sign-in-alt'}
                    content={open ? 'Close' : 'Open'}
                    onClick={() => act('door')}
                  />
                )}
              </>
            }
          >
            {(locked && (
              <Box mt={6} bold textAlign="center" fontSize="40px">
                <Box>Unit Locked</Box>
                <Icon name="lock" />
              </Box>
            )) ||
              (open && (
                <LabeledList>
                  <LabeledList.Item label="Helmet">
                    <Button
                      icon={helmet ? 'square' : 'square-o'}
                      content={helmet || 'Empty'}
                      disabled={!helmet}
                      onClick={() =>
                        act('dispense', {
                          item: 'helmet',
                        })
                      }
                    />
                  </LabeledList.Item>
                  <LabeledList.Item label="Suit">
                    <Button
                      icon={suit ? 'square' : 'square-o'}
                      content={suit || 'Empty'}
                      disabled={!suit}
                      onClick={() =>
                        act('dispense', {
                          item: 'suit',
                        })
                      }
                    />
                  </LabeledList.Item>
                  <LabeledList.Item label="Mask">
                    <Button
                      icon={mask ? 'square' : 'square-o'}
                      content={mask || 'Empty'}
                      disabled={!mask}
                      onClick={() =>
                        act('dispense', {
                          item: 'mask',
                        })
                      }
                    />
                  </LabeledList.Item>
                  <LabeledList.Item label="Storage">
                    <Button
                      icon={storage ? 'square' : 'square-o'}
                      content={storage || 'Empty'}
                      disabled={!storage}
                      onClick={() =>
                        act('dispense', {
                          item: 'storage',
                        })
                      }
                    />
                  </LabeledList.Item>
                </LabeledList>
              )) || (
                <Button
                  fluid
                  icon="recycle"
                  content="Decontaminate"
                  disabled={occupied && safeties}
                  textAlign="center"
                  onClick={() => act('uv')}
                />
              )}
          </Section>
        )}
      </Window.Content>
    </Window>
  );
};
