import BaseComponent from '~/base/component';

import NewTeamUserForm from './new-team-user-form';
import TeamUsersTable from './team-users-table';

const TOGGLE_LINK = '#add_team_user_btn';
const TOGGLE_LINK_ICON = `${TOGGLE_LINK} i`;
const NEW_TEAM_USER_FORM = '#add_team_user_form';
const TEAM_USERS_TABLE = '.table';

// TeamUsersPanel component that lists team users
// and contains new team member form.
class TeamUsersPanel extends BaseComponent {
  elements() {
    this.$toggle = this.$el.find(TOGGLE_LINK);
    this.$toggleIcon = this.$el.find(TOGGLE_LINK_ICON);
    this.$form = this.$el.find(NEW_TEAM_USER_FORM);
    this.$table = this.$el.find(TEAM_USERS_TABLE);
  }

  events() {
    this.$el.on('click', TOGGLE_LINK, e => this.onToggleLinkClick(e));
  }

  mount() {
    this.table = new TeamUsersTable(this.$table);
    this.newForm = new NewTeamUserForm(this.$form);
  }

  onToggleLinkClick() {
    const wasVisible = this.$form.is(':visible');

    this.newForm.toggle();
    this.$toggleIcon.toggleClass('fa-user-times', !wasVisible);
    this.$toggleIcon.toggleClass('fa-user-plus', wasVisible);
  }
}

export default TeamUsersPanel;
