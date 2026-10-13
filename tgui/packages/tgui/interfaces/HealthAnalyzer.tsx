// AQUILA - health analyzer window, port of PowerfulBacon-2/AuriStation#15
// (aquila/code/game/objects/items/devices/health_analyzer_ui.dm)
import { useState } from 'react';
import { Button, Section, Tooltip } from 'tgui-core/components';

import { clamp01 } from '../../common/math';
import { useBackend } from '../backend';
import ScrollingChart from '../components/ScrollingChart';
import { Window } from '../layouts';

const bodyPart =
  'M16 0c-3 0-3 3-3 4-1 0-1 1 0 2 0 2 2 3 2 4s-1 2-4 3-3 2-3 4c0 5 0 9-1 12s-2 5-3 6-1 2-3 2c-1 0-1 1 2 1-1 1-2 1-2 3 0 1 2 2 4-1s4-6 5-10c1-3 1-5 1-8 1 2 1 4 0 7s-2 5-2 8c0 4 0 9 1 13s1 3 1 6c0 2-1 4-1 6 1 3 2 5 2 8 0 4-2 4-2 5s0 1 1 1h3c1 0 1-1 1-3-1-3-1-5 0-8s0-5 0-7c0-1-1-1 0-5 0-2 1-5 1-12 0 7 1 10 1 12 1 4 0 4 0 5 0 2-1 4 0 7 1 3 1 5 0 8 0 2 0 3 1 3h3c1 0 1-1 1-1 0-1-2-1-2-5 0-3 1-5 2-8 0-2-1-4-1-6 0-3 0-2 1-6 1-3 1-9 1-13 0-3-1-5-2-8s-1-5 0-7c0 3 0 5 1 8 1 4 3 7 5 10s4 2 4 1c0-2-1-2-2-3 3 0 3-1 2-1-2 0-2-1.3333-3-2-1-1-2-3-3-6s-1-7-1-12c0-2 0-3-3-4s-4-2-4-3 2-2 2-4c1-1 1-2 0-2 0-1 0-4-3-4';

type BodyZoneUIPart = {
  outline: string;
  hitbox: string;
  zone: string;
  center: { x: number; y: number };
};

const bodyParts: BodyZoneUIPart[] = [
  {
    outline:
      'M17 10c0-1 2-2 2-4 1-1 1-2 0-2 0-1 0-4-3-4S13 3 13 4c-1 0-1 1 0 2 0 2 2 3 2 4Z',
    hitbox: 'M0 0 35 0 35 11 0 11Z',
    zone: 'head',
    center: { x: 16, y: 5 },
  },
  {
    outline:
      'M11 13c-3 1-3 2-3 4 0 5 0 9-1 12s-2 5-3 6-1 2-3 2c-1 0-1 1 2 1-1 1-2 1-2 3 0 1 2 2 4-1s4-6 5-10c1-3 1-5 1-8Z',
    hitbox: 'M0 11 11 11 11 22 11 28 6 42 0 42 0 22Z',
    zone: 'r_arm',
    center: { x: 8, y: 26.5 },
  },
  {
    outline:
      'M15 10C15 11 14 12 11 13L11 23c1 2 1 4 0 7s-2 5-2 8L23 38C23 35 22 33 21 30S20 24 21 22L21 13c-3-1-4-2-4-3Z',
    hitbox: 'M11 11 21 11 21 28 24.2 37 7.8 37 11 28Z',
    zone: 'chest',
    center: { x: 16, y: 24 },
  },
  {
    outline:
      'M21 13c3 1 3 2 3 4 0 5 0 9 1 12s2 5 3 6 1 2 3 2c1 0 1 1-2 1 1 1 2 1 2 3 0 1-2 2-4-1s-4-6-5-10c-1-3-1-5-1-8Z',
    hitbox: 'M32 11 21 11 21 22 21 28 26 42 32 42 32 22Z',
    zone: 'l_arm',
    center: { x: 24, y: 26.5 },
  },
  {
    outline:
      'M9 37c0 4 0 9 1 13s1 3 1 6c0 2-1 4-1 6 1 3 2 5 2 8 0 4-2 4-2 5s0 1 1 1h3c1 0 1-1 1-3-1-3-1-5 0-8s0-5 0-7c0-1-1-1 0-5 0-2 1-5 1-12L16 37Z',
    hitbox: 'M0 42 5 42 7.8 37 16 37 16 80 0 80Z',
    zone: 'r_leg',
    center: { x: 12, y: 58.5 },
  },
  {
    outline:
      'M23 37c0 4 0 9-1 13s-1 3-1 6c0 2 1 4 1 6-1 3-2 5-2 8 0 4 2 4 2 5s0 1-1 1h-3c-1 0-1-1-1-3 1-3 1-5 0-8s0-5 0-7c0-1 1-1 0-5 0-2-1-5-1-12L16 37Z',
    hitbox: 'M16 37 24.2 37 26 42 35 42 35 80 16 80Z',
    zone: 'l_leg',
    center: { x: 20, y: 58.5 },
  },
];

