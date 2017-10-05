import BaseComponent from '~/base/component';

import { setTypeahead } from '~/utils/typeahead';

const TYPEAHEAD_INPUT = '.remote .typeahead';
const WEBHOOK_FORM_FIELDS = '.form-control';

// NewTeamUserForm component refers to the new team member form
class NewTeamUserForm extends BaseComponent {
  elements() {
    this.$fields = this.$el.find(WEBHOOK_FORM_FIELDS);
  }

  mounted() {
    const teamId = this.$el.find(TYPEAHEAD_INPUT).data('teamId');

    setTypeahead(TYPEAHEAD_INPUT, teamId + '/typeahead/%QUERY');
  }

  toggle() {
    this.$el.toggle(400, 'swing', () => {
      const visible = this.$el.is(':visible');

      if (visible) {
        this.$fields.last().focus();
      }

      this.$fields.last().val('');
      this.$fields.first().val('viewer');
      layout_resizer();
    });
  }
}

export default NewTeamUserForm;
