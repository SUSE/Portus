import BaseComponent from '~/base/component';

import NormalNamespacesPanel from '../../namespaces/components/normal-namespaces-panel';
import TeamDetails from '../components/team-details';
import TeamUsersPanel from '../components/team-users-panel';

const NORMAL_NAMESPACES_PANEL = '.normal-namespaces-wrapper';
const TEAM_USERS_PANEL = '.team-users-wrapper';
const TEAM_DETAILS = '.team-details';

// TeamsShowPage component responsible to instantiate
// the team's show page components and handle interactions.
class TeamsShowPage extends BaseComponent {
  elements() {
    this.$teamDetails = this.$el.find(TEAM_DETAILS);
    this.$teamUsersPanel = this.$el.find(TEAM_USERS_PANEL);
    this.$normalNamespacesPanel = this.$el.find(NORMAL_NAMESPACES_PANEL);
  }

  mount() {
    this.normalNamespacesPanel = new NormalNamespacesPanel(this.$normalNamespacesPanel);
    this.teamDetails = new TeamDetails(this.$teamDetails);
    this.teamUsersPanel = new TeamUsersPanel(this.$teamUsersPanel);
  }
}

export default TeamsShowPage;
