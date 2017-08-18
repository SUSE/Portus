import LoadingIcon from '~/shared/components/loading-icon';
import ToggleLink from '~/shared/components/toggle-link';

import NamespacesTable from './table';

import NamespacesStore from '../store';

export default {
  template: '#js-namespaces-panel-tmpl',

  props: ['namespaces', 'tableSortable', 'prefix'],

  data() {
    return {
      state: NamespacesStore.state,
    };
  },

  components: {
    LoadingIcon,
    NamespacesTable,
    ToggleLink,
  },
};
