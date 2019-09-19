<template>
  <form id="new-user-form" class="form-horizontal collapse" role='form' ref="form" @submit.prevent="onSubmit" novalidate>
    <div class="form-group" :class="{ 'has-error': $v.user.username.$error }">
      <label class="control-label col-md-2" for="user_username">Username</label>
      <div class="col-md-7">
        <input type="text" id="user_username" name="user[username]" class="form-control" placeholder="Enter users's username" @input="$v.user.username.$touch()" v-model.trim="user.username" ref="firstField" required />
        <span class="help-block">
          <span v-if="!$v.user.username.required">Username can't be blank</span>
        </span>
      </div>
    </div>
    <div class="form-group" :class="{ 'has-error': $v.user.email.$error }">
      <label class="control-label col-md-2" for="user_email">Email</label>
      <div class="col-md-7">
        <input type="email" id="user_email" name="user[email]" class="form-control" placeholder="Enter users's email" @input="$v.user.email.$touch()" v-model.trim="user.email" required />
        <span class="help-block">
          <span v-if="!$v.user.email.required">Email can't be blank</span>
          <span v-if="!$v.user.email.email">Email is invalid</span>
        </span>
      </div>
    </div>
    <div class="form-group" :class="{ 'has-error': $v.user.password.$error }">
      <label class="control-label col-md-2" for="user_password">Password</label>
      <div class="col-md-7">
        <input type="password" id="user_password" name="user[password]" class="form-control" placeholder="at least 8 characters" @input="$v.user.password.$touch()" v-model.trim="user.password" required />
        <span class="help-block">
          <span v-if="!$v.user.password.required">Password can't be blank</span>
          <span v-if="!$v.user.password.minLength">Password is too short (minimum is 8 characters)</span>
        </span>
      </div>
    </div>
    <div class="form-group" :class="{ 'has-error': $v.user.password_confirmation.$error }">
      <label class="control-label col-md-2" for="user_password_confirmation">Password confirmation</label>
      <div class="col-md-7">
        <input type="password" id="user_password_confirmation" name="user[password_confirmation]" class="form-control" placeholder="Confirm your password" @input="$v.user.password_confirmation.$touch()" v-model.trim="user.password_confirmation" required />
        <span class="help-block">
          <span v-if="!$v.user.password_confirmation.sameAs">Password confirmation doesn't match password</span>
        </span>
      </div>
    </div>
    <div class="form-group">
      <label class="control-label col-md-2" for="user_bot" title="Set this to enable SSL in the communication between Portus and the Registry">Bot</label>
      <div class="col-md-7">
        <input name="user[bot]" type="hidden" value="0">
        <input type="checkbox" name="user[bot]" id="user_bot" v-model="user.bot" value="1" />
      </div>
    </div>
    <div class="form-group">
      <div class="col-md-offset-2 col-md-7">
        <button type="submit" class="btn btn-primary" :disabled="$v.$invalid">Save</button>
      </div>
    </div>
  </form>
</template>

<script>
  import Vue from 'vue';

  import {
    required, sameAs, minLength, email,
  } from 'vuelidate/lib/validators';

  import FormMixin from '~/shared/mixins/form';

  import { handleHttpResponseError } from '~/utils/http';

  import UsersService from '../service';

  const { set } = Vue;

  export default {
    mixins: [FormMixin],

    data() {
      return {
        user: {
          name: '',
          email: '',
          password: '',
          password_confirmation: '',
          bot: false,
        },
        timeout: {
          name: null,
        },
      };
    },

    methods: {
      onSubmit() {
        UsersService.save(this.user).then((response) => {
          const { user } = response.data;
          const token = response.data.plain_token;

          this.toggleForm();
          this.$v.$reset();
          set(this, 'user', {
            name: '',
          });

          this.$bus.$emit('userCreated', user);

          if (user.bot) {
            this.$alert.$show(`Bot '${user.username}' was created successfully. An application token was created automatically: <code>${token}</code>`);
          } else {
            this.$alert.$show(`User '${user.username}' was created successfully`);
          }
        }).catch(handleHttpResponseError);
      },
    },

    validations: {
      user: {
        username: {
          required,
        },
        email: {
          required,
          email,
        },
        password: {
          required,
          minLength: minLength(8),
        },
        password_confirmation: {
          sameAs: sameAs('password'),
        },
      },
    },
  };
</script>
