import BaseComponent from '~/base/component';

import NormalNamespacesPanel from '../components/normal-namespaces-panel';

const NORMAL_NAMESPACES_PANEL = '.normal-namespaces-wrapper';

// NamespacesIndexPage component responsible to instantiate
// the namespaces's index page components and handle interactions.
class NamespacesIndexPage extends BaseComponent {
  elements() {
    this.$normalNamespacesPanel = this.$el.find(NORMAL_NAMESPACES_PANEL);
  }

  mount() {
    this.normalNamespacesPanel = new NormalNamespacesPanel(this.$normalNamespacesPanel);
  }
}

export default NamespacesIndexPage;
