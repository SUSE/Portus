import Vue from 'vue';

import { required } from 'vuelidate/lib/validators';

import { setTypeahead } from '~/utils/typeahead';
import { handleHttpResponseError } from '~/utils/http';

import FormMixin from '~/shared/mixins/form';
import TeamsService from '../../service';

const TYPEAHEAD_INPUT = '#new-team-member-form .remote .typeahead';

const { set } = Vue;

export default {
  template: '#js-team-member-form-tmpl',

  props: ['teamId'],

  mixins: [FormMixin],

  data() {
    return {
      member: {
        role: window.availableRoles[0].toLowerCase(),
        user: '',
      },
      timeout: {
        user: null,
      },
      errors: {
        name: [],
      },
    };
  },

  methods: {
    onSubmit() {
      TeamsService.saveMember(this.teamId, this.member).then((response) => {
        const member = response.data;

        this.toggleForm();
        this.$v.$reset();
        set(this, 'member', {
          role: window.availableRoles[0].toLowerCase(),
          user: '',
        });

        if (member.admin) {
          this.$alert.$show(`User '${member.display_name}' was added to the team (promoted to owner because it's a Portus admin)`);
        } else {
          this.$alert.$show(`User '${member.display_name}' was successfully added to the team`);
        }
        this.$bus.$emit('teamMemberAdded', member);
      }).catch(handleHttpResponseError);
    },
  },

  validations: {
    member: {
      user: {
        required,
        available(value) {
          clearTimeout(this.timeout.user);

          // required already taking care of this
          if (value === '') {
            return true;
          }

          return new Promise((resolve) => {
            const searchTeam = () => {
              const promise = TeamsService.memberExists(this.teamId, value);

              promise.then((exists) => {
                // leave it for the back-end
                if (exists === null) {
                  resolve(true);
                }

                // if exists, valid
                resolve(exists);
              });
            };

            this.timeout.user = setTimeout(searchTeam, 1000);
          });
        },
      },
    },
  },

  mounted() {
    const $user = setTypeahead(TYPEAHEAD_INPUT, `/teams/${this.teamId}/typeahead/%QUERY`);

    // workaround because of typeahead
    const updateTeam = () => {
      set(this.member, 'user', $user.val());
    };

    $user.on('typeahead:selected', updateTeam);
    $user.on('typeahead:autocompleted', updateTeam);
    $user.on('change', updateTeam);
  },
};
