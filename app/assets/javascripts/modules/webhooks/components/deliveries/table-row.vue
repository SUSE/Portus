<template>
  <tr :class="scopeClass">
    <td>
      <i :class="statusIcon"></i>
      {{ delivery.uuid }}
    </td>
    <td>{{ updatedAt }}</td>
    <td v-if="webhook.updatable">
      <button class="btn btn-default delete-webhook-btn"
        @click="retrigger"
        v-if="webhook.enabled">
        <i class="fa fa-refresh" :class="{'fa-spin': ongoingRequest}"></i>
      </button>
      <button class="btn btn-default delete-webhook-btn"
        data-placement="left"
        data-toggle="popover"
        data-title="Please confirm"
        data-content="<p>This webhook is disabled. Are you sure you want to retrigger it?</p>
        <a class='btn btn-default'>No</a> <a class='btn btn-primary yes'>Yes</a>"
        data-template="<div class='popover popover-webhook-delete' role='tooltip'><div class='arrow'></div><h3 class='popover-title'></h3><div class='popover-content'></div></div>'"
        data-html="true"
        role="button"
        :disabled="ongoingRequest"
        v-else>
        <i class="fa fa-refresh" :class="{'fa-spin': ongoingRequest}"></i>
      </button>
    </td>
  </tr>
</template>

<script>
  import Vue from 'vue';
  import dayjs from 'dayjs';

  import { handleHttpResponseError } from '~/utils/http';

  import WebhookDeliveriesService from '../../services/deliveries';

  const { set } = Vue;

  export default {
    props: ['delivery', 'webhook'],

    data() {
      return {
        ongoingRequest: false,
      };
    },

    computed: {
      scopeClass() {
        return `webhook_delivery_${this.delivery.id}`;
      },

      statusIcon() {
        if (this.delivery.status === 200) {
          return 'fa fa-check fa-lg text-success';
        }

        return 'fa fa-close fa-lg text-danger';
      },

      updatedAt() {
        return dayjs(this.delivery.updated_at).fromNow();
      },
    },

    methods: {
      retrigger() {
        const namespaceId = this.webhook.namespace_id;
        const webhookId = this.webhook.id;
        const { id } = this.delivery;

        set(this, 'ongoingRequest', true);
        WebhookDeliveriesService.retrigger(namespaceId, webhookId, id).then((response) => {
          const delivery = response.data;

          this.$bus.$emit('deliveryRetriggered', delivery);
          this.$alert.$show(`Delivery '${this.delivery.uuid}' was retriggered successfully`);
        }).catch(handleHttpResponseError)
          .finally(() => set(this, 'ongoingRequest', false));
      },
    },

    mounted() {
      const REMOVE_BTN = '.delete-webhook-delivery-btn';
      const POPOVER_DELETE = '.popover-webhook-delivery-delete';

      // TODO: refactor bootstrap popover to a component
      $(this.$el).on('inserted.bs.popover', REMOVE_BTN, () => {
        const $yes = $(POPOVER_DELETE).find('.yes');
        $yes.click(this.retrigger.bind(this));
      });
    },
  };
</script>
