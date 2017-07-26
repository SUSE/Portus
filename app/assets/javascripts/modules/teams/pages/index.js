import BaseComponent from '~/base/component';

import TeamsPanel from '../components/teams-panel';

const TEAMS_PANEL = '.teams-wrapper';

// TeamsIndexPage component responsible to instantiate
// the teams index page components and handle interactions.
class TeamsIndexPage extends BaseComponent {
  elements() {
    this.$teamsPanel = this.$el.find(TEAMS_PANEL);
  }

  mount() {
    this.teamsPanel = new TeamsPanel(this.$teamsPanel);
  }
}

export default TeamsIndexPage;
