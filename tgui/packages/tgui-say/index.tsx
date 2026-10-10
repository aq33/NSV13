import './styles/main.scss';
import { createRenderer } from 'tgui/renderer';
import { TguiSay } from './interfaces/TguiSay';

// Uncomment to enable hot-reloading
// import { setupHotReloading } from 'tgui-dev-server/link/client.cjs';

const renderApp = createRenderer(() => {
  return <TguiSay />;
});

const setupApp = () => {
  // Delay setup. On 516 (WebView2) DOMContentLoaded does not reach this
  // inlined bundle, so wait for readyState 'complete' like Bee does.
  if (document.readyState !== 'complete') {
    document.onreadystatechange = () => {
      if (document.readyState === 'complete') {
        setupApp();
      }
    };
    return;
  }

  // Uncomment to enable hot-reloading
  // if (module.hot) {
  //  setupHotReloading();
  // }

  renderApp();
};

setupApp();
