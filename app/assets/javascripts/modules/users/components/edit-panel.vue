<template>
  <panel>
    <h5 slot="heading-left"><b>Edit</b> {{ user.display_username }} <span v-if="user.bot">(bot)</span></h5>

    <div slot="body">
      <form id="edit-user-form" role="form" @submit.prevent="onSubmit" novalidate>
        <div class="form-group" :class="{ 'has-error': $v.userCopy.email.$error }">
          <label class="control-label" for="user_email">Email</label>
          <div>
            <input type="text" id="user_email" name="user[email]" class="form-control" placeholder="Enter users's email" @input="$v.userCopy.email.$touch()" v-model.trim="userCopy.email" ref="firstField" required />
            <span class="help-block">
              <span v-if="!$v.userCopy.email.required">Email can't be blank</span>
              <span v-if="!$v.userCopy.email.email">Email is invalid</span>
            </span>
          </div>
        </div>

        <div class="form-group" :class="{ 'has-error': $v.userCopy.display_name.$error }" v-if="displayNameEnabled">
          <label class="control-label" for="user_display_name">Display name</label>
          <div>
            <input type="text" id="user_display_name" name="user[display_name]" class="form-control" placeholder="Enter users's display_name" @input="$v.userCopy.display_name.$touch()" v-model.trim="userCopy.display_name" required />
            <span class="help-block">
              <span v-if="!$v.userCopy.display_name.required">Display name can't be blank</span>
            </span>
          </div>
        </div>

        <div class="form-group">
          <button type="submit" class="btn btn-primary" :disabled="$v.$invalid">Save</button>
        </div>
      </form>
    </div>
  </panel>
</template>

<script>
  import { required, requiredIf, email } from 'vuelidate/lib/validators';

  import { handleHttpResponseError } from '~/utils/http';

  import UsersService from '../service';

  export default {
    props: {
      user: Object,
      displayNameEnabled: Boolean,
    },

    data() {
      return {
        userCopy: {
          id: this.user.id,
          email: this.user.email,
          display_name: this.user.display_username,
        },
      };
    },

    methods: {
      onSubmit() {
        UsersService.update(this.userCopy).then((response) => {
          const user = response.data;

          this.$v.$reset();

          this.$bus.$emit('userSaved', user);
          this.$alert.$show(`User '${this.user.username}' was updated successfully`);
        }).catch(handleHttpResponseError);
      },
    },

    validations: {
      userCopy: {
        email: {
          required,
          email,
        },
        display_name: {
          required: requiredIf(function () {
            return this.displayNameEnabled;
          }),
        },
      },
    },
  };
</script>
