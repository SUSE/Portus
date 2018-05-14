import BaseComponent from '~/base/component';

import NewWebhookHeaderForm from './new-webhook-header-form';

const TOGGLE_LINK = '#add_webhook_header_btn';
const TOGGLE_LINK_ICON = `${TOGGLE_LINK} i`;
const NEW_WEBHOOK_HEADER_FORM = '#add_webhook_header_form';

// WebhookHeadersPanel component that lists webhook headers
// and contains new webhook header form.
class WebhookHeadersPanel extends BaseComponent {
  elements() {
    this.$toggle = this.$el.find(TOGGLE_LINK);
    this.$toggleIcon = this.$el.find(TOGGLE_LINK_ICON);
    this.$form = this.$el.find(NEW_WEBHOOK_HEADER_FORM);
  }

  events() {
    this.$el.on('click', TOGGLE_LINK, e => this.onToggleLinkClick(e));
  }

  mount() {
    this.newForm = new NewWebhookHeaderForm(this.$form);
  }

  onToggleLinkClick() {
    const wasVisible = this.$form.is(':visible');

    this.newForm.toggle();
    this.$toggleIcon.toggleClass('fa-minus-circle', !wasVisible);
    this.$toggleIcon.toggleClass('fa-plus-circle', wasVisible);
  }
}

export default WebhookHeadersPanel;
