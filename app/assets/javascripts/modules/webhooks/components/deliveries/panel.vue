<template>
  <panel>
    <h5 slot="heading-left">
      <a data-placement="right"
        data-toggle="popover"
        data-container=".panel-heading"
        data-content="A delivery is created once a webhook has been triggered. They are not re-created but updated after retriggering."
        data-original-title="What's this?"
        tabindex="0">
        <i class="fa fa-info-circle"></i>
      </a>
      Deliveries
    </h5>

    <div slot="body">
      <webhook-deliveries-table :webhook="webhook" :deliveries="deliveries" sort-by="name" prefix="wd_"></webhook-deliveries-table>
    </div>
  </panel>
</template>

<script>
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
    },
  };
</script>
