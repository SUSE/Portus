import BaseComponent from '~/base/component';

import { openCloseIcon } from '~/utils/effects';

const TEAM_USER_EDIT_BTN = '.edit-team-user-btn';

// TeamUsersTable component refers to the
// team users table
class TeamUsersTable extends BaseComponent {
  events() {
    this.$el.on('click', TEAM_USER_EDIT_BTN, e => this.onToggleEdit(e));
  }

  // eslint-disable-next-line class-methods-use-this
  onToggleEdit(e) {
    const $btn = $(e.currentTarget);
    const teamUserId = $btn.data('teamUserId');

    openCloseIcon($btn.find('.fa'));
    $(`#team_user_${teamUserId} td .role`).toggle();
    $(`#change_role_team_user_${teamUserId}`).toggle();
  }
}

export default TeamUsersTable;
