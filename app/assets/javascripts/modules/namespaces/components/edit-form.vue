<template>
  <form role="form" class="edit-namespace-form" @submit.prevent="onSubmit" novalidate>
    <div class="form-group has-feedback" :class="{ 'has-error': $v.namespaceParams.team.$error }" v-if="!hideTeam">
      <label class="control-label" for="namespace_team">Team</label>
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
        @search-change="searchTeam">
        <span slot="noResult">Oops! No team found. Consider changing the search query.</span>
      </vue-multiselect>
      <!-- once we fix the condition to show error messages we merge this with the block below -->
      <span class="help-block show" v-if="hasTeamChanged">
        <span class="text-danger">By changing the team you will transfer this namespace. Are you sure?</span>
      </span>
      <span class="help-block">
        <span v-if="!$v.namespaceParams.team.required">Team can't be blank</span>
      </span>
    </div>

    <div class="form-group">
      <label class="control-label" for="namespace_visibility">Visibility</label>
      <div>
        <visibility-chooser :is-global="namespace.global" :visibility.sync="namespaceParams.visibility" :can-change="namespace.permissions.visibility"></visibility-chooser>
      </div>
    </div>

    <div class="form-group">
      <label class="control-label" for="namespace_description">Description</label>
      <textarea id="namespace_description" name="namespace[description]" class="form-control fixed-size" placeholder="A short description of your namespace" v-model="namespaceParams.description"></textarea>
    </div>

    <div class="form-group">
      <button type="submit" class="btn btn-primary" :disabled="$v.$invalid">Save</button>
    </div>
  </form>
</template>

<script>
  import { required } from 'vuelidate/lib/validators';

  import { handleHttpResponseError } from '~/utils/http';

  import NamespacesService from '../services/namespaces';

  import NamespacesFormMixin from '../mixins/form';

  import VisibilityChooser from './visibility-chooser';

  export default {
    props: {
      namespace: Object,
      hideTeam: Boolean,
    },

    mixins: [NamespacesFormMixin],

    components: {
      VisibilityChooser,
    },

    data() {
      return {
        mixinAttr: 'namespaceParams',
        selectedTeam: this.namespace.team,
        namespaceParams: {
          team: this.namespace.team.name,
          description: this.namespace.description,
          visibility: this.namespace.visibility,
        },
        timeout: {
          team: null,
        },
      };
    },

    computed: {
      hasTeamChanged() {
        return this.namespaceParams.team
            && this.namespace.team.name !== this.namespaceParams.team;
      },
    },

    methods: {
      onSubmit() {
        const params = { namespace: this.namespaceParams };

        NamespacesService.update(this.namespace.id, params).then((response) => {
          const namespace = response.data;

          this.$bus.$emit('namespaceUpdated', namespace);
          this.$alert.$show(`Namespace '${namespace.name}' was updated successfully`);
        }).catch(handleHttpResponseError);
      },
    },

    validations: {
      namespaceParams: {
        team: {
          required,
        },
      },
    },
  };
</script>