const ZONE_NAMES = {
  body: 'Całe ciało',
  head: 'Głowa',
  chest: 'Tułów',
  l_arm: 'Lewa ręka',
  r_arm: 'Prawa ręka',
  l_leg: 'Lewa noga',
  r_leg: 'Prawa noga',
};

enum InjurySeverity {
  None = 0,
  Healing = 1,
  Active = 2,
}

type InjuryEntry = {
  name: string;
  heal_text: string;
  damage?: number | string;
  severity?: InjurySeverity;
};

type Injuries = { [area: string]: InjuryEntry[] };

type ReagentEntry = {
  name: string;
  colour: string;
  volume: number;
};

type Data = {
  target?: string;
  is_dead?: boolean;
  consciousness?: number;
  damage?: number;
  circulation?: number;
  oxygenation?: number;
  injuries?: Injuries;
  body_temperature?: string;
  species?: string;
  blood_type?: string;
  blood_volume?: number;
  reagents?: ReagentEntry[];
};

const isActive = (injury: InjuryEntry) =>
  injury.severity === InjurySeverity.Active || injury.severity === undefined;

export const HealthAnalyzer = (props) => {
  const { act, data } = useBackend<Data>();
  const [selectedSection, setSelectedSection] = useState('chest');

  if (!data.target) {
    return (
      <Window width={510} height={594}>
        <Window.Content>Brak pacjenta.</Window.Content>
      </Window>
    );
  }

  const circulation = Math.min(data.circulation ?? 0, 1.1);
  let heartBpm =
    72 +
    0.8 * (100 - circulation * 100) +
    120 * Math.exp(-Math.pow((circulation * 100 - 10) / 10, 2));
  if (circulation <= 0) {
    heartBpm = 0;
  }
  const heartTickRate = heartBpm ? Math.round((20 * 60) / heartBpm) : 0;
  const consciousness = clamp01(Math.abs(data.consciousness ?? 1));

  return (
    <Window width={540} height={620} title={`Analizator: ${data.target}`}>
      <Window.Content className="health_analyzer">
        <div className="interface_main">
          <div className="body_overview">
            <svg width="140" height="320" viewBox="0 0 35 80">
              <defs>
                <clipPath id="consciousnessClip">
                  <rect
                    x="0"
                    y={80 - consciousness * 80}
                    width="35"
                    height={consciousness * 80}
                  />
                </clipPath>
                <filter id="staticNoise">
                  <feTurbulence
                    type="fractalNoise"
                    baseFrequency="1.2"
                    numOctaves="1"
                    seed="1"
                    result="noise"
                  >
                    <animate
                      attributeName="seed"
                      values="1;2;3;4;5;6;7;8;9;10"
                      dur="0.12s"
                      repeatCount="indefinite"
                    />
                  </feTurbulence>
                  <feColorMatrix type="saturate" values="0" />
                  <feComponentTransfer>
                    <feFuncR type="discrete" tableValues="0 1" />
                    <feFuncG type="discrete" tableValues="0 1" />
                    <feFuncB type="discrete" tableValues="0 1" />
                  </feComponentTransfer>
                </filter>
              </defs>
              <path
                d={bodyPart}
                stroke="none"
                fill={(data.consciousness ?? 0) >= 0 ? 'green' : 'red'}
                clipPath="url(#consciousnessClip)"
              />
              <path d={bodyPart} stroke="white" fill="none" strokeWidth="0.5" />
              {bodyParts.map((part) => {
                const active = (data.injuries?.[part.zone] ?? []).filter(
                  isActive,
                );
                return (
                  <g key={part.zone}>
                    <path
                      className="areaPath"
                      d={part.outline}
                      stroke={
                        selectedSection === part.zone
                          ? 'rgb(255, 248, 56)'
                          : 'none'
                      }
                    />
                    <path
                      className="areaHitbox"
                      d={part.hitbox}
                      onClick={() => setSelectedSection(part.zone)}
                      stroke="none"
                      fill="transparent"
                    />
                    {active.length > 0 && (
                      <>
                        <circle
                          cx={part.center.x}
                          cy={part.center.y}
                          r={3}
                          stroke={GetWorstInjuryColour(active)}
                          fill="#212637"
                        />
                        <text
                          x={part.center.x}
                          y={part.center.y}
                          fill="white"
                          fontSize={4}
                          textAnchor="middle"
                          dominantBaseline="middle"
                        >
                          {active.length}
                        </text>
                      </>
                    )}
                  </g>
                );
              })}
              {data.is_dead && (
                <>
                  <rect
                    x="0"
                    y="0"
                    width="35"
                    height="80"
                    fill="rgba(0, 0, 0, 1)"
                    filter="url(#staticNoise)"
                    opacity={0.5}
                  />
                  <rect
                    x="0"
                    y="26"
                    width="35"
                    height="11"
                    fill="rgba(0, 0, 0, 0.7)"
                  />
                  <text
                    x="16"
                    y="32"
                    fill="white"
                    fontSize="6"
                    fontWeight="bold"
                    textAnchor="middle"
                    dominantBaseline="middle"
                  >
                    Zgon
                  </text>
                </>
              )}
            </svg>
            <div className="chart_container heart">
              Krążenie
              <ScrollingChart
                className="chart"
                generator={(params) =>
                  heartTickRate && params.steps % heartTickRate === 0
                    ? circulation * 0.5 + 0.25
                    : 0.25
                }
                frameRate={20}
                maxValues={60}
                lineColour="lime"
                label={
                  <>
                    <p>{Math.round(heartBpm) + ' BPM'}</p>
                    <p>{Math.round(circulation * 100) + '%'}</p>
                  </>
                }
              />
            </div>
            <div className="chart_container oxygen">
              Tlen
              <ScrollingChart
                className="chart"
                generator={() => (data.oxygenation ?? 0) * 0.75}
                frameRate={10}
                maxValues={60}
                lineColour="cyan"
                label={Math.round((data.oxygenation ?? 0) * 100) + '%'}
              />
            </div>
            <div className="chart_container blood">
              Krew
              <ScrollingChart
                className="chart"
                generator={() => (data.blood_volume ?? 0) / 650}
                frameRate={10}
                maxValues={60}
                lineColour="red"
                label={Math.round(data.blood_volume ?? 0) + ' cl'}
              />
            </div>
            <div className="chart_container pain">
              Obrażenia
              <ScrollingChart
                className="chart"
                generator={() => (data.damage ?? 0) / 220 + 0.1}
                frameRate={10}
                maxValues={60}
                lineColour="yellow"
                label={Math.round(data.damage ?? 0) + '%'}
              />
            </div>
          </div>
          <div className="side_bar">
            <Section
              title={data.target}
              buttons={
                <Button
                  icon="comment-medical"
                  tooltip="Wypisz pełny skan na czat"
                  onClick={() => act('print_chat')}
                />
              }
            >
              {!!data.species && <div>Gatunek: {data.species}</div>}
              {!!data.blood_type && <div>Grupa krwi: {data.blood_type}</div>}
              {!!data.body_temperature && (
                <div>Temperatura: {data.body_temperature}</div>
              )}
            </Section>
            {!!data.injuries?.body && MapZone('body', data.injuries.body)}
            {selectedSection !== 'body' &&
              !!data.injuries?.[selectedSection] &&
              MapZone(selectedSection, data.injuries[selectedSection])}
            {!!data.reagents && (
              <Section title="Substancje we krwi">
                <div className="injury_row">
                  {data.reagents.map((reagent) =>
                    MapInjury({
                      name: reagent.name,
                      damage: reagent.volume,
                      heal_text: '',
                      severity: InjurySeverity.None,
                    }),
                  )}
                  {data.reagents.length === 0 && 'Brak'}
                </div>
              </Section>
            )}
          </div>
        </div>
      </Window.Content>
    </Window>
  );
};

