<template>
  <form id="new-app-token-form" role="form" class="form-horizontal collapse"
    ref="form" @submit.prevent="onSubmit">
    <div class="form-group has-feedback" :class="{ 'has-error': $v.appToken.application.$error }">
      <label for="application_token_application" class="control-label col-md-2">Application</label>
      <div class="col-md-7">
        <input type="text" placeholder="Name" name="application_token[application]" id="application_token_application" ref="firstField" class="form-control fixed-size" @input="$v.appToken.application.$touch()" v-model.trim="appToken.application" />
        <span class="help-block">
          <span v-if="!$v.appToken.application.required">
            Application can't be blank
          </span>
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

  import UsersService from '../../service';

  const { set } = Vue;

  export default {
    props: {
      userId: Number,
    },

    mixins: [FormMixin],

    data() {
      return {
        appToken: {
          application: null,
        },
      };
    },

    methods: {
      onSubmit() {
        UsersService.createToken(this.userId, this.appToken).then((response) => {
          const appToken = response.data;

          this.toggleForm();
          this.$v.$reset();
          set(this, 'appToken', {
            application: null,
          });

          this.$bus.$emit('appTokenAdded', appToken);
          this.$alert.$show(`Token <code>${appToken.plain_token}</code> was created successfully`);
        }).catch(handleHttpResponseError);
      },
    },

    validations: {
      appToken: {
        application: {
          required,
        },
      },
    },
  };
</script>
