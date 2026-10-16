// AQUILA - port of PowerfulBacon-2/AuriStation#15
import { useEffect, useState } from 'react';
import { classes } from 'tgui-core/react';

interface ScrollingChartProps {
  className?: string;
  frameRate?: number;
  maxValues?: number;
  lineColour?: string;
  generator: ScrollingChartGenerator;
  label?: string | any;
}

interface ScrollingChartData {
  timeElapsed: number;
  stepsElapsed: number;
  previousValues: number[];
}

interface ScrollingChartParams {
  time: number;
  steps: number;
}

type ScrollingChartGenerator = (params: ScrollingChartParams) => number;

export default function ScrollingChart(props: ScrollingChartProps) {
  const [data, setData] = useState<ScrollingChartData>({
    timeElapsed: 0,
    stepsElapsed: 0,
    previousValues: [],
  });

  useEffect(() => {
    const frameRate = props.frameRate ?? 30;

    const interval = setInterval(() => {
      setData((data) => {
        const nextTime = data.timeElapsed + 1 / frameRate;
        const nextStep = props.generator({
          time: nextTime,
          steps: data.stepsElapsed + 1,
        });

        const allowedValues = props.maxValues ?? 30;

        return {
          timeElapsed: nextTime,
          previousValues: [
            ...data.previousValues.slice(
              Math.max(data.previousValues.length - allowedValues + 1, 0),
              allowedValues,
            ),
            nextStep,
          ],
          stepsElapsed: data.stepsElapsed + 1,
        };
      });
    }, 1000 / frameRate);

    return () => clearInterval(interval);
  }, [props.frameRate, props.maxValues, props.generator]);

  const values = data.previousValues;

  const points = values
    .map((value, index) => {
      const x = values.length <= 1 ? 100 : (index / (values.length - 1)) * 100;

      // Assumes generator produces values between 0 and 1.
      const y = (1 - value) * 100;

      return `${x},${y}`;
    })
    .join(' ');

  return (
    <div className={classes([props.className, 'scrollingChart'])}>
      <svg
        width="100%"
        height="100%"
        viewBox="0 0 100 100"
        preserveAspectRatio="none"
      >
        <polyline
          points={points}
          fill="none"
          stroke={props.lineColour ?? 'green'}
          strokeWidth="1"
          vectorEffect="non-scaling-stroke"
        />
      </svg>
      {!!props.label && (
        <div
          className="label"
          style={{
            color: props.lineColour ?? 'white',
          }}
        >
          {props.label}
        </div>
      )}
    </div>
  );
}
