<template>
  <panel>
    <h5 slot="heading-left"><b>Delete</b> {{ user.display_username }}</h5>

    <div slot="body">
      <form role="form" @submit.prevent="openDeletionModal" novalidate>
        <p v-if="user.bot">As an administrator, you can delete this bot. Just click the button below.</p>
        <div v-else>
          <p>As an administrator, you can delete this user. That being said, be aware that doing this has its consequences:</p>

          <ul>
            <li>The namespace and the repositories of this user won't be deleted. You will still be able to access them and manage them.</li>
            <li>The user will be lost forever, so you won't be able to recover the data.</li>
            <li>The user refrence will be gone and some activities might disappear from your timeline.</li>
          </ul>

          <p>With this in mind, if you want to delete this user, just click the button below.</p>
        </div>
        <div class="form-group">
          <button type="submit" class="btn btn-danger toggle-deletion-modal">Delete</button>
        </div>
      </form>

      <user-deletion-modal :user="user" :redirect-path="usersPath" v-if="deletionModalVisible" @close="closeDeletionModal"></user-deletion-modal>
    </div>
  </panel>
</template>

<script>
  import Vue from 'vue';

  import UserDeletionModal from './deletion-modal';

  const { set } = Vue;

  export default {
    props: {
      user: Object,
      usersPath: String,
    },

    components: {
      UserDeletionModal,
    },

    data() {
      return {
        deletionModalVisible: false,
      };
    },

    methods: {
      openDeletionModal() {
        set(this, 'deletionModalVisible', true);
      },

      closeDeletionModal() {
        set(this, 'deletionModalVisible', false);
      },
    },
  };
</script>
