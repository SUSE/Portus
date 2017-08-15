import BaseComponent from '~/base/component';

import NamespaceDetails from '../legacy-components/namespace-details';

const NAMESPACE_DETAILS = '.namespace-details';

// NamespaceShowPage component responsible to instantiate
// the user's edit page components and handle interactions.
class NamespaceShowPage extends BaseComponent {
  elements() {
    this.$details = this.$el.find(NAMESPACE_DETAILS);
  }

  mount() {
    this.details = new NamespaceDetails(this.$details);
  }
}

export default NamespaceShowPage;
