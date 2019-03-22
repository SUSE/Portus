<template>
  <div class="namespaces-show-page">
    <namespace-details-panel :namespace="namespace" :state="state" :teams-path="teamsPath" :webhooks-path="webhooksPath" :namespaces-path="namespacesPath"></namespace-details-panel>
    <repositories-panel title="Namespace's repositories" :repositories="repositories" :show-namespaces="false" :repositories-path="repositoriesPath">
      <div slot="heading-right">
        <popover title="What can I do?" trigger="hover-focus" v-if="namespace.permissions.push">
          <div tabindex="0" class="circle-label permissions-label circle-label-sm">
            <i class="fa fa-arrow-up"></i>
            Push
          </div>
          <template slot="popover">
            You can push images
          </template>
        </popover>

        <popover title="What can I do?" trigger="hover-focus" v-if="namespace.permissions.pull">
          <div tabindex="0" class="circle-label permissions-label circle-label-sm">
            <i class="fa fa-arrow-down"></i>
            Pull
          </div>
          <template slot="popover">
            You can pull images
          </template>
        </popover>

        <popover title="What's my role?" trigger="hover-focus" v-if="namespace.permissions.role == 'owner'">
          <div tabindex="0" class="circle-label permissions-label circle-label-sm">
            <i class="fa fa-male"></i>
            Owner
          </div>
          <template slot="popover">
            You are an owner of this namespace
          </template>
        </popover>

        <popover title="What's my role?" trigger="hover-focus" v-if="namespace.permissions.role == 'contributor'">
          <div tabindex="0" class="circle-label permissions-label circle-label-sm">
            <i class="fa fa-exchange"></i>
            Contr.
          </div>
          <template slot="popover">
            You are a contributor in this namespace
          </template>
        </popover>

        <popover title="What's my role?" trigger="hover-focus" v-if="namespace.permissions.role == 'viewer'">
          <div tabindex="0" class="circle-label permissions-label circle-label-sm">
            <i class="fa fa-eye"></i>
            Viewer
          </div>
          <template slot="popover">
            You are a viewer in this namespace
          </template>
        </popover>
      </div>
    </repositories-panel>
  </div>
</template>

<script>
  import Vue from 'vue';

  import RepositoriesPanel from '~/modules/repositories/components/panel';
  import WebhooksPanel from '~/modules/webhooks/components/panel';

  import { Popover } from 'uiv';
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
      Popover,
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
