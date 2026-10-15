import { NoticeBox } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { LaunchpadControl } from './LaunchpadConsole';

type Data = {
  has_pad: any;
  pad_closed: any;
};

export const LaunchpadRemote = (props) => {
  const { data } = useBackend<Data>();
  const { has_pad, pad_closed } = data;
  return (
    <Window theme="syndicate" width={300} height={240}>
      <Window.Content>
        {(!has_pad && <NoticeBox>No Launchpad Connected</NoticeBox>) ||
          (pad_closed && <NoticeBox>Launchpad Closed</NoticeBox>) || (
            <LaunchpadControl topLevel />
          )}
      </Window.Content>
    </Window>
  );
};
