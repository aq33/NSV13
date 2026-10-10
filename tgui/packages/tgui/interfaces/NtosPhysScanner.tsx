import { Box, Dropdown, Section } from 'tgui-core/components';

import { useBackend } from '../backend';
import { NtosWindow } from '../layouts';
import { sanitizeText } from '../sanitize';

type Data = {
  available_modes: any;
  last_record: any;
  set_mode: any;
};

export const NtosPhysScanner = (props) => {
  const { act, data } = useBackend<Data>();
  const { set_mode, available_modes = [], last_record } = data;
  const textHtml = {
    __html: sanitizeText(last_record),
  };
  return (
    <NtosWindow width={600} height={350}>
      <NtosWindow.Content scrollable>
        <Section title="Scanner Mode">
          <Dropdown
            options={available_modes}
            selected={set_mode || 'Select Mode'}
            onSelected={(value) =>
              act('selectMode', {
                newMode: value,
              })
            }
          />
        </Section>
        {textHtml.__html.length ? (
          <Section title="Results">
            <Box
              style={{ whiteSpace: 'pre-line' }}
              dangerouslySetInnerHTML={textHtml}
            />
          </Section>
        ) : null}
      </NtosWindow.Content>
    </NtosWindow>
  );
};
