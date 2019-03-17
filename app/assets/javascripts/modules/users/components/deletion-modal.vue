<style>
  .delete-modal .modal-dialog {
    width: 400px;
  }

  .submit-btn {
    width: 100%;
  }
</style>

<template>
  <modal class="delete-modal" v-on="$listeners" @enter="onEnter" ref="modal">
    <template slot="title">
      <h4>Delete user</h4>
    </template>

    <template slot="body">
      <p>You are about to delete the <strong>{{ user.username }}</strong> user. This action <strong>cannot</strong> be undone.</p> Are you sure?
    </template>

    <template slot="footer">
      <button type="button" class="btn btn-danger submit-btn" @click="onSubmit" :disabled="isDeleting">I understand, delete user</button>
    </template>
  </modal>
</template>

<script>
  import Vue from 'vue';

  import { handleHttpResponseError } from '~/utils/http';

  import UsersService from '../service';

  const { set } = Vue;

  export default {
    props: {
      user: Object,
      redirectPath: String,
    },

    data() {
      return {
        close: false,
        isDeleting: false,
      };
    },

    methods: {
      onEnter() {
        this.$refs.modal.$el.focus();
      },

      onSubmit() {
        set(this, 'isDeleting', true);

        UsersService.destroy(this.user).then(() => {
          this.$alert.$schedule(`User '${this.user.username}' was removed successfully`);
          this.$refs.modal.close();
          window.location.href = this.redirectPath;
        }).catch(handleHttpResponseError);
      },
    },
  };
</script>
