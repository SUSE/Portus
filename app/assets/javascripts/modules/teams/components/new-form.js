import Vue from 'vue';

import { required } from 'vuelidate/lib/validators';

import Alert from '~/shared/components/alert';
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

        Alert.show(`Team '${team.name}' was created successfully`);
        this.$bus.$emit('teamCreated', team);
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
    team: {
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
              const promise = TeamsService.exists(value);

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
