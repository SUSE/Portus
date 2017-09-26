import BaseComponent from '~/base/component';

import EditTeamForm from './edit-team-form';

const TOGGLE_LINK = '.edit-team-link';
const EDIT_TEAM_FORM = '.edit-team-form';
const TEAM_INFORMATION = '.team_information';

// TeamDetails component handles details panel
// and edit team form
class TeamDetails extends BaseComponent {
  elements() {
    this.$toggle = this.$el.find(TOGGLE_LINK);
    this.$form = this.$el.find(EDIT_TEAM_FORM);
    this.$teamInformation = this.$el.find(TEAM_INFORMATION);
  }

  events() {
    this.$toggle.on('click', () => this.onEditClick());
  }

  mount() {
    this.form = new EditTeamForm(this.$form);
  }

  onEditClick() {
    this.$teamInformation.toggle();
    this.form.toggle();

    layout_resizer();
  }
}

export default TeamDetails;
