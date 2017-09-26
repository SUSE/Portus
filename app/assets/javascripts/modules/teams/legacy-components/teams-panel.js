import BaseComponent from '~/base/component';

import NewTeamForm from './new-team-form';

const TOGGLE_LINK = '#add_team_btn';
const TOGGLE_LINK_ICON = `${TOGGLE_LINK} i`;
const NEW_TEAM_FORM = '#add_team_form';

// TeamsPanel component that lists teams
// and contains new team form.
class TeamsPanel extends BaseComponent {
  elements() {
    this.$toggle = this.$el.find(TOGGLE_LINK);
    this.$toggleIcon = this.$el.find(TOGGLE_LINK_ICON);
    this.$form = this.$el.find(NEW_TEAM_FORM);
  }

  events() {
    this.$el.on('click', TOGGLE_LINK, e => this.onToggleLinkClick(e));
  }

  mount() {
    this.newForm = new NewTeamForm(this.$form);
  }

  onToggleLinkClick() {
    const wasVisible = this.$form.is(':visible');

    this.newForm.toggle();
    this.$toggleIcon.toggleClass('fa-minus-circle', !wasVisible);
    this.$toggleIcon.toggleClass('fa-plus-circle', wasVisible);
  }
}

export default TeamsPanel;
