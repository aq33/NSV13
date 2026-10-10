import { Button, Icon, Image, Section } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  pictures: any;
  title: any;
};

export const PictureSelectModal = (_) => {
  const { data, act } = useBackend<Data>();
  const { title, pictures = [] } = data;
  return (
    <Window title={title} width={400} height={500}>
      <Window.Content scrollable>
        {pictures.map((picture) => (
          <Section
            title={
              <>
                <Icon name="camera" /> {picture.name}
              </>
            }
            key={picture.ref}
            buttons={
              <Button
                content="Select"
                color="green"
                onClick={() => act('submit', { entry: picture.ref })}
              />
            }
            style={{ overflow: 'auto' }}
          >
            <Image
              mt={1}
              src={picture.path}
              style={{ float: 'left', margin: '0.5em', marginTop: '0' }}
            />
            <span style={{ display: 'inline-block' }}>{picture.desc}</span>
          </Section>
        ))}
      </Window.Content>
    </Window>
  );
};
