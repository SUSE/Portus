import BaseComponent from '~/base/component';

import NewWebhookForm from './new-webhook-form';

const TOGGLE_LINK = '#add_webhook_btn';
const TOGGLE_LINK_ICON = `${TOGGLE_LINK} i`;
const NEW_WEBHOOK_FORM = '#add_webhook_form';

// WebhooksPanel component that lists normal webhook
// and contains new webhook form.
class WebhooksPanel extends BaseComponent {
  elements() {
    this.$toggle = this.$el.find(TOGGLE_LINK);
    this.$toggleIcon = this.$el.find(TOGGLE_LINK_ICON);
    this.$form = this.$el.find(NEW_WEBHOOK_FORM);
  }

  events() {
    this.$el.on('click', TOGGLE_LINK, e => this.onToggleLinkClick(e));
  }

  mount() {
    this.newForm = new NewWebhookForm(this.$form);
  }

  onToggleLinkClick() {
    const wasVisible = this.$form.is(':visible');

    this.newForm.toggle();
    this.$toggleIcon.toggleClass('fa-minus-circle', !wasVisible);
    this.$toggleIcon.toggleClass('fa-plus-circle', wasVisible);
  }
}

export default WebhooksPanel;
