// NSV13: buttons used as stars on the starmap.
// The Inferno version only re-implemented Button to work around IE8 click events,
// which no longer matters on BYOND 516 (WebView2), so it is the tgui-core Button now.

import { Button } from 'tgui-core/components';

export const StarButton = Button;
