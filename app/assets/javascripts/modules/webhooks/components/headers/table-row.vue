<template>
  <tr :class="scopeClass">
    <td>{{ header.name }}</td>
    <td>{{ header.value }}</td>
    <td v-if="webhook.updatable">
      <popover title="Please confirm" placement="left" v-model="confirm">
        <button class="btn btn-default" role="button">
          <i class="fa fa-trash"></i>
        </button>
        <template slot="popover">
          <div class='popover-content'>
            <p>Are you sure you want to remove this webhook header?</p>
            <a class='btn btn-default' @click="confirm = false">No</a>
            <a class='btn btn-primary yes' @click="destroy">Yes</a>
          </div>
        </template>
      </popover>
    </td>
  </tr>
</template>

<script>
  import { handleHttpResponseError } from '~/utils/http';

  import WebhookHeadersService from '../../services/headers';
  import { Popover } from 'uiv';

  export default {
    data() {
      return {
        confirm: false,
      };
    },

    props: ['header', 'webhook'],

    computed: {
      scopeClass() {
        return `webhook_header_${this.header.id}`;
      },
    },

    methods: {
      destroy() {
        const namespaceId = this.webhook.namespace_id;
        const webhookId = this.webhook.id;

        WebhookHeadersService.destroy(namespaceId, webhookId, this.header.id).then(() => {
          this.$bus.$emit('webhookHeaderDestroyed', this.header);
          this.$alert.$show(`Header '${this.header.name}' was removed successfully`);
        }).catch(handleHttpResponseError);
      },
    },

    components: {
      Popover,
    },
  };
</script>
