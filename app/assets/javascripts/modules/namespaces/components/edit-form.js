import Vue from 'vue';

import { required } from 'vuelidate/lib/validators';

import { setTypeahead } from '~/utils/typeahead';

import EventBus from '~/utils/eventbus';
import Alert from '~/shared/components/alert';

import NamespacesService from '../services/namespaces';

const TYPEAHEAD_INPUT = '.remote .typeahead';

const { set } = Vue;

export default {
  template: '#js-edit-namespace-form-tmpl',

  props: ['namespace'],

  data() {
    return {
      model: {
        namespace: {
          team: this.namespace.team_name,
          description: this.namespace.description,
        },
      },
      timeout: {
        team: null,
      },
    };
  },

  methods: {
    onSubmit() {
      NamespacesService.update(this.namespace.id, this.model).then((response) => {
        const namespace = response.data;

        Alert.show(`Namespace '${namespace.name}' was updated successfully`);
        EventBus.$emit('namespaceUpdated', namespace);
      }).catch((response) => {
        let errors = response.data;

        if (Array.isArray(errors)) {
          errors = errors.join('<br />');
        }

        Alert.show(errors);
      });
    },
  },

  validations: {
    model: {
      namespace: {
        team: {
          required,
          available(value) {
            clearTimeout(this.timeout.team);

            // required already taking care of this
            if (value === '' || value === this.namespace.team_name) {
              return true;
            }

            return new Promise((resolve) => {
              const searchTeam = () => {
                const promise = NamespacesService.teamExists(value);

                promise.then((exists) => {
                  // leave it for the back-end
                  if (exists === null) {
                    resolve(true);
                  }

                  // if exists, valid
                  resolve(exists);
                });
              };

              this.timeout.team = setTimeout(searchTeam, 1000);
            });
          },
        },
      },
    },
  },

  mounted() {
    const $team = setTypeahead(TYPEAHEAD_INPUT, '/namespaces/typeahead/%QUERY');

    // workaround because of typeahead
    const updateTeam = () => {
      set(this.model.namespace, 'team', $team.val());
    };

    $team.on('typeahead:selected', updateTeam);
    $team.on('typeahead:autocompleted', updateTeam);
    $team.on('change', updateTeam);
  },
};
