<template>
  <panel>
    <h5 slot="heading-left">
      <a data-placement="right"
        data-toggle="popover"
        data-container=".panel-heading"
        data-content="<b>Name</b>: Name of the webhook.<br>
        <b>Request method</b>: URL endpoint where the HTTP request is sent to.<br/>
        <b>Content type</b>: Description of the webhook request content.<br/>
        <b>Username</b>: Username used for basic HTTP auth.<br/>
        <b>Password</b>: Password used for basic HTTP auth."
        data-original-title="What's this?"
        tabindex="0"
        data-html="true">
        <i class="fa fa-info-circle"></i>
      </a>
      <strong>{{ webhook.name }}</strong> webhook
    </h5>

    <div slot="heading-right" v-if="webhook.updatable">
      <toggle-link text="Edit webhook" :state="state" state-key="editFormVisible" class="toggle-link-edit-webhook" true-icon="fa-close" false-icon="fa-pencil"></toggle-link>
    </div>

    <div slot="body">
      <webhook-info :webhook="webhook" v-if="!state.editFormVisible"></webhook-info>
      <edit-webhook-form :webhook="webhook" :visible="state.editFormVisible" v-else></edit-webhook-form>
    </div>
  </panel>
</template>

<script>
  import WebhookInfo from './info';
  import EditWebhookForm from './edit-form';

  export default {
    props: {
      webhook: {
        type: Object,
      },
      state: {
        type: Object,
      },
    },

    components: {
      EditWebhookForm,
      WebhookInfo,
    },
  };
</script>
