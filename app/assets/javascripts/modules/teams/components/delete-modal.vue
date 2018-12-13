<style>
  .delete-modal .modal-dialog {
    width: 400px;
  }

  .submit-btn {
    width: 100%;
  }
</style>

<template>
  <modal class="delete-modal" v-on="$listeners" @enter="onEnter" ref="modal">
    <template slot="title">
      <h4>Delete team</h4>
    </template>

    <template slot="body">
      <p>You are about to delete the <strong>{{ team.name }}</strong> team. <span v-if="hasNamespaces">If you want to migrate its namespace, select the new team below. Otherwise, just ignore the field.</span></p>

      <form role="form" class="delete-team-form" v-if="hasNamespaces" novalidate>
        <div class="form-group has-feedback" :class="{ 'has-error': $v.params.team.$error }">
          <vue-multiselect
            class="team_select"
            :class="{'multiselect--selected': selectedTeam != null}"
            v-model="selectedTeam"
            label="name"
            track-by="name"
            placeholder="Type to search"
            :loading="isLoading"
            :options="teams"
            :max-height="400"
            @close="onTouch"
            @select="onSelect"
            @remove="onRemove"
            @search-change="searchTeam"
            ref="input">
            <span slot="noResult">Oops! No team found.</span>
          </vue-multiselect>
          <span class="help-block">
            <span v-if="!$v.params.team.notSameAsTeam">You cannot select the original team</span>
          </span>
        </div>
      </form>
    </template>

    <template slot="footer">
      <button type="button" class="btn btn-danger submit-btn" @click="onSubmit" :disabled="$v.$invalid || isDeleting">{{ buttonName }}</button>
    </template>
  </modal>
</template>

<script>
  import Vue from 'vue';

  import { sameAs, not } from 'vuelidate/lib/validators';

  import { handleHttpResponseError } from '~/utils/http';

  import TeamsService from '../service';

  import NamespacesFormMixin from '~/modules/namespaces/mixins/form';

  const { set } = Vue;

  export default {
    props: {
      team: Object,
      redirectPath: String,
      hasNamespaces: Boolean,
    },

    // TODO: extract this mixin to something like "TeamsMultiselectFormMixin"
    mixins: [NamespacesFormMixin],

    data() {
      return {
        mixinAttr: 'params',
        params: {
          team: null,
        },
        close: false,
        isDeleting: false,
      };
    },

    validations: {
      params: {
        team: {
          notSameAsTeam: not(sameAs(function () { return this.team.name; })),
        },
      },
    },

    computed: {
      buttonName() {
        if (!this.hasNamespaces) {
          return 'I understand, delete team';
        }

        if (this.selectedTeam) {
          return 'Migrate namespaces and delete team';
        }

        return 'Delete team and its namespaces';
      },
    },

    methods: {
      onEnter() {
        this.$refs.modal.$el.focus();
      },

      onSubmit() {
        const params = {};

        if (this.selectedTeam) {
          params.new_team = this.selectedTeam.name;
        }

        set(this, 'isDeleting', true);

        TeamsService.remove(this.team.id, params).then(() => {
          let msg = `Team '${this.team.name}' was removed successfully`;

          if (params.new_team) {
            msg += ` and its namespaces were migrated to '${params.new_team}'`;
          }

          this.$alert.$schedule(msg);
          this.$refs.modal.close();
          window.location.href = this.redirectPath;
        }).catch(handleHttpResponseError);
      },
    },
  };
</script>
