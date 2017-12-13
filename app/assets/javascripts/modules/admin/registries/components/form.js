import Vue from 'vue';

import { required } from 'vuelidate/lib/validators';

import RegistriesService from '../service';

const { set } = Vue;

const timeouts = {};

export default {
  template: '#js-registry-form-tmpl',

  props: {
    canChangeHostname: {
      type: Boolean,
    },
  },

  data() {
    return {
      original: window.registry,
      registry: {
        name: window.registry.name || '',
        hostname: window.registry.hostname || '',
        external_hostname: window.registry.external_hostname || '',
        use_ssl: window.registry.use_ssl || false,
        force: false,
      },
      errors: {
        name: [],
        hostname: [],
      },
      display: {
        force: window.showForce || false,
      },
    };
  },

  validations: {
    registry: {
      name: {
        required,
        remote(value) {
          return this.validate('name', value);
        },
      },
      hostname: {
        required,
        remote(value) {
          // workaround to force validation when use_ssl changes
          void this.registry.use_ssl;

          set(this.display, 'force', false);

          const promise = this.validate('hostname', value);

          if (promise.then) {
            promise.then(() => {
              const hasHostnameErrors = (this.errors.hostname || []).length > 0;
              set(this.display, 'force', hasHostnameErrors);
            });
          }

          return promise;
        },
      },
    },
  },

  methods: {
    isReachableError(error) {
      return error.indexOf('Error: ') !== -1 ||
             error.indexOf('SSLError') !== -1 ||
             error.indexOf('OpenTimeout') !== -1 ||
             error.indexOf('SSLError') !== -1;
    },

    hasReachableError() {
      const errors = this.errors.hostname || [];

      return errors.some(e => this.isReachableError(e));
    },

    validate(field, value) {
      clearTimeout(timeouts[field]);

      // required already taking care of this
      if (value === '' || value === this.original[field]) {
        set(this.errors, field, []);
        return true;
      }

      return new Promise((resolve) => {
        const validateRequest = () => {
          const promise = RegistriesService.validate(this.registry, field);

          promise.then(({ valid, messages }) => {
            set(this.errors, field, messages[field]);

            resolve(valid);
          });
        };

        set(this.errors, field, []);
        timeouts[field] = setTimeout(validateRequest, 1000);
      });
    },
  },

  computed: {
    submitDisabled() {
      const nameInvalid = this.$v.registry.name.$invalid;
      const hostnameRequiredInvalid = !this.$v.registry.hostname.required;
      const hostnameReachableInvalid = this.hasReachableError() && !this.registry.force;

      return nameInvalid ||
             hostnameRequiredInvalid ||
             hostnameReachableInvalid ||
             this.$v.$pending;
    },
  },
};
