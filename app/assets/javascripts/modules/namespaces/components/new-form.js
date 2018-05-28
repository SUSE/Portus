import Vue from 'vue';

import { required } from 'vuelidate/lib/validators';

import { handleHttpResponseError } from '~/utils/http';

import FormMixin from '~/shared/mixins/form';

import NamespacesService from '../services/namespaces';
import NamespacesFormMixin from '../mixins/form';

const { set } = Vue;

export default {
  template: '#js-new-namespace-form-tmpl',

  props: ['teamName'],

  mixins: [FormMixin, NamespacesFormMixin],

  data() {
    return {
      namespace: {
        name: '',
        team: this.teamName || '',
      },
      timeout: {
        validate: null,
        team: null,
      },
      errors: {
        name: [],
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

        this.$bus.$emit('namespaceCreated', namespace);
        this.$alert.$show(`Namespace '${namespace.name}' was created successfully`);
      }).catch(handleHttpResponseError);
    },
  },

  validations: {
    namespace: {
      name: {
        required,
        validate(value) {
          clearTimeout(this.timeout.validate);

          // required already taking care of this
          if (value === '') {
            set(this.errors, 'name', []);
            return true;
          }

          return new Promise((resolve) => {
            const validate = () => {
              const promise = NamespacesService.validate(value);

              promise.then((data) => {
                set(this.errors, 'name', data.messages.name);
                resolve(data.valid);
              });
            };

            this.timeout.validate = setTimeout(validate, 1000);
          });
        },
      },
      team: {
        required,
      },
    },
  },
};
