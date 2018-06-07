import Vue from 'vue';
import VueMultiselect from 'vue-multiselect';

import { required } from 'vuelidate/lib/validators';

import { handleHttpResponseError } from '~/utils/http';

import FormMixin from '~/shared/mixins/form';
import TeamsService from '../../service';

import TeamsStore from '../../store';

const { set } = Vue;

export default {
  template: '#js-team-member-form-tmpl',

  props: ['teamId'],

  mixins: [FormMixin],

  components: {
    VueMultiselect,
  },

  data() {
    const initialRole = TeamsStore.state.availableRoles[0].toLowerCase();

    return {
      members: [],
      selectedMember: null,
      isTouched: false,
      isLoading: false,
      initialRole,
      member: {
        role: initialRole,
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
          role: this.initialRole,
          user: '',
        });
        set(this, 'selectedMember', '');
        set(this, 'members', []);

        if (member.admin) {
          this.$alert.$show(`User '${member.display_name}' was added to the team (promoted to owner because it's a Portus admin)`);
        } else {
          this.$alert.$show(`User '${member.display_name}' was successfully added to the team`);
        }
        this.$bus.$emit('teamMemberAdded', member);
      }).catch(handleHttpResponseError);
    },

    searchMember(query) {
      if (!query) {
        return;
      }

      set(this, 'isLoading', true);
      TeamsService.searchMember(this.teamId, query).then((response) => {
        set(this, 'members', response.data);
      }).catch(() => {
        void 0;
      }).finally(() => set(this, 'isLoading', false));
    },

    onSelect(member) {
      set(this.member, 'user', member.name);
    },

    onRemove() {
      set(this.member, 'user', '');
    },

    onTouch() {
      this.$v.member.user.$touch();
    },
  },

  validations: {
    member: {
      user: {
        required,
      },
    },
  },
};
