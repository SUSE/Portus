<template>
  <div class="webhooks-index-page">
    <webhook-details-panel :webhook="webhook" :state="state"></webhook-details-panel>
  </div>
</template>

<script>
  import Vue from 'vue';

  import WebhookDetailsPanel from '../components/details';

  import WebhooksStore from '../store';

  const { set } = Vue;

  export default {
    props: {
      webhookRef: {
        type: Object,
      },
    },

    components: {
      WebhookDetailsPanel,
    },

    data() {
      return {
        webhook: { ...this.webhookRef },
        state: WebhooksStore.state,
      };
    },

    methods: {
      onUpdate(webhook) {
        set(this, 'webhook', webhook);
        WebhooksStore.set('editFormVisible', false);
      },
    },

    created() {
      this.$bus.$on('webhookUpdated', webhook => this.onUpdate(webhook));
    },
  };
</script>
