import { useDispatch, useSelector } from 'tgui/backend';
import { Box, Button, Flex } from 'tgui/components';

import { selectStatPanel } from './selectors';
import { StatText } from './StatText';

export const StatStatus = (props) => {
  const stat = useSelector(selectStatPanel);
  const dispatch = useDispatch();
  return (
    <Flex direction="column">
      {stat.dead_popup ? (
        <Flex.Item mt={1} mb={1}>
          <Flex direction="column">
            <div className="StatBorder_observer">
              <Flex.Item>
                <Box className="deadsay">
                  <Button
                    color="transparent"
                    icon="times"
                    onClick={() =>
                      dispatch({
                        type: 'stat/clearDeadPopup',
                      })
                    }
                  />
                  <b>Nie żyjesz</b>!
                </Box>
              </Flex.Item>
              <Flex.Item mt={2}>
                <Box className="deadsay">
                  Spokojnie, możesz jeszcze wrócić do gry, jeśli ktoś ożywi twoje
                  ciało albo przez role dla duchów.
                </Box>
              </Flex.Item>
            </div>
          </Flex>
        </Flex.Item>
      ) : null}
      {stat.alert_popup ? (
        <Flex.Item mt={1} mb={1}>
          <div className="StatBorder_infomation">
            <Box>
              <Flex direction="column" className="stat_infomation">
                <Flex.Item bold>
                  <Button
                    color="transparent"
                    icon="times"
                    onClick={() =>
                      dispatch({
                        type: 'stat/clearAlertPopup',
                      })
                    }
                  />
                  <Box inline>{stat.alert_popup.title}</Box>
                </Flex.Item>
                <Flex.Item mt={2}>{stat.alert_popup.text}</Flex.Item>
              </Flex>
            </Box>
          </div>
        </Flex.Item>
      ) : null}
      {stat.antagonist_popup ? (
        <Flex.Item mt={1} mb={1}>
          <div className="StatBorder_antagonist">
            <Box>
              <Flex direction="column" className="stat_antagonist">
                <Flex.Item bold>
                  <Button
                    color="transparent"
                    icon="times"
                    onClick={() =>
                      dispatch({
                        type: 'stat/clearAntagPopup',
                      })
                    }
                  />
                  <Box inline>{stat.antagonist_popup.title}</Box>
                </Flex.Item>
                <Flex.Item mt={2}>{stat.antagonist_popup.text}</Flex.Item>
              </Flex>
            </Box>
          </div>
        </Flex.Item>
      ) : null}
      {stat.alert_br ? (
        <Flex.Item mt={1} mb={1}>
          <div className="StatBorder_br">
            <Box>
              <Flex direction="column" className="stat_br">
                <Flex.Item bold>
                  <Button
                    color="transparent"
                    icon="times"
                    onClick={() =>
                      dispatch({
                        type: 'stat/clearAlertBr',
                      })
                    }
                  />
                  <Box inline>{stat.alert_br.title}</Box>
                </Flex.Item>
                <Flex.Item mt={2}>{stat.alert_br.text}</Flex.Item>
                <Flex.Item>
                  <Button
                    content="Rozpocznij"
                    color="transparent"
                    onClick={(e) =>
                      Byond.sendMessage('stat/pressed', {
                        action_id: 'start_br',
                      })
                    }
                  />
                  <Box inline>
                    <Button
                      content="Odrzuć"
                      color="transparent"
                      onClick={() =>
                        dispatch({
                          type: 'stat/clearAlertBr',
                        })
                      }
                    />
                  </Box>
                </Flex.Item>
              </Flex>
            </Box>
          </div>
        </Flex.Item>
      ) : null}
      <StatText />
    </Flex>
  );
};
