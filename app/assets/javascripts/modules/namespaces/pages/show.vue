<template>
  <div class="namespaces-show-page">
    <namespace-details-panel :namespace="namespace" :state="state" :teams-path="teamsPath" :webhooks-path="webhooksPath" :namespaces-path="namespacesPath"></namespace-details-panel>
    <repositories-panel title="Namespace's repositories" :repositories="repositories" :show-namespaces="false" :repositories-path="repositoriesPath">
      <div slot="heading-right">
        <div v-if="namespace.permissions.push"
          class="circle-label permissions-label circle-label-sm"
          data-placement="left"
          data-toggle="popover"
          data-container=".panel-heading"
          data-content="You can push images"
          data-original-title="What can I do?"
          tabindex="0" data-html="true">
          <i class="fa fa-arrow-up"></i>
          Push
        </div>
        <div v-if="namespace.permissions.pull"
          class="circle-label permissions-label circle-label-sm"
          data-placement="left"
          data-toggle="popover"
          data-container=".panel-heading"
          data-content="You can pull images"
          data-original-title="What can I do?"
          tabindex="0" data-html="true">
          <i class="fa fa-arrow-down"></i>
          Pull
        </div>
        <div v-if="namespace.permissions.role == 'owner'"
          class="circle-label permissions-label circle-label-sm"
          data-placement="left"
          data-toggle="popover"
          data-container=".panel-heading"
          data-content="You are an owner of this namespace"
          data-original-title="What's my role?"
          tabindex="0" data-html="true">
          <i class="fa fa-male"></i>
          Owner
        </div>
        <div v-if="namespace.permissions.role == 'contributor'"
          class="circle-label permissions-label circle-label-sm"
          data-placement="left"
          data-toggle="popover"
          data-container=".panel-heading"
          data-content="You are a contributor in this namespace"
          data-original-title="What's my role?"
          tabindex="0" data-html="true">
          <i class="fa fa-exchange"></i>
          Contr.
        </div>
        <div v-if="namespace.permissions.role == 'viewer'"
          class="circle-label permissions-label circle-label-sm"
          data-placement="left"
          data-toggle="popover"
          data-container=".panel-heading"
          data-content="You are a viewer in this namespace"
          data-original-title="What's my role?"
          tabindex="0" data-html="true">
          <i class="fa fa-eye"></i>
          Viewer
        </div>
      </div>
    </repositories-panel>
  </div>
</template>

<script>
  import Vue from 'vue';

  import RepositoriesPanel from '~/modules/repositories/components/panel';
  import WebhooksPanel from '~/modules/webhooks/components/panel';

  import NamespaceDetailsPanel from '../components/details';

  import NamespacesStore from '../store';

  const { set } = Vue;

  export default {
    props: {
      namespaceRef: {
        type: Object,
      },
      repositoriesRef: {
        type: Array,
      },
      namespacesPath: {
        type: String,
      },
      repositoriesPath: {
        type: String,
      },
      teamsPath: {
        type: String,
      },
      webhooksPath: {
        type: String,
      },
      userNamespaceId: {
        type: Number,
      },
    },

    components: {
      NamespaceDetailsPanel,
      RepositoriesPanel,
      WebhooksPanel,
    },

    data() {
      return {
        state: NamespacesStore.state,
        namespace: { ...this.namespaceRef },
        repositories: [...this.repositoriesRef],
      };
    },

    computed: {
      isSpecial() {
        return this.namespace.global || this.namespace.id === this.userNamespaceId;
      },
    },

    methods: {
      onUpdate(namespace) {
        set(this.state, 'editFormVisible', false);
        set(this, 'namespace', namespace);
      },
    },

    mounted() {
      set(this.state, 'isSpecialNamespace', this.isSpecial);
      this.$bus.$on('namespaceUpdated', namespace => this.onUpdate(namespace));
    },
  };
</script>
