import BaseComponent from '~/base/component';

const WEBHOOK_FORM_FIELDS = 'input.form-control, textarea';

// NewWebhookForm component refers to the new webhook form
class NewWebhookForm extends BaseComponent {
  elements() {
    this.$fields = this.$el.find(WEBHOOK_FORM_FIELDS);
  }

  toggle() {
    this.$el.toggle(400, 'swing', () => {
      const visible = this.$el.is(':visible');

      if (visible) {
        this.$fields.first().focus();
      }

      this.$fields.val('');
      layout_resizer();
    });
  }
}

export default NewWebhookForm;
