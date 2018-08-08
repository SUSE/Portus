<template>
  <panel>
    <h5 slot="heading-left">
      <a data-placement="right"
        data-toggle="popover"
        data-container=".panel-heading"
        data-content="<p>A webhook is an HTTP callback which is triggered after an event, e.g. a push event, occurs.</p>"
        data-original-title="What's this?"
        tabindex="0"
        data-html="true">
        <i class="fa fa-info-circle"></i>
      </a>
      Webhooks for namespace <strong><a :href="namespacePath">{{ parentNamespace.name }}</a></strong>
    </h5>

    <div slot="heading-right" v-if="canCreateWebhook">
      <toggle-link text="Create new webhook" :state="state" state-key="newFormVisible" class="toggle-link-new-webhook"></toggle-link>
    </div>

    <div slot="body">
      <webhooks-table :webhooks="webhooks" :webhooks-path="webhooksPath" :can-create-webhook="canCreateWebhook" sort-by="name"></webhooks-table>
    </div>
  </panel>
</template>

<script>
  import WebhooksTable from './table';

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
      webhooks: {
        type: Array,
      },
      state: {
        type: Object,
      },
    },

    components: {
      WebhooksTable,
    },
  };
</script>
