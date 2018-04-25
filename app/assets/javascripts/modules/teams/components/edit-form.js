import Vue from 'vue';

import { required } from 'vuelidate/lib/validators';

import { handleHttpResponseError } from '~/utils/http';

import TeamsService from '../service';

const { set } = Vue;

export default {
  template: '#js-team-edit-form-tmpl',

  props: ['team', 'visible'],

  data() {
    return {
      teamCopy: {},
      timeout: {
        name: null,
      },
    };
  },

  methods: {
    onSubmit() {
      TeamsService.update(this.teamCopy).then((response) => {
        const team = response.data;


        this.$bus.$emit('teamUpdated', team);
        this.$alert.$show(`Team '${team.name}' was updated successfully`);
      }).catch(handleHttpResponseError);
    },

    copyOriginal() {
      set(this, 'teamCopy', { ...this.team });
    },
  },

  watch: {
    visible: {
      handler: 'copyOriginal',
      immediate: true,
    },
  },

  validations: {
    teamCopy: {
      name: {
        required,
        available(value) {
          clearTimeout(this.timeout.name);

          // required already taking care of this
          if (value === '' || value === this.team.name) {
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
