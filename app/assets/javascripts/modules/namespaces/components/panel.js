import LoadingIcon from '~/shared/components/loading-icon';
import ToggleLink from '~/shared/components/toggle-link';
import PanelWithFormMixin from '~/shared/mixins/panel-with-form';

import NamespacesTable from './table';

export default {
  template: '#js-namespaces-panel-tmpl',

  mixins: [PanelWithFormMixin],

  props: ['namespaces', 'tableSortable'],

  components: {
    LoadingIcon,
    NamespacesTable,
    ToggleLink,
  },
};
