import BaseComponent from '~/base/component';

import { openCloseIcon } from '~/utils/effects';

import EditNamespaceForm from './edit-namespace-form';

const TOGGLE_LINK = '.edit-namespace-link';
const TOGGLE_LINK_ICON = `${TOGGLE_LINK} i`;
const EDIT_NAMESPACE_FORM = '.edit-namespace-form';
const DESCRIPTION = '.description';

// NamespaceDetails component handles details panel
// and edit namespace form
class NamespaceDetails extends BaseComponent {
  elements() {
    this.$toggle = this.$el.find(TOGGLE_LINK);
    this.$toggleIcon = this.$el.find(TOGGLE_LINK_ICON);
    this.$form = this.$el.find(EDIT_NAMESPACE_FORM);
    this.$description = this.$el.find(DESCRIPTION);
  }

  events() {
    this.$toggle.on('click', () => this.onEditClick());
  }

  mount() {
    this.form = new EditNamespaceForm(this.$form);
  }

  onEditClick() {
    openCloseIcon(this.$toggleIcon);
    this.$description.toggle();
    this.form.toggle();

    layout_resizer();
  }
}

export default NamespaceDetails;
