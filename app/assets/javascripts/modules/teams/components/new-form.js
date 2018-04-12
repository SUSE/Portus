import Vue from 'vue';

import { required, requiredIf } from 'vuelidate/lib/validators';

import FormMixin from '~/shared/mixins/form';

import TeamsService from '../service';

const { set } = Vue;

export default {
  template: '#js-new-team-form-tmpl',

  mixins: [FormMixin],

  data() {
    return {
      team: {
        name: '',
        owner_id: null,
      },
      timeout: {
        name: null,
      },
    };
  },

  methods: {
    onSubmit() {
      TeamsService.save(this.team).then((response) => {
        const team = response.data;

        this.toggleForm();
        this.$v.$reset();
        set(this, 'team', {
          name: '',
        });

        this.$bus.$emit('teamCreated', team);
        this.$alert.$show(`Team '${team.name}' was created successfully`);
      }).catch((response) => {
        let errors = response.data.errors || response.data.error;

        if (Array.isArray(errors)) {
          errors = errors.join('<br />');
        }

        this.$alert.$show(errors);
      });
    },
  },

  validations: {
    team: {
      owner_id: {
        required: requiredIf(function () {
          return window.isAdmin;
        }),
      },

      name: {
        required,
        available(value) {
          clearTimeout(this.timeout.name);

          // required already taking care of this
          if (value === '') {
            return true;
          }

          return new Promise((resolve) => {
            const searchTeam = () => {
              const promise = TeamsService.exists(value, { unscoped: true });

              promise.then((exists) => {
                // leave it for the back-end
                if (exists === null) {
                  resolve(true);
                }

                // if it doesn't exist, valid
                resolve(!exists);
              });
            };

            this.timeout.name = setTimeout(searchTeam, 1000);
          });
        },
      },
    },
  },
};
