import Vue from 'vue';

import { required } from 'vuelidate/lib/validators';

import { setTypeahead } from '~/utils/typeahead';

import EventBus from '~/utils/eventbus';
import Alert from '~/shared/components/alert';
import FormMixin from '~/shared/mixins/form';

import NamespacesService from '../services/namespaces';

const TYPEAHEAD_INPUT = '.remote .typeahead';

const { set } = Vue;

export default {
  template: '#js-new-namespace-form-tmpl',

  props: ['teamName'],

  mixins: [FormMixin],

  data() {
    return {
      namespace: {
        name: '',
        team: this.teamName || '',
      },
      timeout: {
        name: null,
        team: null,
      },
    };
  },

  methods: {
    onSubmit() {
      NamespacesService.save(this.namespace).then((response) => {
        const namespace = response.data;

        this.toggleForm();
        this.$v.$reset();
        set(this, 'namespace', {
          name: '',
          team: this.teamName || '',
        });

        Alert.show(`Namespace '${namespace.name}' was created successfully`);
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

  validations: {
    namespace: {
      name: {
        required,
        format(value) {
          // extracted from models/namespace.rb
          const regexp = /^[a-z0-9]+(?:[._-][a-z0-9]+)*$/;

          // required already taking care of this
          if (value === '') {
            return true;
          }

          return regexp.test(value);
        },
        available(value) {
          clearTimeout(this.timeout.name);

          // required already taking care of this
          if (value === '') {
            return true;
          }

          return new Promise((resolve) => {
            const searchName = () => {
              const promise = NamespacesService.existsByName(value);

              promise.then((exists) => {
                // leave it for the back-end
                if (exists === null) {
                  resolve(true);
                }

                // if exists, invalid
                resolve(!exists);
              });
            };

            this.timeout.name = setTimeout(searchName, 1000);
          });
        },
      },
      team: {
        required,
        available(value) {
          clearTimeout(this.timeout.team);

          // required already taking care of this
          if (value === '') {
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

  mounted() {
    const $team = setTypeahead(TYPEAHEAD_INPUT, '/namespaces/typeahead/%QUERY');

    // workaround because of typeahead
    const updateTeam = () => {
      set(this.namespace, 'team', $team.val());
    };

    $team.on('typeahead:selected', updateTeam);
    $team.on('typeahead:autocompleted', updateTeam);
    $team.on('change', updateTeam);
  },
};
