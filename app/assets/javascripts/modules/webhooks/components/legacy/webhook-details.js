import BaseComponent from '~/base/component';

import EditWebhookForm from './edit-webhook-form';

const TOGGLE_LINK = '.edit-webhook-link';
const EDIT_WEBHOOK_FORM = '.edit-webhook-form';
const WEBHOOK_INFORMATION = '.webhook_information';

// WebhooksDetails component handles details panel
// and edit webhook form
class WebhooksDetails extends BaseComponent {
  elements() {
    this.$toggle = this.$el.find(TOGGLE_LINK);
    this.$form = this.$el.find(EDIT_WEBHOOK_FORM);
    this.$webhookInformation = this.$el.find(WEBHOOK_INFORMATION);
  }

  events() {
    this.$toggle.on('click', () => this.onEditClick());
  }

  mount() {
    this.form = new EditWebhookForm(this.$form);
  }

  onEditClick() {
    this.$webhookInformation.toggle();
    this.form.toggle();

    layout_resizer();
  }
}

export default WebhooksDetails;
