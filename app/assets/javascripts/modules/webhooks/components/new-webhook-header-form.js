import BaseComponent from '~/base/component';

const WEBHOOK_FORM_FIELDS = '.form-control';

// NewWebhookHeaderForm component refers to the new webhook header form
class NewWebhookHeaderForm extends BaseComponent {
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

export default NewWebhookHeaderForm;
