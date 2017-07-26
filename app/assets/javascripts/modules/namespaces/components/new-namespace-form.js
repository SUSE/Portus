import BaseComponent from '~/base/component';

import { setTypeahead } from '~/utils/typeahead';

const TYPEAHEAD_INPUT = '.remote .typeahead';
const NAMESPACE_FORM_FIELDS = '.form-control, textarea';

// NewNamespaceForm component refers to the new namespace form
class NewNamespaceForm extends BaseComponent {
  elements() {
    this.$fields = this.$el.find(NAMESPACE_FORM_FIELDS);
  }

  // eslint-disable-next-line class-methods-use-this
  mounted() {
    setTypeahead(TYPEAHEAD_INPUT, '/namespaces/typeahead/%QUERY');
  }

  toggle() {
    this.$el.toggle(400, 'swing', () => {
      const visible = this.$el.is(':visible');

      if (visible) {
        this.$fields.first().focus();
      }

      this.$fields.val('');
      layout_resizer();
    });
  }
}

export default NewNamespaceForm;
