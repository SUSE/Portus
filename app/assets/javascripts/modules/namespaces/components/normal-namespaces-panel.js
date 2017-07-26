import BaseComponent from '~/base/component';

import NewNamespaceForm from './new-namespace-form';

const TOGGLE_LINK = '#add_namespace_btn';
const TOGGLE_LINK_ICON = `${TOGGLE_LINK} i`;
const NEW_NAMESPACE_FORM = '#add_namespace_form';

// NormalNamespacesPanel component that lists normal namespaces
// and contains new namespace form.
class NormalNamespacesPanel extends BaseComponent {
  elements() {
    this.$toggle = this.$el.find(TOGGLE_LINK);
    this.$toggleIcon = this.$el.find(TOGGLE_LINK_ICON);
    this.$form = this.$el.find(NEW_NAMESPACE_FORM);
  }

  events() {
    this.$el.on('click', TOGGLE_LINK, e => this.onToggleLinkClick(e));
  }

  mount() {
    this.newForm = new NewNamespaceForm(this.$form);
  }

  // eslint-disable-next-line class-methods-use-this
  onToggleLinkClick() {
    const wasVisible = this.$form.is(':visible');

    this.newForm.toggle();
    this.$toggleIcon.toggleClass('fa-minus-circle', !wasVisible);
    this.$toggleIcon.toggleClass('fa-plus-circle', wasVisible);
  }
}

export default NormalNamespacesPanel;
