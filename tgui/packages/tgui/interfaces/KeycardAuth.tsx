import { Box, Button, Section } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  auth_required: any;
  ftl_safety_override: any;
  waiting: any;
};

export const KeycardAuth = (props) => {
  const { act, data } = useBackend<Data>();
  return (
    <Window width={375} height={150}>
      <Window.Content>
        <Section>
          <Box>
            {data.waiting === 1 && (
              <span>Waiting for another device to confirm your request...</span>
            )}
          </Box>
          <Box>
            {data.waiting === 0 && (
              <>
                {!!data.auth_required && (
                  <Button
                    icon="check-square"
                    color="red"
                    textAlign="center"
                    lineHeight="60px"
                    fluid
                    onClick={() => act('auth_swipe')}
                    content="Authorize"
                  />
                )}
                {data.auth_required === 0 && (
                  <>
                    <Button
                      icon="exclamation-triangle"
                      fluid
                      onClick={() => {
                        return act('red_alert');
                      }}
                      content="Red Alert"
                    />
                    <Button
                      icon="wrench"
                      fluid
                      onClick={() => act('emergency_maint')}
                      content="Emergency Maintenance Access"
                    />
                    <Button
                      icon="meteor"
                      fluid
                      onClick={() => act('bsa_unlock')}
                      content="Bluespace Artillery Unlock"
                    />
                    {data.ftl_safety_override >= 0 && (
                      <Button
                        icon="exclamation-triangle"
                        fluid
                        onClick={() => act('ftl_safety_override')}
                        content="FTL Drive Safety Override"
                      />
                    )}
                  </>
                )}
              </>
            )}
          </Box>
        </Section>
      </Window.Content>
    </Window>
  );
};
