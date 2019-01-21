<template>
  <div class="namespaces-index-page">
    <new-namespace-form :state="state" form-state="newFormVisible"></new-namespace-form>

    <namespaces-panel :namespaces="specialNamespaces" :namespaces-path="namespacesPath" :webhooks-path="webhooksPath" prefix="sns_" :can-create="canCreateNamespace">
      <h5 slot="name">
        <a data-placement="right"
          data-toggle="popover"
          data-container=".panel-heading"
          data-content="<p>A namespace groups a series of repositories.</p>"
          data-original-title="What's this?"
          tabindex="0"
          data-html="true">
          <i class="fa fa-info-circle"></i>
        </a>
        Special namespaces
      </h5>
    </namespaces-panel>

    <namespaces-panel :namespaces="normalNamespaces" :namespaces-path="namespacesPath" :webhooks-path="webhooksPath" :table-sortable="true" class="member-namespaces-panel">
      <h5 slot="name">Namespaces you have access to through team membership</h5>
    </namespaces-panel>

    <namespaces-panel :namespaces="orphanNamespaces" :namespaces-path="namespacesPath" :webhooks-path="webhooksPath" prefix="ons_" :table-sortable="true" v-if="orphanNamespaces.length">
      <h5 slot="name">Orphan namespaces (no team assigned)</h5>
    </namespaces-panel>

    <namespaces-panel :namespaces="otherNamespaces" :namespaces-path="namespacesPath" :webhooks-path="webhooksPath" prefix="ons_" :table-sortable="true" v-if="otherNamespaces.length">
      <h5 slot="name">Other namespaces</h5>
    </namespaces-panel>
  </div>
</template>

<script>
  import Vue from 'vue';

  import NamespacesPanel from '../components/panel';
  import NewNamespaceForm from '../components/new-form';

  import NamespacesService from '../services/namespaces';

  import NamespacesStore from '../store';

  const { set } = Vue;

  export default {
    props: {
      namespacesPath: {
        type: String,
      },
      webhooksPath: {
        type: String,
      },
      userNamespaceId: {
        type: Number,
      },
      canCreateNamespace: {
        type: Boolean,
      },
      accessibleTeamsIds: {
        type: Array,
      },
    },

    components: {
      NewNamespaceForm,
      NamespacesPanel,
    },

    data() {
      return {
        state: NamespacesStore.state,
        namespaces: [],
      };
    },

    computed: {
      otherNamespaces() {
        // eslint-disable-next-line
        return this.namespaces.filter((n) => {
          return !n.global
              && n.id !== this.userNamespaceId
              && this.accessibleTeamsIds.indexOf(n.team.id) === -1
              && n.team.name.indexOf('global_team') === -1;
        });
      },

      normalNamespaces() {
        // eslint-disable-next-line
        return this.namespaces.filter((n) => {
          return !n.global
              && !n.orphan
              && n.id !== this.userNamespaceId
              && this.accessibleTeamsIds.indexOf(n.team.id) !== -1;
        });
      },

      orphanNamespaces() {
        // eslint-disable-next-line
        return this.namespaces.filter((n) => {
          return n.orphan;
        });
      },

      specialNamespaces() {
        return this.namespaces.filter(n => n.global || n.id === this.userNamespaceId);
      },
    },

    methods: {
      onCreate(namespace) {
        const currentNamespaces = this.namespaces;
        const namespaces = [
          ...currentNamespaces,
          namespace,
        ];

        set(this, 'namespaces', namespaces);
      },

      loadData() {
        NamespacesService.all({ all: true }).then((response) => {
          const namespaces = response.data;

          set(this, 'namespaces', namespaces);
          set(this.state, 'isLoading', false);
        });
      },
    },

    mounted() {
      set(this.state, 'isLoading', true);
      this.loadData();
      this.$bus.$on('namespaceCreated', namespace => this.onCreate(namespace));
    },
  };
</script>
