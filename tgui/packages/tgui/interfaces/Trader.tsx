// NSV13

import { Button, Section } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  desc: any;
  greeting: any;
  holding_cargo: any;
  image: any;
  items_info: any;
  next_restock: any;
  points: any;
  theme: any;
};

export const Trader = (props) => {
  const { act, data } = useBackend<Data>();
  let imgStyle = {
    // I hate that I have to do this.
    maxWidth: '500px',
    maxHeight: '300px',
  };
  return (
    <Window theme={data.theme} width={750} height={750}>
      <Window.Content scrollable>
        <Section title={data.desc}>
          <img style={imgStyle} src={data.image} />
          <p>{data.greeting}</p>
          <hr />
        </Section>
        <MissionTracker />
        <Section
          title={data.next_restock}
          buttons={<Button content={data.points} />}
        >
          {Object.keys(data.items_info).map((key) => {
            let value = data.items_info[key];
            return (
              <Section
                title={value.name + ' (' + 'x' + value.stock + ')'}
                key={key}
                buttons={
                  <Button
                    content={'$' + value.price}
                    icon="cart-arrow-down"
                    onClick={() => act('purchase', { target: value.id })}
                  />
                }
              >
                {value.desc}
              </Section>
            );
          })}
        </Section>
      </Window.Content>
    </Window>
  );
};

const MissionTracker = (props) => {
  const { act, data } = useBackend<Data>();
  if (data.holding_cargo && data.holding_cargo.length) {
    return (
      <Section title="Mission Tracking">
        {Object.keys(data.holding_cargo).map((key) => {
          let value = data.holding_cargo[key];
          return (
            <Section
              title={value.name}
              key={key}
              buttons={
                <Button
                  content={'Receive Mission Cargo'}
                  icon="arrow-circle-down"
                  onClick={() => act('receive_cargo', { objective: value.id })}
                />
              }
            >
              {value.brief}
            </Section>
          );
        })}
      </Section>
    );
  } else {
    return;
  }
};
