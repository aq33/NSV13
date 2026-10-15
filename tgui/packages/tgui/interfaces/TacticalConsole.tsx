// NSV13

import { Fragment } from 'react';
import {
  Box,
  Button,
  LabeledList,
  NumberInput,
  ProgressBar,
  Section,
} from 'tgui-core/components';

import { useBackend, useLocalState } from '../backend';
import { Window } from '../layouts';

type Data = {
  additional_weapon_info: any;
  armour_integrity: any;
  has_quadrant: any;
  integrity: any;
  max_armour_integrity: any;
  max_integrity: any;
  modifying_weapon_priorities: any;
  no_gun_cam: any;
  painted_targets: any;
  quadrant_ap_armour_current: any;
  quadrant_ap_armour_max: any;
  quadrant_as_armour_current: any;
  quadrant_as_armour_max: any;
  quadrant_fp_armour_current: any;
  quadrant_fp_armour_max: any;
  quadrant_fs_armour_current: any;
  quadrant_fs_armour_max: any;
  target_name: any;
  weapons: any;
};

export const TacticalConsole = (props) => {
  const { act, data } = useBackend<Data>();
  const tabIndex = 1;
  return (
    <Window theme="nanotrasen" width={560} height={600}>
      <Window.Content scrollable>
        <Section>
          <Section title="Ship status">
            <Section title="Hull integrity:">
              <ProgressBar
                value={(data.integrity / data.max_integrity) * 100 * 0.01}
                ranges={{
                  good: [0.95, Infinity],
                  average: [0.15, 0.9],
                  bad: [-Infinity, 0.15],
                }}
              />
            </Section>
            <Section title="Armour:">
              {(data.has_quadrant && (
                <LabeledList>
                  <LabeledList.Item label="Forward Port" labelColor="#ffffff">
                    <ProgressBar
                      value={
                        data.quadrant_fp_armour_current /
                        data.quadrant_fp_armour_max
                      }
                      ranges={{
                        good: [0.66, Infinity],
                        average: [0.33, 0.66],
                        bad: [-Infinity, 0.33],
                      }}
                    />
                  </LabeledList.Item>
                  <LabeledList.Item
                    label="Forward Starboard"
                    labelColor="#ffffff"
                  >
                    <ProgressBar
                      value={
                        data.quadrant_fs_armour_current /
                        data.quadrant_fs_armour_max
                      }
                      ranges={{
                        good: [0.66, Infinity],
                        average: [0.33, 0.66],
                        bad: [-Infinity, 0.33],
                      }}
                    />
                  </LabeledList.Item>
                  <LabeledList.Item label="Aft Port" labelColor="#ffffff">
                    <ProgressBar
                      value={
                        data.quadrant_ap_armour_current /
                        data.quadrant_ap_armour_max
                      }
                      ranges={{
                        good: [0.66, Infinity],
                        average: [0.33, 0.66],
                        bad: [-Infinity, 0.33],
                      }}
                    />
                  </LabeledList.Item>
                  <LabeledList.Item label="Aft Starboard" labelColor="#ffffff">
                    <ProgressBar
                      value={
                        data.quadrant_as_armour_current /
                        data.quadrant_as_armour_max
                      }
                      ranges={{
                        good: [0.66, Infinity],
                        average: [0.33, 0.66],
                        bad: [-Infinity, 0.33],
                      }}
                    />
                  </LabeledList.Item>
                </LabeledList>
              )) || (
                <LabeledList>
                  <LabeledList.Item label="Integrity" labelColor="#ffffff">
                    <ProgressBar
                      value={
                        (data.armour_integrity / data.max_armour_integrity) *
                        100 *
                        0.01
                      }
                      ranges={{
                        good: [0.9, Infinity],
                        average: [0.15, 0.9],
                        bad: [-Infinity, 0.15],
                      }}
                    />
                  </LabeledList.Item>
                </LabeledList>
              )}
            </Section>
          </Section>
          <Section
            title="Armaments:"
            buttons={
              <>
                <Button
                  icon="cog"
                  color={data.additional_weapon_info ? 'good' : 'default'}
                  content="Expanded Info"
                  onClick={() => act('toggle_additional_weapon_info')}
                />
                <Button
                  icon="wrench"
                  color={data.modifying_weapon_priorities ? 'blue' : 'grey'}
                  disabled={!data.additional_weapon_info}
                  onClick={() => act('toggle_weapon_priority_modification')}
                />
              </>
            }
          >
            <LabeledList>
              {Object.keys(data.weapons).map((key) => {
                let value = data.weapons[key];
                return (
                  <Fragment key={key}>
                    {!!value.maxammo && (
                      <LabeledList.Item
                        label={`${value.name}`}
                        labelColor="#ffffff"
                      >
                        <ProgressBar
                          value={(value.ammo / value.maxammo) * 100 * 0.01}
                          ranges={{
                            good: [0.95, Infinity],
                            average: [0.15, 0.9],
                            bad: [-Infinity, 0.15],
                          }}
                        />
                        {!!data.additional_weapon_info &&
                          ((!!data.modifying_weapon_priorities &&
                            !!value.can_modify_priority && (
                              <Box>
                                <br />
                                {'Priority: '}
                                <NumberInput
                                  step={1}
                                  value={value.weapon_priority}
                                  width="47px"
                                  minValue={1}
                                  maxValue={900}
                                  onChange={(input_number) =>
                                    act('change_weapon_priority', {
                                      target_weapon: value.weapon_ref,
                                      new_priority: input_number,
                                    })
                                  }
                                />
                              </Box>
                            )) || (
                            <Box>
                              <br />
                              {'Priority: ' + value.weapon_priority}
                            </Box>
                          ))}
                        {!!value.controllers && (
                          <Box>
                            <br />
                            {'Weapon controllers: ' + value.controllers}
                          </Box>
                        )}
                        {!!value.ammo_filter && (
                          <Box>
                            <br />
                            {'Filtered ammo: ' + value.ammo_filter}
                          </Box>
                        )}
                        <br />
                      </LabeledList.Item>
                    )}
                  </Fragment>
                );
              })}
            </LabeledList>
          </Section>
          <Section title="Tracking:">
            {!data.no_gun_cam && (
              <Button
                width="100%"
                fluid
                content={'Toggle Gun Camera'}
                icon="bullseye"
                onClick={() => act('toggle_gun_camera')}
              />
            )}
            {Object.keys(data.painted_targets).map((key, newCurrent) => {
              let value = data.painted_targets[key];
              const [current, setCurrent] = useLocalState('fs_current', true);
              const [hidden, setHidden] = useLocalState('fs_hidden', true);

              return (
                <Fragment key={key}>
                  {!!value.name && (
                    <Section>
                      <Button
                        width="100%"
                        fluid
                        onClick={() => {
                          setCurrent(value.name);
                          setHidden(!hidden);
                        }}
                      >
                        {`${value.name}`}
                      </Button>
                      {!!(current === value.name) && !hidden && (
                        <Section title="Armour">
                          <LabeledList>
                            <LabeledList.Item label="Forward Starboard">
                              <ProgressBar
                                value={
                                  (value.quadrant_fp_armour_current /
                                    value.quadrant_fp_armour_max) *
                                  100 *
                                  0.01
                                }
                                ranges={{
                                  good: [0.95, Infinity],
                                  average: [0.15, 0.9],
                                  bad: [-Infinity, 0.15],
                                }}
                              />
                            </LabeledList.Item>
                            <LabeledList.Item label="Forward Port">
                              <ProgressBar
                                value={
                                  (value.quadrant_fs_armour_current /
                                    value.quadrant_fs_armour_max) *
                                  100 *
                                  0.01
                                }
                                ranges={{
                                  good: [0.95, Infinity],
                                  average: [0.15, 0.9],
                                  bad: [-Infinity, 0.15],
                                }}
                              />
                            </LabeledList.Item>
                            <LabeledList.Item label="Aft Starboard">
                              <ProgressBar
                                value={
                                  (value.quadrant_as_armour_current /
                                    value.quadrant_as_armour_max) *
                                  100 *
                                  0.01
                                }
                                ranges={{
                                  good: [0.95, Infinity],
                                  average: [0.15, 0.9],
                                  bad: [-Infinity, 0.15],
                                }}
                              />
                            </LabeledList.Item>
                            <LabeledList.Item label="Aft Port">
                              <ProgressBar
                                value={
                                  (value.quadrant_ap_armour_current /
                                    value.quadrant_ap_armour_max) *
                                  100 *
                                  0.01
                                }
                                ranges={{
                                  good: [0.95, Infinity],
                                  average: [0.15, 0.9],
                                  bad: [-Infinity, 0.15],
                                }}
                              />
                            </LabeledList.Item>
                          </LabeledList>
                        </Section>
                      )}
                      <Section>
                        <LabeledList>
                          <LabeledList.Item label="Integrity">
                            <ProgressBar
                              value={
                                (value.integrity / value.max_integrity) *
                                100 *
                                0.01
                              }
                              ranges={{
                                good: [0.95, Infinity],
                                average: [0.15, 0.9],
                                bad: [-Infinity, 0.15],
                              }}
                            />
                          </LabeledList.Item>
                        </LabeledList>
                      </Section>
                      <Button
                        fluid
                        content={
                          data.target_name === value.name
                            ? `Stop Targeting ${value.name}`
                            : `Target ${value.name}`
                        }
                        icon="bullseye"
                        onClick={() => act('lock_ship', { target: value.name })}
                      />
                      <Button
                        fluid
                        content={`Stop Tracking ${value.name}`}
                        icon="bullseye"
                        onClick={() => act('dump_lock', { target: value.name })}
                      />
                    </Section>
                  )}
                </Fragment>
              );
            })}
          </Section>
        </Section>
      </Window.Content>
    </Window>
  );
};