const MapZone = (zone: string, injuries: InjuryEntry[]) => {
  const sorted = [...injuries].sort(
    (a, b) => (b.severity ?? 2) - (a.severity ?? 2),
  );
  return (
    <Section title={ZONE_NAMES[zone] || zone} key={zone}>
      <div className="injury_row">
        {sorted.map(MapInjury)}
        {injuries.length === 0 && 'Brak obrażeń'}
      </div>
    </Section>
  );
};

const MapInjury = (injury: InjuryEntry) => {
  const icon = (
    <div key={injury.name} className="injury_entry">
      <div
        className="injury_icon"
        style={{
          borderColor: GetInjuryColour(injury),
        }}
      >
        {typeof injury.damage === 'number' && injury.damage > 0
          ? injury.damage.toFixed(1)
          : injury.damage !== 0 && injury.damage}
      </div>
      <div>{injury.name}</div>
    </div>
  );
  if (!injury.heal_text) {
    return icon;
  }
  return (
    <Tooltip key={injury.name} content={injury.heal_text}>
      {icon}
    </Tooltip>
  );
};

function mixColors(color1: string, color2: string, amount = 0.5) {
  const hexToRgb = (hex: string) => {
    hex = hex.replace('#', '');
    return [
      parseInt(hex.slice(0, 2), 16),
      parseInt(hex.slice(2, 4), 16),
      parseInt(hex.slice(4, 6), 16),
    ];
  };
  const rgbToHex = (rgb: number[]) =>
    '#' + rgb.map((x) => Math.round(x).toString(16).padStart(2, '0')).join('');
  const a = hexToRgb(color1);
  const b = hexToRgb(color2);
  const clamped = Math.min(Math.max(amount, 0), 1);
  return rgbToHex(a.map((value, i) => value + (b[i] - value) * clamped));
}

function GetInjuryColour(injury: InjuryEntry) {
  if (typeof injury.damage === 'number' && injury.damage > 0) {
    return mixColors('#29ba41', '#b82828', injury.damage / 50);
  }
  return injury.severity === InjurySeverity.None ||
    injury.severity === InjurySeverity.Healing
    ? '#29ba41'
    : '#b82828';
}

function GetWorstInjuryColour(injuries: InjuryEntry[]) {
  const worst = [...injuries].sort((a, b) => {
    const severity = (b.severity ?? 2) - (a.severity ?? 2);
    if (severity) {
      return severity;
    }
    const damage = (x: InjuryEntry) =>
      typeof x.damage === 'number' ? x.damage : 0;
    return damage(b) - damage(a);
  })[0];
  return worst ? GetInjuryColour(worst) : undefined;
}
