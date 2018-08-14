<template>
  <form id="edit-webhook-form" role="form" class="form-horizontal" ref="form" @submit.prevent="onSubmit">
    <div class="form-group has-feedback" :class="{ 'has-error': $v.webhookCopy.name.$error }">
      <label for="webhook_name" class="control-label col-md-2">Name</label>
      <div class="col-md-7">
        <input placeholder="Name of the webhook" type="text" name="webhook[name]" id="webhook_name" class="form-control" v-model.trim="webhookCopy.name" @input="$v.webhookCopy.name.$touch()" ref="firstField" autofocus>
        <span class="help-block">
          <span v-if="!$v.webhookCopy.name.required">
            Name can't be blank
          </span>
        </span>
      </div>
    </div>
    <div class="form-group has-feedback" :class="{ 'has-error': $v.webhookCopy.url.$error }">
      <label for="webhook_url" class="control-label col-md-2">URL</label>
      <div class="col-md-7">
        <input placeholder="http://your.server/endpoint" type="url" name="webhook[url]" id="webhook_url" class="form-control" v-model.trim="webhookCopy.url" @input="$v.webhookCopy.url.$touch()">
        <span class="help-block">
          <span v-if="!$v.webhookCopy.url.required">
            URL can't be blank
          </span>
        </span>
      </div>
    </div>
    <div class="form-group">
      <label for="webhook_request_method" class="control-label col-md-2">Request method</label>
      <div class="col-md-7">
        <select name="webhook[request_method]" id="webhook_request_method" class="form-control" v-model="webhookCopy.request_method">
          <option value="GET">GET</option>
          <option value="POST">POST</option>
        </select>
      </div>
    </div>
    <div class="form-group">
      <label for="webhook_content_type" class="control-label col-md-2">Content type</label>
      <div class="col-md-7">
        <select name="webhook[content_type]" id="webhook_content_type" class="form-control" v-model="webhookCopy.content_type">
          <option value="application/json">application/json</option>
          <option value="application/x-www-form-urlencoded">application/x-www-form-urlencoded</option>
        </select>
      </div>
    </div>
    <div class="form-group">
      <label for="webhook_username" class="control-label col-md-2">Username</label>
      <div class="col-md-7">
        <input placeholder="Username for authentication" type="text" name="webhook[username]" id="webhook_username" class="form-control" v-model.trim="webhookCopy.username">
      </div>
    </div>
    <div class="form-group">
      <label for="webhook_password" class="control-label col-md-2">Password</label>
      <div class="col-md-7">
        <input placeholder="Password for authentication" type="text" name="webhook[password]" id="webhook_password" class="form-control" v-model.trim="webhookCopy.password">
      </div>
    </div>
    <div class="form-group">
      <label for="webhook_enabled" class="control-label col-md-2">Enabled</label>
      <div class="col-md-7">
        <span @click.prevent="webhookCopy.enabled=!webhookCopy.enabled" >
          <i class="fa fa-2x fa-toggle-on toggle" title="Click to disable" v-if="webhookCopy.enabled"></i>
          <i class="fa fa-2x fa-toggle-off toggle" title="Click to enable" v-else></i>
        </span>
      </div>
    </div>
    <div class="form-group">
      <div class="col-md-offset-2 col-md-7">
        <input type="submit" name="commit" value="Save" class="btn btn-primary" :disabled="$v.$invalid">
      </div>
    </div>
  </form>
</template>

<script>
  import Vue from 'vue';

  import { required } from 'vuelidate/lib/validators';

  import { handleHttpResponseError } from '~/utils/http';

  import FormMixin from '~/shared/mixins/form';

  import WebhooksService from '../services/webhooks';

  const { set } = Vue;

  export default {
    props: ['webhook', 'visible'],

    mixins: [FormMixin],

    data() {
      return {
        webhookCopy: {},
      };
    },

    methods: {
      onSubmit() {
        WebhooksService.update(this.webhook.namespace_id, this.webhookCopy).then((response) => {
          const webhook = response.data;

          this.$bus.$emit('webhookUpdated', webhook);
          this.$alert.$show(`Webhook '${webhook.name}' was updated successfully`);
        }).catch(handleHttpResponseError);
      },

      copyOriginal() {
        set(this, 'webhookCopy', { ...this.webhook });
      },
    },

    watch: {
      visible: {
        handler: 'copyOriginal',
        immediate: true,
      },
    },

    validations: {
      webhookCopy: {
        name: {
          required,
        },
        url: {
          required,
        },
      },
    },
  };
</script>
