<template>
  <panel>
    <h5 slot="heading-left">
      <popover title="What's this?" trigger="hover-focus">
        <a tabindex="0">
          <i class="fa fa-info-circle"></i>
        </a>
        <template slot="popover">
          A delivery is created once a webhook has been triggered. They are not re-created but updated after retriggering.
        </template>
      </popover>
      Deliveries
    </h5>

    <div slot="body">
      <webhook-deliveries-table :webhook="webhook" :deliveries="deliveries" sort-by="name" prefix="wd_"></webhook-deliveries-table>
    </div>
  </panel>
</template>

<script>
  import { Popover } from 'uiv';
  import WebhookDeliveriesTable from './table';

  export default {
    props: {
      webhook: {
        type: Object,
      },
      deliveries: {
        type: Array,
      },
    },

    components: {
      WebhookDeliveriesTable,
      Popover,
    },
  };
</script>
