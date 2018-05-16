<template>
  <tr :class="scopeClass">
    <td><a :href="webhookPath">{{ webhook.name }}</a></td>
    <td>{{ webhook.url }}</td>
    <td>{{ webhook.request_method }}</td>
    <td>{{ webhook.content_type }}</td>
    <td>
      <button class="btn btn-default" v-if="webhook.updatable" @click.prevent="toggleEnabled">
        <i class="fa fa-toggle-on toggle" title="Click to disable" v-if="webhook.enabled"></i>
        <i class="fa fa-toggle-off toggle" title="Click to enable" v-else></i>
      </button>
      <span v-else>
        <i class="fa fa-toggle-on" v-if="webhook.enabled"></i>
        <i class="fa fa-toggle-off" v-else></i>
      </span>
    </td>
    <td v-if="webhook.destroyable">
      <button class="btn btn-default delete-webhook-btn"
        data-placement="left"
        data-toggle="popover"
        data-title="Please confirm"
        data-content="<p>Are you sure you want to remove this\
        webhook?</p><a class='btn btn-default'>No</a> <a class='btn \
        btn-primary yes'>Yes</a>"
        data-template="<div class='popover popover-webhook-delete' role='tooltip'><div class='arrow'></div><h3 class='popover-title'></h3><div class='popover-content'></div></div>'"
        data-html="true"
        role="button">
        <i class="fa fa-trash"></i>
      </button>
    </td>
  </tr>
</template>

<script>
  import Vue from 'vue';

  import { handleHttpResponseError } from '~/utils/http';

  import WebhooksService from '../services/webhooks';

  const { set } = Vue;

  export default {
    props: ['webhook', 'webhooksPath'],

    computed: {
      scopeClass() {
        return `webhook_${this.webhook.id}`;
      },

      webhookPath() {
        return `${this.webhooksPath}/${this.webhook.id}`;
      },
    },

    methods: {
      toggleEnabled() {
        WebhooksService.toggleEnabled(this.webhook.namespace_id, this.webhook.id).then(() => {
          const stateMsg = this.webhook.enabled ? 'disabled' : 'enabled';
          set(this.webhook, 'enabled', !this.webhook.enabled);

          this.$alert.$show(`Webhook '${this.webhook.name}' is now ${stateMsg}`);
        }).catch(handleHttpResponseError);
      },

      destroy() {
        WebhooksService.destroy(this.webhook.namespace_id, this.webhook.id).then(() => {
          this.$bus.$emit('webhookDestroyed', this.webhook);
          this.$alert.$show(`Webhook '${this.webhook.name}' was removed successfully`);
        }).catch(handleHttpResponseError);
      },
    },

    mounted() {
      const REMOVE_BTN = '.delete-webhook-btn';
      const POPOVER_DELETE = '.popover-webhook-delete';

      // TODO: refactor bootstrap popover to a component
      $(this.$el).on('inserted.bs.popover', REMOVE_BTN, () => {
        const $yes = $(POPOVER_DELETE).find('.yes');
        $yes.click(this.destroy.bind(this));
      });
    },
  };
</script>
