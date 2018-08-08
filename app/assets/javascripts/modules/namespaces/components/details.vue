<template>
  <panel>
    <h5 slot="heading-left">
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

    <div slot="heading-right">
      <toggle-link text="Edit namespace" :state="state" state-key="editFormVisible" class="toggle-link-edit-namespace" false-icon="fa-pencil" true-icon="fa-close" v-if="namespace.updatable"></toggle-link>
    </div>

    <div slot="body">
      <namespace-info :namespace="namespace" v-if="!state.editFormVisible" :teams-path="teamsPath" :webhooks-path="webhooksPath"></namespace-info>
      <edit-namespace-form :namespace="namespace" v-if="state.editFormVisible"></edit-namespace-form>
    </div>
  </panel>
</template>

<script>
  import NamespaceInfo from './info';
  import EditNamespaceForm from './edit-form';

  export default {
    props: {
      namespace: {
        type: Object,
      },
      state: {
        type: Object,
      },
      teamsPath: {
        type: String,
      },
      webhooksPath: {
        type: String,
      },
    },

    components: {
      NamespaceInfo,
      EditNamespaceForm,
    },
  };
</script>
