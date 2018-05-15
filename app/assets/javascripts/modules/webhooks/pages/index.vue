<template>
  <div class="webhooks-index-page">
    <new-webhook-form :parent-namespace="parentNamespace" :state="state" form-state="newFormVisible"></new-webhook-form>

    <webhooks-panel :webhooks="webhooks" :webhooks-path="webhooksPath" :can-create-webhook="canCreateWebhook" :parent-namespace="parentNamespace" :namespace-path="namespacePath" :state="state"></webhooks-panel>
  </div>
</template>

<script>
  import Vue from 'vue';

  import WebhooksPanel from '../components/panel';
  import NewWebhookForm from '../components/new-form';

  import WebhooksStore from '../store';

  const { set } = Vue;

  export default {
    props: {
      namespacePath: {
        type: String,
      },
      webhooksPath: {
        type: String,
      },
      parentNamespace: {
        type: Object,
      },
      canCreateWebhook: {
        type: Boolean,
      },
      webhooksRef: {
        type: Array,
      },
    },

    components: {
      NewWebhookForm,
      WebhooksPanel,
    },

    data() {
      return {
        webhooks: [...this.webhooksRef],
        state: WebhooksStore.state,
      };
    },

    methods: {
      onCreate(webhook) {
        const currentWebhooks = this.webhooks;
        const webhooks = [
          ...currentWebhooks,
          webhook,
        ];

        set(this, 'webhooks', webhooks);
      },

      onDestroy(webhook) {
        const currentWebhooks = this.webhooks;
        const index = currentWebhooks.findIndex(c => c.id === webhook.id);

        const webhooks = [
          ...currentWebhooks.slice(0, index),
          ...currentWebhooks.slice(index + 1),
        ];

        set(this, 'webhooks', webhooks);
      },
    },

    created() {
      this.$bus.$on('webhookDestroyed', webhook => this.onDestroy(webhook));
      this.$bus.$on('webhookCreated', webhook => this.onCreate(webhook));
    },
  };
</script>
