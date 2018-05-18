<template>
  <tr :class="scopeClass">
    <td>{{ header.name }}</td>
    <td>{{ header.value }}</td>
    <td v-if="webhook.updatable">
      <button class="btn btn-default delete-webhook-header-btn"
        data-placement="left"
        data-toggle="popover"
        data-title="Please confirm"
        data-content="<p>Are you sure you want to remove this\
        webhook header?</p><a class='btn btn-default'>No</a> <a class='btn \
        btn-primary yes'>Yes</a>"
        data-template="<div class='popover popover-webhook-header-delete' role='tooltip'><div class='arrow'></div><h3 class='popover-title'></h3><div class='popover-content'></div></div>'"
        role="button"
        data-html="true">
        <i class="fa fa-trash"></i>
      </button>
    </td>
  </tr>
</template>

<script>
  import { handleHttpResponseError } from '~/utils/http';

  import WebhookHeadersService from '../../services/headers';

  export default {
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

    mounted() {
      const REMOVE_BTN = '.delete-webhook-header-btn';
      const POPOVER_DELETE = '.popover-webhook-header-delete';

      // TODO: refactor bootstrap popover to a component
      $(this.$el).on('inserted.bs.popover', REMOVE_BTN, () => {
        const $yes = $(POPOVER_DELETE).find('.yes');
        $yes.click(this.destroy.bind(this));
      });
    },
  };
</script>
