import BaseComponent from '~/base/component';

const WEBHOOK_FORM_FIELDS = 'input.form-control, textarea';

// EditWebhookForm component refers to the webhook form
class EditWebhookForm extends BaseComponent {
  elements() {
    this.$fields = this.$el.find(WEBHOOK_FORM_FIELDS);
  }

  toggle() {
    this.$el.toggle();

    const visible = this.$el.is(':visible');

    if (visible) {
      this.$fields.first().focus();
    }
  }
}

export default EditWebhookForm;
