import { required } from 'vuelidate/lib/validators';

import { handleHttpResponseError } from '~/utils/http';

import NamespacesService from '../services/namespaces';

import NamespacesFormMixin from '../mixins/form';

import VisibilityChooser from './visibility-chooser';

export default {
  template: '#js-edit-namespace-form-tmpl',

  props: ['namespace'],

  mixins: [NamespacesFormMixin],

  components: {
    VisibilityChooser,
  },

  data() {
    return {
      mixinAttr: 'namespaceParams',
      selectedTeam: this.namespace.team,
      namespaceParams: {
        team: this.namespace.team.name,
        description: this.namespace.description,
        visibility: this.namespace.visibility,
      },
      timeout: {
        team: null,
      },
    };
  },

  methods: {
    onSubmit() {
      const params = { namespace: this.namespaceParams };

      NamespacesService.update(this.namespace.id, params).then((response) => {
        const namespace = response.data;

        this.$bus.$emit('namespaceUpdated', namespace);
        this.$alert.$show(`Namespace '${namespace.name}' was updated successfully`);
      }).catch(handleHttpResponseError);
    },
  },

  validations: {
    namespaceParams: {
      team: {
        required,
      },
    },
  },
};
