import { useEffect } from 'react';

import { useBackend } from '../../backend';
import { ByondUi } from '../../components';

export const CharacterPreview = (props: { height: string; id: string }) => {
  const { act } = useBackend();

  // AQUILA: każda nowa kontrolka mapy prosi serwer o ponowne podpięcie postaci,
  // inaczej BYOND pokazuje domyślny widok z malutką postacią
  useEffect(() => {
    act('refresh_character_preview');
  }, []);

  return (
    <ByondUi
      width="220px"
      height={props.height}
      params={{
        id: props.id,
        type: 'map',
      }}
    />
  );
};
