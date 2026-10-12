import { multiline } from 'common/string';

import { CheckboxInput, FeatureToggle } from '../base';

export const inverted_rotation: FeatureToggle = {
  name: 'Odwrócone obracanie obiektów',
  category: 'GAMEPLAY',
  description: multiline`
    Domyślnie Alt+lewy przycisk obraca obiekt przeciwnie do ruchu wskazówek zegara, a Alt+prawy zgodnie z nim. Ta opcja zamienia przyciski.
  `,
  component: CheckboxInput,
  important: true,
};
