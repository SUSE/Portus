<template>
  <form id="new-webhook-form" role="form" class="form-horizontal collapse"
    ref="form" @submit.prevent="onSubmit">
    <div class="form-group has-feedback" :class="{ 'has-error': $v.webhook.name.$error }">
      <label for="webhook_name" class="control-label col-md-2">Name</label>
      <div class="col-md-7">
        <input placeholder="Name of the webhook" type="text" name="webhook[name]" id="webhook_name" class="form-control" v-model.trim="webhook.name" @input="$v.webhook.name.$touch()" ref="firstField" autofocus>
        <span class="help-block">
          <span v-if="!$v.webhook.name.required">
            Name can't be blank
          </span>
        </span>
      </div>
    </div>
    <div class="form-group has-feedback" :class="{ 'has-error': $v.webhook.url.$error }">
      <label for="webhook_url" class="control-label col-md-2">URL</label>
      <div class="col-md-7">
        <input placeholder="http://your.server/endpoint" type="url" name="webhook[url]" id="webhook_url" class="form-control" v-model.trim="webhook.url" @input="$v.webhook.url.$touch()">
        <span class="help-block">
          <span v-if="!$v.webhook.url.required">
            URL can't be blank
          </span>
        </span>
      </div>
    </div>
    <div class="form-group">
      <label for="webhook_request_method" class="control-label col-md-2">Request method</label>
      <div class="col-md-7">
        <select name="webhook[request_method]" id="webhook_request_method" class="form-control" v-model="webhook.request_method">
          <option value="GET">GET</option>
          <option value="POST">POST</option>
        </select>
      </div>
    </div>
    <div class="form-group">
      <label for="webhook_content_type" class="control-label col-md-2">Content type</label>
      <div class="col-md-7">
        <select name="webhook[content_type]" id="webhook_content_type" class="form-control" v-model="webhook.content_type">
          <option value="application/json">application/json</option>
          <option value="application/x-www-form-urlencoded">application/x-www-form-urlencoded</option>
        </select>
      </div>
    </div>
    <div class="form-group">
      <label for="webhook_username" class="control-label col-md-2">Username</label>
      <div class="col-md-7">
        <input placeholder="Username for authentication" type="text" name="webhook[username]" id="webhook_username" class="form-control" v-model.trim="webhook.username">
      </div>
    </div>
    <div class="form-group">
      <label for="webhook_password" class="control-label col-md-2">Password</label>
      <div class="col-md-7">
        <input placeholder="Password for authentication" type="text" name="webhook[password]" id="webhook_password" class="form-control" v-model.trim="webhook.password">
      </div>
    </div>
    <div class="form-group">
      <div class="col-md-offset-2 col-md-7">
        <input type="submit" name="commit" value="Add" class="btn btn-primary" :disabled="$v.$invalid">
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
    props: ['parentNamespace'],

    mixins: [FormMixin],

    data() {
      return {
        webhook: {
          name: null,
          url: null,
          content_type: 'application/json',
          request_method: 'GET',
          username: null,
          password: null,
        },
      };
    },

    methods: {
      onSubmit() {
        WebhooksService.save(this.parentNamespace.id, this.webhook).then((response) => {
          const webhook = response.data;

          this.toggleForm();
          this.$v.$reset();
          set(this, 'webhook', {
            name: null,
            url: null,
            content_type: 'application/json',
            request_method: 'GET',
            username: null,
            password: null,
          });

          this.$bus.$emit('webhookCreated', webhook);
          this.$alert.$show(`Webhook '${webhook.name}' was created successfully`);
        }).catch(handleHttpResponseError);
      },
    },

    validations: {
      webhook: {
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
