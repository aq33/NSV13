// AQUILA - okno roli szpiega (port z tgstation)
import { Section, Stack } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { sanitizeText } from '../sanitize';
import { Objective } from './common/ObjectiveSection';

const greenText = {
  fontStyle: 'italic',
  color: '#20b142',
};

const redText = {
  fontStyle: 'italic',
  color: '#e03c3c',
};

type Data = {
  antag_name: string;
  uplink_location: string | null;
  objectives: Objective[];
};

export const AntagInfoSpy = () => {
  const { data } = useBackend<Data>();
  const { antag_name, uplink_location, objectives } = data;
  return (
    <Window width={380} height={450} theme="ntos_darkmode">
      <Window.Content
        scrollable
        style={{
          backgroundImage: 'none',
        }}
      >
        <Section title={`Jesteś: ${antag_name || 'Szpieg'}.`}>
          <Stack vertical fill ml={1} mr={1}>
            <Stack.Item fontSize={1.2}>
              Dostałeś specjalny uplink ukryty jako{' '}
              {uplink_location || 'coś przy tobie'}. Dzięki niemu okradniesz
              statek.
            </Stack.Item>
            <Stack.Item>
              <span style={greenText}>
                <b>Użyj go w ręce</b>, żeby otworzyć listę zleceń, i kliknij nim{' '}
                <b>prawym przyciskiem</b> na cel zlecenia, żeby go ukraść.
              </span>
            </Stack.Item>
            <Stack.Divider />
            <Stack.Item>
              Możesz nie być sam: na statku mogą być inni szpiedzy.
            </Stack.Item>
            <Stack.Item>
              Współpracuj z nimi albo działaj przeciwko nim, wybór należy do
              ciebie, ale{' '}
              <span style={redText}>
                tego samego zlecenia nie da się wykonać dwa razy.
              </span>
            </Stack.Item>
            <Stack.Divider />
            <Stack.Item bold>Twoja misja, jeśli ją przyjmiesz:</Stack.Item>
            {(!objectives?.length && <Stack.Item>Brak.</Stack.Item>) ||
              objectives.map((objective) => (
                <Stack.Item key={objective.count}>
                  #{objective.count}:{' '}
                  <span
                    // eslint-disable-next-line react/no-danger
                    dangerouslySetInnerHTML={{
                      __html: sanitizeText(objective.explanation, false),
                    }}
                  />
                </Stack.Item>
              ))}
          </Stack>
        </Section>
      </Window.Content>
    </Window>
  );
};
