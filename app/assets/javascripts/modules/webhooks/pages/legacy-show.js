import BaseComponent from '~/base/component';

import WebhookDetails from '../components/legacy/webhook-details';
import WebhookHeadersPanel from '../components/legacy/webhook-headers-panel';

const WEBHOOK_DETAILS = '.webhook-details';
const WEBHOOK_HEADERS_PANEL = '.webhook-headers-panel';

// WebhookShowPage component responsible to instantiate
// the webhooks's show page components and handle interactions.
class WebhookShowPage extends BaseComponent {
  elements() {
    this.$details = this.$el.find(WEBHOOK_DETAILS);
    this.$headers = this.$el.find(WEBHOOK_HEADERS_PANEL);
  }

  mount() {
    this.details = new WebhookDetails(this.$details);
    this.headers = new WebhookHeadersPanel(this.$headers);
  }
}

export default WebhookShowPage;
