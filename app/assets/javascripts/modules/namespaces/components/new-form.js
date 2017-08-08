import Vue from 'vue';

import EventBus from '~/utils/eventbus';

import { setTypeahead } from '~/utils/typeahead';

import Alert from '~/shared/components/alert';
import FormMixin from '~/shared/mixins/form';

import NamespacesService from '../services/namespaces';

const TYPEAHEAD_INPUT = '.remote .typeahead';

const { set } = Vue;

export default {
  template: '#js-new-namespace-form-tmpl',

  mixins: [FormMixin],

  data() {
    return {
      namespace: {
        namespace: {},
      },
    };
  },

  methods: {
    onSubmit() {
      NamespacesService.save(this.namespace).then((response) => {
        const namespace = response.data.data;
        const name = namespace.attributes.clean_name;

        this.toggleForm();
        set(this.namespace, 'namespace', {});

        Alert.show(`Namespace '${name}' was created successfully`);
        EventBus.$emit('namespaceCreated', namespace);
      }).catch((response) => {
        let errors = response.data;

        if (Array.isArray(errors)) {
          errors = errors.join('<br />');
        }

        Alert.show(errors);
      });
    },
  },

  mounted() {
    const $team = setTypeahead(TYPEAHEAD_INPUT, '/namespaces/typeahead/%QUERY');

    // workaround because of typeahead
    $team.on('change', () => {
      set(this.namespace.namespace, 'team', $team.val());
    });
  },
};
