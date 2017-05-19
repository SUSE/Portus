import BaseComponent from '~/base/component';
import TabbedWidget from '../components/tabbed_widget';

const TAB_WIDGET = '#sidebar-tabs';

class DashboardPage extends BaseComponent {
  elements() {
    this.$widget = this.$el.find(TAB_WIDGET);
  }

  mount() {
    this.tabbedWidget = new TabbedWidget(this.$widget);
  }
}

export default DashboardPage;
