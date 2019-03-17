<template>
  <div class="admin-users-edit-page">
    <user-edit-panel :user="user" :display-name-enabled="displayNameEnabled"></user-edit-panel>
    <app-tokens-wrapper :user-id="user.id" :app-tokens-ref="appTokensRef" :max-tokens="maxTokens" v-if="user.bot"></app-tokens-wrapper>
    <user-deletion-panel :user="user" :users-path="usersPath"></user-deletion-panel>
  </div>
</template>

<script>
  import UserEditPanel from '../components/edit-panel';
  import AppTokensWrapper from '../components/application-tokens/wrapper';
  import UserDeletionPanel from '../components/deletion-panel';

  export default {
    props: {
      userRef: Object,
      usersPath: String,
      maxTokens: Number,
      appTokensRef: Array,
      displayNameEnabled: Boolean,
    },

    components: {
      AppTokensWrapper,
      UserDeletionPanel,
      UserEditPanel,
    },

    data() {
      return {
        user: { ...this.userRef },
      };
    },
  };
</script>
