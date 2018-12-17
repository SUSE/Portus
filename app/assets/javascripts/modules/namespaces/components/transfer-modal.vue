<style>
  .transfer-modal .modal-dialog {
    width: 400px;
  }

  .submit-btn {
    width: 100%;
  }
</style>

<template>
  <modal class="transfer-modal" v-on="$listeners" @enter="onEnter" ref="modal">
    <template slot="title">
      <h4>Transfer namespace</h4>
    </template>

    <template slot="body">
      <p v-if="namespace.orphan">You are about to transfer the <strong>{{ namespace.name }}</strong> namespace. Please select the new team below:</p>
      <p v-else>You are about to transfer the <strong>{{ namespace.name }}</strong> namespace from the <strong>{{ namespace.team.name }}</strong> team. Please select the new team below:</p>

      <form role="form" class="edit-namespace-form" novalidate>
        <div class="form-group has-feedback" :class="{ 'has-error': $v.namespaceParams.team.$error }">
          <vue-multiselect
            class="namespace_team"
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
            <span v-if="!$v.namespaceParams.team.required">Team can't be blank</span>
            <span v-if="!$v.namespaceParams.team.notSameAsTeam">You cannot select the original team</span>
          </span>
        </div>
      </form>
    </template>

    <template slot="footer">
      <button type="button" class="btn btn-primary submit-btn" @click="onSubmit" :disabled="$v.$invalid">I understand, transfer this namespace</button>
    </template>
  </modal>
</template>

<script>
  import { required, sameAs, not } from 'vuelidate/lib/validators';

  import { handleHttpResponseError } from '~/utils/http';

  import NamespacesService from '../services/namespaces';

  import NamespacesFormMixin from '../mixins/form';

  export default {
    props: {
      namespace: Object,
    },

    mixins: [NamespacesFormMixin],

    data() {
      return {
        mixinAttr: 'namespaceParams',
        namespaceParams: {
          team: null,
        },
        close: false,
      };
    },

    validations: {
      namespaceParams: {
        team: {
          required,
          notSameAsTeam: not(sameAs(function () { return this.namespace.team.name; })),
        },
      },
    },

    methods: {
      onEnter() {
        this.$refs.modal.$el.focus();
      },

      onSubmit() {
        const params = { namespace: this.namespaceParams };

        NamespacesService.update(this.namespace.id, params).then((response) => {
          const namespace = response.data;

          this.$bus.$emit('namespaceUpdated', namespace);
          this.$alert.$show(`Namespace '${namespace.name}' has been transferred successfully`);
          this.$refs.modal.close();
        }).catch(handleHttpResponseError);
      },
    },
  };
</script>
