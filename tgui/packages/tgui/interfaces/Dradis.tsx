import { CSSProperties, useState } from 'react';
import { Button, Knob, Section } from 'tgui-core/components';

// NSV13
import { useBackend } from '../backend';
import { Map } from '../components';
import { Window } from '../layouts';

type Data = {
  can_radar_pulse: any;
  can_target: any;
  can_use_radar: any;
  dradis_targeting: any;
  focus_x: any;
  focus_y: any;
  pulse_delay: any;
  sensor_mode: any;
  ships: any;
  showAnomalies: any;
  showAsteroids: any;
  showEnemies: any;
  showFriendlies: any;
  width_mod: any;
  zoom_factor: any;
  zoom_factor_max: any;
  zoom_factor_min: any;
};

export const DradisContent = (props) => {
  const { act, data } = useBackend<Data>();
  // Bumping the key remounts the map, which centers it on the ship again
  const [focusKey, setFocusKey] = useState(0);

  const drawShips = (ship) => {
    let borderType = '1px solid ' + ship.colour;
    let markerStyle: CSSProperties = {
      height: '1px',
      position: 'absolute',
      left: ship.x * scale_factor + 'px',
      bottom: ship.y * scale_factor + 'px',
      border: borderType,
      opacity: ship.opacity,
      transition: 'all 0.5s ease-out',
    };
    let markerType = 'star_marker' + '_' + ship.alignment;
    return (
      <li key={ship.id}>
        {!!ship.name && (
          <Button
            style={markerStyle}
            className={markerType}
            content=""
            onClick={() => act('hail', { target: ship.id })}
          >
            <span className="star_label">
              <p>{ship.name}</p>
            </span>
          </Button>
        )}
      </li>
    );
  };

  const DradisMap = (ships, zoom_factor, width_mod, focus_x, focus_y) => {
    let scale_factor = 5 * zoom_factor;
    let multiplier = 562.5 * zoom_factor;
    let rangeStyle = {
      left: focus_x * scale_factor + 'px',
      bottom: focus_y * scale_factor + 'px',
      width: width_mod * multiplier + 'px',
      height: width_mod * multiplier + 'px',
      marginBottom: -1 * ((width_mod * multiplier) / 2) + 'px',
      marginLeft: -1 * ((width_mod * multiplier) / 2) + 'px',
    };
    let ShipMap = ships.map(drawShips);
    return (
      <Map
        key={focusKey}
        initial_focus_x={focus_x}
        initial_focus_y={focus_y}
        initial_scale_factor={scale_factor}
        grid
      >
        {ShipMap}
        <div id="rangeCircle" style={rangeStyle} />
      </Map>
    );
  };

  // Floats representing the different alpha values for different filtered objects.
  let showFriendlies = data.showFriendlies;
  let showEnemies = data.showEnemies;
  let showAsteroids = data.showAsteroids;
  let showAnomalies = data.showAnomalies;
  let focus_x = data.focus_x;
  let focus_y = data.focus_y;
  let zoom_factor = data.zoom_factor;
  let zoom_factor_min = data.zoom_factor_min;
  let zoom_factor_max = data.zoom_factor_max;
  let scale_factor = zoom_factor * 5;
  let dradis_targeting = data.dradis_targeting;
  let can_use_radar = data.can_use_radar;
  let dradis = DradisMap(
    data.ships,
    zoom_factor,
    data.width_mod,
    focus_x,
    focus_y,
  );

  return (
    <Section
      title="Settings:"
      buttons={
        <>
          <Button icon="search-plus" onClick={() => act('zoomin')} />
          <Button icon="search-minus" onClick={() => act('zoomout')} />
          {!!data.can_use_radar && (
            <>
              <Button
                content="Radar Pulse"
                icon="bullseye"
                disabled={!data.can_radar_pulse}
                onClick={() => act('radar_pulse')}
              />
              <Button
                content={data.sensor_mode}
                icon="project-diagram"
                onClick={() => act('sensor_mode')}
              />
              <Button
                content={data.pulse_delay}
                icon="stopwatch"
                onClick={() => act('radar_delay')}
              />
            </>
          )}
          <Button
            content="Re-focus"
            icon="camera"
            onClick={() => setFocusKey(focusKey + 1)}
          />
          {!!data.can_target && (
            <Button
              content={dradis_targeting ? 'Targeting' : 'Hailing'}
              icon={dradis_targeting ? 'bullseye' : 'square-o'}
              disabled={!data.can_target}
              color={data.dradis_targeting ? 'bad' : 'good'}
              onClick={() => act('dradis_targeting')}
            />
          )}
        </>
      }
    >
      Allies:
      <Knob
        inline
        mx={1}
        color={!!showFriendlies && 'green'}
        value={showFriendlies}
        unit="scan strength"
        minValue={0}
        maxValue={100}
        step={1}
        stepPixelSize={1}
        onDrag={(e, value) => act('showFriendlies', { alpha: value })}
      />
      Enemies:
      <Knob
        inline
        mx={1}
        color={!!showEnemies && 'green'}
        value={showEnemies}
        unit="scan strength"
        minValue={0}
        maxValue={100}
        step={1}
        stepPixelSize={1}
        onDrag={(e, value) => act('showEnemies', { alpha: value })}
      />
      Asteroids:
      <Knob
        inline
        mx={1}
        color={!!showAsteroids && 'green'}
        value={showAsteroids}
        unit="scan strength"
        minValue={0}
        maxValue={100}
        step={1}
        stepPixelSize={1}
        onDrag={(e, value) => act('showAsteroids', { alpha: value })}
      />
      Anomalies:
      <Knob
        inline
        mx={1}
        color={!!showAnomalies && 'green'}
        value={showAnomalies}
        unit="scan strength"
        minValue={0}
        maxValue={100}
        step={1}
        stepPixelSize={1}
        onDrag={(e, value) => act('showAnomalies', { alpha: value })}
      />
      Zoom:
      <Knob
        inline
        mx={1}
        color="green"
        value={zoom_factor * 100}
        unit="%"
        minValue={zoom_factor_min * 100}
        maxValue={zoom_factor_max * 100}
        step={1}
        stepPixelSize={1}
        onDrag={(e, value) => act('setZoom', { zoom: value })}
      />
      {dradis}
    </Section>
  );
};

export const Dradis = (props) => {
  let content = DradisContent(props);

  return (
    <Window theme="hackerman" width={700} height={750}>
      <Window.Content scrollable>{content}</Window.Content>
    </Window>
  );
};
