import BaseComponent from '~/base/component';

const TEAM_FORM_FIELDS = 'input.form-control, textarea';

// NewTeamForm component refers to the new team form
class NewTeamForm extends BaseComponent {
  elements() {
    this.$fields = this.$el.find(TEAM_FORM_FIELDS);
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

export default NewTeamForm;
