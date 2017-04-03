import BaseComponent from '~/base/component';

class TabbedWidget extends BaseComponent {
  elements() {
    this.$links = this.$el.find('a');
  }

  events() {
    this.$links.on('click', (e) => {
      e.preventDefault();
      $(this).tab('show');
    });
  }
}

export default TabbedWidget;
