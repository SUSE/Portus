<template>
  <div class="namespaces-index-page">
    <namespaces-panel :namespaces="specialNamespaces" :namespaces-path="namespacesPath" :webhooks-path="webhooksPath" prefix="sns_">
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

    <new-namespace-form :state="state" form-state="newFormVisible"></new-namespace-form>

    <namespaces-panel :namespaces="normalNamespaces" :namespaces-path="namespacesPath" :webhooks-path="webhooksPath" :table-sortable="true">
      <h5 slot="name">Namespaces you have access to</h5>
      <div slot="actions" v-if="canCreateNamespace">
        <toggle-link text="Create new namespace" :state="state" state-key="newFormVisible" class="toggle-link-new-namespace"></toggle-link>
      </div>
    </namespaces-panel>
  </div>
</template>

<script>
  import Vue from 'vue';

  import ToggleLink from '~/shared/components/toggle-link';

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
    },

    components: {
      NewNamespaceForm,
      NamespacesPanel,
      ToggleLink,
    },

    data() {
      return {
        state: NamespacesStore.state,
        normalNamespaces: [],
        specialNamespaces: [],
      };
    },

    methods: {
      onCreate(namespace) {
        const currentNamespaces = this.normalNamespaces;
        const namespaces = [
          ...currentNamespaces,
          namespace,
        ];

        set(this, 'normalNamespaces', namespaces);
      },

      loadData() {
        NamespacesService.all().then((response) => {
          const namespaces = response.data;

          const normal = namespaces.filter(n => !n.global && n.id !== this.userNamespaceId);
          const special = namespaces.filter(n => n.global || n.id === this.userNamespaceId);

          set(this, 'normalNamespaces', normal);
          set(this, 'specialNamespaces', special);
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
