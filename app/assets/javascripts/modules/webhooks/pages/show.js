import BaseComponent from '~/base/component';

import WebhookDetails from '../components/webhook-details';

const WEBHOOK_DETAILS = '.webhook-details';

// WebhookShowPage component responsible to instantiate
// the user's edit page components and handle interactions.
class WebhookShowPage extends BaseComponent {
  elements() {
    this.$details = this.$el.find(WEBHOOK_DETAILS);
  }

  mount() {
    this.details = new WebhookDetails(this.$details);
  }
}

export default WebhookShowPage;
