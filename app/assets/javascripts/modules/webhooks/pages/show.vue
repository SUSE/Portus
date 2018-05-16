<template>
  <div class="webhooks-show-page">
    <webhook-details-panel :webhook="webhook" :state="state"></webhook-details-panel>
    <new-webhook-header-form :webhook="webhook" :state="state" form-state="newHeaderFormVisible"></new-webhook-header-form>
    <webhook-headers-panel :webhook="webhook" :headers="headers" :state="state"></webhook-headers-panel>
    <webhook-deliveries-panel :webhook="webhook" :deliveries="deliveries"></webhook-deliveries-panel>
  </div>
</template>

<script>
  import Vue from 'vue';

  import NewWebhookHeaderForm from '../components/headers/form';
  import WebhookDeliveriesPanel from '../components/deliveries/panel';
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
      deliveriesRef: {
        type: Array,
      },
    },

    components: {
      NewWebhookHeaderForm,
      WebhookDeliveriesPanel,
      WebhookDetailsPanel,
      WebhookHeadersPanel,
    },

    data() {
      return {
        webhook: { ...this.webhookRef },
        headers: [...this.headersRef],
        deliveries: [...this.deliveriesRef],
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

      onDeliveryRetrigger(delivery) {
        const currentDeliveries = this.deliveries;
        const index = currentDeliveries.findIndex(d => d.id === delivery.id);

        const deliveries = [
          ...currentDeliveries.slice(0, index),
          delivery,
          ...currentDeliveries.slice(index + 1),
        ];

        set(this, 'deliveries', deliveries);
      },
    },

    created() {
      this.$bus.$on('webhookUpdated', webhook => this.onUpdate(webhook));
      this.$bus.$on('webhookHeaderCreated', header => this.onHeaderCreate(header));
      this.$bus.$on('webhookHeaderDestroyed', header => this.onHeaderDestroy(header));
      this.$bus.$on('webhookDeliveryRetriggered', delivery => this.onDeliveryRetrigger(delivery));
    },
  };
</script>
