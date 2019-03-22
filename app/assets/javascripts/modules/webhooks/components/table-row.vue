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
      <popover title="Please confirm" v-model="confirm">
        <button class="btn btn-default" role="button">
          <i class="fa fa-trash"></i>
        </button>
        <template slot="popover">
          <div class='popover-content'>
            <p>Are you sure you want to remove this webhook?</p>
            <a class='btn btn-default' @click="confirm = false">No</a>
            <a class='btn btn-primary yes' @click="destroy">Yes</a>
          </div>
        </template>
      </popover>
    </td>
  </tr>
</template>

<script>
  import Vue from 'vue';

  import { handleHttpResponseError } from '~/utils/http';

  import { Popover } from 'uiv';
  import WebhooksService from '../services/webhooks';

  const { set } = Vue;

  export default {
    data() {
      return {
        confirm: false,
      };
    },

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

    components: {
      Popover,
    },
  };
</script>
