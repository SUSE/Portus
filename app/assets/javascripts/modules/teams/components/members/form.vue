<template>
  <form id="new-team-member-form" ref="form" class="form-horizontal collapse" role="form" @submit.prevent="onSubmit" novalidate>
    <div class="form-group">
      <label class="control-label col-md-2" for="team_user_role">Role</label>
      <div class="col-md-7">
        <select name="team_user[role]" id="team_user_role" class="form-control" v-model="member.role">
          <option v-for="r in roles" :key="r" :value="r.toLowerCase()">{{ r }}</option>
        </select>
      </div>
    </div>
    <div class="form-group has-feedback" :class="{ 'has-error': $v.member.user.$error }">
      <label class="control-label col-md-2" for="team_user_user">User</label>
      <div class="col-md-7">
        <vue-multiselect
          id="team_user_user"
          class="team_user_user"
          :class="{'multiselect--selected': selectedMember != null}"
          v-model="selectedMember"
          label="name"
          track-by="name"
          placeholder="Type to search"
          :loading="isLoading"
          :options="members"
          :max-height="400"
          @close="onTouch"
          @select="onSelect"
          @remove="onRemove"
          @search-change="searchMember">
          <span slot="noResult">Oops! No username found. Consider changing the search query.</span>
        </vue-multiselect>
        <span class="help-block">
          <span v-if="!$v.member.user.required">User can't be blank</span>
        </span>
      </div>
    </div>

    <div class="form-group">
      <div class="col-md-offset-2 col-md-7">
        <button type="submit" class="btn btn-primary" :disabled="$v.$invalid">Add</button>
      </div>
    </div>
  </form>
</template>

<script>
  import Vue from 'vue';
  import VueMultiselect from 'vue-multiselect';

  import { required } from 'vuelidate/lib/validators';

  import { handleHttpResponseError } from '~/utils/http';

  import FormMixin from '~/shared/mixins/form';
  import TeamsService from '../../service';

  import TeamsStore from '../../store';

  const { set } = Vue;

  export default {
    props: ['teamId'],

    mixins: [FormMixin],

    components: {
      VueMultiselect,
    },

    data() {
      const roles = TeamsStore.state.availableRoles;
      const initialRole = roles[0].toLowerCase();

      return {
        members: [],
        selectedMember: null,
        isTouched: false,
        isLoading: false,
        roles,
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
</script>
