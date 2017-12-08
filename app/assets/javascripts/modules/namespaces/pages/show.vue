<template>
  <div class="namespaces-show-page">
    <panel>
      <div slot="heading-left">
        <h5>
          <a data-placement="right"
            data-toggle="popover"
            data-container=".panel-heading"
            data-content="<p>Information about the namespace.</p>"
            data-original-title="What's this?"
            tabindex="0"
            data-html="true">
            <i class="fa fa-info-circle"></i>
          </a>
          <strong> {{ namespace.name }} </strong>
          namespace
        </h5>
      </div>

      <div slot="heading-right">
        <toggle-link text="Edit namespace" :state="state" state-key="editFormVisible" class="toggle-link-edit-namespace" false-icon="fa-pencil" true-icon="fa-close" v-if="canManageNamespace"></toggle-link>
      </div>

      <div slot="body">
        <namespace-info :namespace="namespace" v-if="!state.editFormVisible"></namespace-info>
        <edit-namespace-form :namespace="namespace" v-if="state.editFormVisible"></edit-namespace-form>
      </div>
    </panel>
  </div>
</template>

<script>
  import Vue from 'vue';

  import ToggleLink from '~/shared/components/toggle-link';
  import Panel from '~/shared/components/panel';

  import NamespaceInfo from '../components/info';
  import EditNamespaceForm from '../components/edit-form';

  import NamespacesStore from '../store';

  const { set } = Vue;

  export default {
    props: {
      namespaceJson: {
        type: String,
      },
      canManageNamespace: {
        type: Boolean,
      },
    },

    components: {
      NamespaceInfo,
      EditNamespaceForm,
      ToggleLink,
      Panel,
    },

    data() {
      return {
        state: NamespacesStore.state,
        namespace: JSON.parse(this.namespaceJson),
      };
    },

    methods: {
      onUpdate(namespace) {
        set(this.state, 'editFormVisible', false);
        set(this, 'namespace', namespace);
      },
    },

    mounted() {
      this.$bus.$on('namespaceUpdated', namespace => this.onUpdate(namespace));
    },
  };
</script>
