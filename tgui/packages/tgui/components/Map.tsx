// NSV13: draggable, scrollable map used by the starmap consoles.

import { Component, createRef, PropsWithChildren } from 'react';

type Props = PropsWithChildren<{
  initial_focus_x: number;
  initial_focus_y: number;
  initial_scale_factor: number;
  grid?: boolean;
}>;

export class Map extends Component<Props> {
  mapContainerRef = createRef<HTMLDivElement>();
  resizeObserver?: ResizeObserver;
  // Once the player drags the map, window resizes no longer re-center it
  userMoved = false;

  constructor(props: Props) {
    super(props);
    this.handleMouseDown = this.handleMouseDown.bind(this);
  }

  componentDidMount() {
    const map = this.mapContainerRef.current;
    if (!map) {
      return;
    }
    this.focus();
    // AQUILA: React mounts the map before tgui sizes the window, so the first
    // scroll gets clamped to the old window size. Re-apply it on resize.
    this.resizeObserver = new ResizeObserver(() => {
      if (!this.userMoved) {
        this.focus();
      }
    });
    this.resizeObserver.observe(map);
    if (map.firstElementChild) {
      this.resizeObserver.observe(map.firstElementChild);
    }
  }

  componentWillUnmount() {
    this.resizeObserver?.disconnect();
  }

  focus() {
    const map = this.mapContainerRef.current;
    if (!map) {
      return;
    }
    const { initial_focus_x, initial_focus_y, initial_scale_factor, grid } =
      this.props;
    // Do not question this. It just works.
    if (!grid) {
      map.scrollLeft = initial_focus_x * initial_scale_factor - 300;
      map.scrollTop = (100 - initial_focus_y) * initial_scale_factor + 500;
    } else {
      map.scrollLeft = initial_focus_x * initial_scale_factor - 500;
      map.scrollTop = (100 - initial_focus_y) * initial_scale_factor + 2500;
    }
  }

  handleMouseDown(e: React.MouseEvent) {
    if (e.button !== 0) {
      return;
    }
    // Stops text selection, which used to scroll the whole window instead of the map
    e.preventDefault();
    let curr_x = e.screenX;
    let curr_y = e.screenY;

    const mousemove = (event: MouseEvent) => {
      event.preventDefault();
      const map = this.mapContainerRef.current;
      if (!map) {
        return;
      }
      this.userMoved = true;
      map.scrollLeft -= event.screenX - curr_x;
      map.scrollTop -= event.screenY - curr_y;
      curr_x = event.screenX;
      curr_y = event.screenY;
    };
    const mouseup = () => {
      document.removeEventListener('mousemove', mousemove);
      document.removeEventListener('mouseup', mouseup);
    };
    document.addEventListener('mousemove', mousemove);
    document.addEventListener('mouseup', mouseup);
  }

  render() {
    const { grid, children } = this.props;
    return (
      <div
        id="mapContainer"
        ref={this.mapContainerRef}
        onMouseDown={this.handleMouseDown}
        className={grid ? 'outerbgdradis' : 'outerbg'}
        style={{ userSelect: 'none' }}
      >
        <div className={grid ? 'innerbgdradis' : 'innerbg'} id="mapDraggable">
          {children}
        </div>
      </div>
    );
  }
}
