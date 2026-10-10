// NSV13: draggable, scrollable map used by the starmap consoles.

import { Component, createRef, PropsWithChildren } from 'react';

type Props = PropsWithChildren<{
  initial_focus_x: number;
  initial_focus_y: number;
  initial_scale_factor: number;
  grid?: boolean;
}>;

type State = {
  focus_x: number;
  focus_y: number;
  grid?: boolean;
  scale_factor: number;
};

export class Map extends Component<Props, State> {
  mapContainerRef = createRef<HTMLDivElement>();

  constructor(props: Props) {
    super(props);
    const { initial_focus_x, initial_focus_y, initial_scale_factor, grid } =
      props;
    this.state = {
      focus_x: initial_focus_x,
      focus_y: initial_focus_y,
      grid: grid,
      scale_factor: initial_scale_factor,
    };
    this.handleMouseDown = this.handleMouseDown.bind(this);
  }

  componentDidMount() {
    const map = this.mapContainerRef.current;
    if (!map) {
      return;
    }
    // Do not question this. It just works.
    if (!this.state.grid) {
      map.scrollLeft = this.state.focus_x * this.state.scale_factor - 300;
      map.scrollTop =
        (100 - this.state.focus_y) * this.state.scale_factor + 500;
    } else {
      map.scrollLeft = this.state.focus_x * this.state.scale_factor - 500;
      map.scrollTop =
        (100 - this.state.focus_y) * this.state.scale_factor + 2500;
    }
    this.setState({
      focus_x: map.scrollLeft,
      focus_y: map.scrollTop,
    });
  }

  handleMouseDown(e: React.MouseEvent) {
    let curr_x = e.screenX;
    let curr_y = e.screenY;

    const mousemove = (event: MouseEvent) => {
      event.preventDefault();
      const map = this.mapContainerRef.current;
      if (!map) {
        return;
      }
      map.scrollLeft = this.state.focus_x - (event.screenX - curr_x);
      map.scrollTop = this.state.focus_y - (event.screenY - curr_y);
      this.setState({
        focus_x: map.scrollLeft,
        focus_y: map.scrollTop,
      });
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
    return (
      <div
        id="mapContainer"
        ref={this.mapContainerRef}
        onMouseDown={this.handleMouseDown}
        className={this.state.grid ? 'outerbgdradis' : 'outerbg'}
      >
        <div
          className={this.state.grid ? 'innerbgdradis' : 'innerbg'}
          id="mapDraggable"
        >
          {this.props.children}
        </div>
      </div>
    );
  }
}
