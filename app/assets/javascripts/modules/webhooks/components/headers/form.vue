<template>
  <form id="new-webhook-header-form" role="form" class="form-horizontal collapse"
    ref="form" @submit.prevent="onSubmit">
    <div class="form-group has-feedback" :class="{ 'has-error': $v.header.name.$error }">
      <label for="header_name" class="control-label col-md-2">Name</label>
      <div class="col-md-7">
        <input placeholder="e.g.: Authorization" type="text" name="header[name]" id="header_name" class="form-control" v-model.trim="header.name" @input="$v.header.name.$touch()" ref="firstField" autofocus>
        <span class="help-block">
          <span v-if="!$v.header.name.required">
            Name can't be blank
          </span>
        </span>
      </div>
    </div>
    <div class="form-group has-feedback" :class="{ 'has-error': $v.header.value.$error }">
      <label for="header_url" class="control-label col-md-2">Value</label>
      <div class="col-md-7">
        <input placeholder="e.g.: Basic YWxhZGRpbjpvcGVuc2VzYW1l" type="value" name="header[value]" id="header_url" class="form-control" v-model.trim="header.value" @input="$v.header.value.$touch()">
        <span class="help-block">
          <span v-if="!$v.header.value.required">
            Value can't be blank
          </span>
        </span>
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

  import WebhookHeadersService from '../../services/headers';

  const { set } = Vue;

  export default {
    props: ['webhook'],

    mixins: [FormMixin],

    data() {
      return {
        header: {
          name: null,
          value: null,
        },
      };
    },

    methods: {
      onSubmit() {
        const namespaceId = this.webhook.namespace_id;
        const webhookId = this.webhook.id;

        WebhookHeadersService.save(namespaceId, webhookId, this.header).then((response) => {
          const header = response.data;

          this.toggleForm();
          this.$v.$reset();
          set(this, 'header', {
            name: null,
            value: null,
          });

          this.$bus.$emit('webhookHeaderCreated', header);
          this.$alert.$show(`Header '${header.name}' was created successfully`);
        }).catch(handleHttpResponseError);
      },
    },

    validations: {
      header: {
        name: {
          required,
        },
        value: {
          required,
        },
      },
    },
  };
</script>
