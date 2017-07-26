import BaseComponent from '~/base/component';

import NormalNamespacesPanel from '../../namespaces/components/normal-namespaces-panel';

const NORMAL_NAMESPACES_PANEL = '.normal-namespaces-wrapper';

// TeamsShowPage component responsible to instantiate
// the team's show page components and handle interactions.
class TeamsShowPage extends BaseComponent {
  elements() {
    this.$normalNamespacesPanel = this.$el.find(NORMAL_NAMESPACES_PANEL);
  }

  mount() {
    this.normalNamespacesPanel = new NormalNamespacesPanel(this.$normalNamespacesPanel);
  }
}

export default TeamsShowPage;
