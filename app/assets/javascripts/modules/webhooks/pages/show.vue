<template>
  <div class="webhooks-show-page">
    <webhook-details-panel :webhook="webhook" :state="state"></webhook-details-panel>
    <new-webhook-header-form :webhook="webhook" :state="state" form-state="newHeaderFormVisible"></new-webhook-header-form>
    <webhook-headers-panel :webhook="webhook" :headers="headers" :state="state"></webhook-headers-panel>
  </div>
</template>

<script>
  import Vue from 'vue';

  import NewWebhookHeaderForm from '../components/headers/form';
  import WebhookDetailsPanel from '../components/details';
  import WebhookHeadersPanel from '../components/headers/panel';

  import WebhooksStore from '../store';

  const { set } = Vue;

  export default {
    props: {
      webhookRef: {
        type: Object,
      },
      headersRef: {
        type: Array,
      },
    },

    components: {
      NewWebhookHeaderForm,
      WebhookDetailsPanel,
      WebhookHeadersPanel,
    },

    data() {
      return {
        webhook: { ...this.webhookRef },
        headers: [...this.headersRef],
        state: WebhooksStore.state,
      };
    },

    methods: {
      onUpdate(webhook) {
        set(this, 'webhook', webhook);
        WebhooksStore.set('editFormVisible', false);
      },

      onHeaderCreate(header) {
        const currentHeaders = this.headers;
        const headers = [
          ...currentHeaders,
          header,
        ];

        set(this, 'headers', headers);
      },

      onHeaderDestroy(header) {
        const currentHeaders = this.headers;
        const index = currentHeaders.findIndex(h => h.id === header.id);

        const headers = [
          ...currentHeaders.slice(0, index),
          ...currentHeaders.slice(index + 1),
        ];

        set(this, 'headers', headers);
      },
    },

    created() {
      this.$bus.$on('webhookUpdated', webhook => this.onUpdate(webhook));
      this.$bus.$on('webhookHeaderCreated', header => this.onHeaderCreate(header));
      this.$bus.$on('webhookHeaderDestroyed', header => this.onHeaderDestroy(header));
    },
  };
</script>
