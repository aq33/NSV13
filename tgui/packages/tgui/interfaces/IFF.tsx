// NSV13

import { Section } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  iff_theme: any;
  is_hackerman: any;
};

export const IFF = (props) => {
  const { act, data } = useBackend<Data>();
  return (
    <Window theme={data.iff_theme} width={600} height={800}>
      <Window.Content scrollable>
        {!data.is_hackerman && (
          <Section title="ACCESS DENIED.">
            <img src="https://nsv.beestation13.com/mediawiki2/images/8/8f/SolGov.png" />
            <br />
            {'FILE ACCESS ENCRYPTED.'}
            <br />
            {
              'Reprogramming IFF chips is in violation of SolGov conflict regulation #A230385-C. Lethal force is authorised for ships found to have tampered with their IFF.'
            }
          </Section>
        )}
        {!!data.is_hackerman && (
          <Section title="./iff_bustr.exe">
            {`
.####.########.########.........########..##.....##..######..########.########.\n
..##..##.......##...............##.....##.##.....##.##....##....##....##.....##\n
..##..##.......##...............##.....##.##.....##.##..........##....##.....##\n
..##..######...######...........########..##.....##..######.....##....########.\n
..##..##.......##...............##.....##.##.....##.......##....##....##...##..\n
..##..##.......##...............##.....##.##.....##.##....##....##....##....##.\n
.####.##.......##.......#######.########...#######...######.....##....##.....##\n
            `}
            <br />
            {'___________________________________'}
            <br />
            {'br34ch3r.dll: loaded'}
            <br />
            {'5ysbr34k3r.dll: loaded'}
            <br />
            {'bye_bye_iff.dll: loaded'}
            <br />
            {'package upload in progress'}
          </Section>
        )}
      </Window.Content>
    </Window>
  );
};
