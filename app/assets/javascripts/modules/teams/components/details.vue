<template>
  <panel>
    <h5 slot="heading-left">
      <a data-placement="right"
        data-toggle="popover"
        data-container=".panel-heading"
        data-content="<p>Information about the team.</p>"
        data-original-title="What's this?"
        tabindex="0" data-html="true">
        <i class="fa fa-info-circle"></i>
      </a>
      <strong class="team-name"> {{ team.name }} </strong>
      team
    </h5>

    <div slot="heading-right" v-if="team.updatable">
      <toggle-link text="Edit" :state="state" state-key="editFormVisible" class="toggle-link-edit-team" true-icon="fa-close" false-icon="fa-pencil"></toggle-link>
      <button class="btn btn-danger btn-sm toggle-delete-modal" @click="openDeleteModal" v-if="team.destroyable">
        <i class="fa fa-trash"></i> Delete
      </button>
    </div>

    <div slot="body">
      <team-info :team="team" v-if="!state.editFormVisible"></team-info>
      <team-edit-form :team="team" :visible="state.editFormVisible" v-else></team-edit-form>
      <delete-modal :team="team" :redirect-path="teamsPath" :has-namespaces="hasNamespaces" v-if="deleteModalVisible" @close="closeDeleteModal"></delete-modal>
    </div>

  </panel>
</template>

<script>
  import Vue from 'vue';

  import TeamEditForm from './edit-form';
  import TeamInfo from './info';
  import DeleteModal from './delete-modal';

  const { set } = Vue;

  export default {
    props: {
      team: Object,
      state: Object,
      teamsPath: String,
    },

    components: {
      TeamEditForm,
      TeamInfo,
      DeleteModal,
    },

    data() {
      return {
        deleteModalVisible: false,
        isDeleting: false,
        hasNamespaces: this.team.namespaces_count > 0,
      };
    },

    methods: {
      openDeleteModal() {
        set(this, 'deleteModalVisible', true);
      },

      closeDeleteModal() {
        set(this, 'deleteModalVisible', false);
      },

      updateHasNamespaces() {
        set(this, 'hasNamespaces', true);
      },
    },

    mounted() {
      this.$bus.$on('namespaceCreated', this.updateHasNamespaces);
    },
  };
</script>
