import BaseComponent from '~/base/component';

const TEAM_FORM_FIELDS = 'input.form-control, textarea';

// EditTeamForm component refers to the team form
class EditTeamForm extends BaseComponent {
  elements() {
    this.$fields = this.$el.find(TEAM_FORM_FIELDS);
  }

  toggle() {
    this.$el.toggle();

    const visible = this.$el.is(':visible');

    if (visible) {
      this.$fields.first().focus();
    }
  }
}

export default EditTeamForm;
