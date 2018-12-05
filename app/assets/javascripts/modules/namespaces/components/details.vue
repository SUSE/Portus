<template>
  <panel>
    <h5 slot="heading-left">
      <a data-placement="right"
        data-toggle="popover"
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
      <toggle-link text="Edit" :state="state" state-key="editFormVisible" class="toggle-link-edit-namespace" false-icon="fa-pencil" true-icon="fa-close" v-if="namespace.updatable"></toggle-link>
      <button class="btn btn-default btn-sm toggle-transfer-modal" @click="openTransferModal" v-if="!state.isSpecialNamespace && !state.editFormVisible">
        <i class="fa fa-exchange"></i> Transfer
      </button>
      <delete-namespace-btn :namespace="namespace" :redirect-path="namespacesPath" v-if="namespace.destroyable"></delete-namespace-btn>
    </div>

    <div slot="body">
      <namespace-info :namespace="namespace" v-if="!state.editFormVisible" :teams-path="teamsPath" :webhooks-path="webhooksPath"></namespace-info>
      <edit-namespace-form :namespace="namespace" :hide-team="state.isSpecialNamespace" v-if="state.editFormVisible"></edit-namespace-form>
      <transfer-modal :namespace="namespace" v-if="transferModalVisible" @close="closeTransferModal"></transfer-modal>
    </div>
  </panel>
</template>

<script>
  import Vue from 'vue';

  import NamespaceInfo from './info';
  import EditNamespaceForm from './edit-form';
  import DeleteNamespaceBtn from './delete-btn';
  import TransferModal from './transfer-modal';

  const { set } = Vue;

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
      namespacesPath: {
        type: String,
      },
    },

    components: {
      NamespaceInfo,
      EditNamespaceForm,
      DeleteNamespaceBtn,
      TransferModal,
    },

    data() {
      return {
        transferModalVisible: false,
      };
    },

    methods: {
      openTransferModal() {
        set(this, 'transferModalVisible', true);
      },

      closeTransferModal() {
        set(this, 'transferModalVisible', false);
      },
    },
  };
</script>
