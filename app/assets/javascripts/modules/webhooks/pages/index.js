import BaseComponent from '~/base/component';

import WebhooksPanel from '../components/webhooks-panel';

const WEBHOOKS_PANEL = '.webhooks-wrapper';

// WebhooksIndexPage component responsible to instantiate
// the namespace's webhooks index page components and
// handle interactions.
class WebhooksIndexPage extends BaseComponent {
  elements() {
    this.$webhooksPanel = this.$el.find(WEBHOOKS_PANEL);
  }

  mount() {
    this.webhooksPanel = new WebhooksPanel(this.$webhooksPanel);
  }
}

export default WebhooksIndexPage;
