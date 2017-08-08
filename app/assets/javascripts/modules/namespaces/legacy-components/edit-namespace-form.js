import BaseComponent from '~/base/component';

import { setTypeahead } from '~/utils/typeahead';

const TYPEAHEAD_INPUT = '.remote .typeahead';

// EditNamespaceForm component refers to the namespace form
class EditNamespaceForm extends BaseComponent {
  // eslint-disable-next-line class-methods-use-this
  mounted() {
    setTypeahead(TYPEAHEAD_INPUT, '/namespaces/typeahead/%QUERY');
  }

  toggle() {
    this.$el.toggle();
  }
}

export default EditNamespaceForm;
