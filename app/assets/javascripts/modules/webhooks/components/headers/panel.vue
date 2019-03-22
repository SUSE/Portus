<template>
  <panel>
    <h5 slot="heading-left">
      <popover title="What's this?" trigger="hover-focus">
        <a tabindex="0">
          <i class="fa fa-info-circle"></i>
        </a>
        <template slot="popover">
          A header is a HTTP header, i.e. is a key-value pair which is included in the HTTP request.
        </template>
      </popover>
      Headers
    </h5>

    <div slot="heading-right" v-if="webhook.updatable">
      <toggle-link text="Create new header" :state="state" state-key="newHeaderFormVisible" class="toggle-link-new-webhook-header"></toggle-link>
    </div>

    <div slot="body">
      <webhook-headers-table :webhook="webhook" :headers="headers" sort-by="name" prefix="wb_"></webhook-headers-table>
    </div>
  </panel>
</template>

<script>
  import { Popover } from 'uiv';
  import WebhookHeadersTable from './table';

  export default {
    props: {
      webhook: {
        type: Object,
      },
      headers: {
        type: Array,
      },
      state: {
        type: Object,
      },
    },

    components: {
      WebhookHeadersTable,
      Popover,
    },
  };
</script>
