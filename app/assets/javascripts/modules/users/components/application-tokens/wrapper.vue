<template>
  <div class="app-tokens-wrapper">
    <app-tokens-form :state="state" form-state="newFormVisible" :user-id="userId"></app-tokens-form>
    <app-tokens-panel :app-tokens="appTokens" :max-tokens="maxTokens" :state="state"></app-tokens-panel>
  </div>
</template>

<script>
  import Vue from 'vue';

  import AppTokensForm from './form';
  import AppTokensPanel from './panel';

  import UsersStore from '../../store';

  const { set } = Vue;

  export default {
    props: {
      appTokensRef: Array,
      maxTokens: Number,
      userId: Number,
    },

    components: {
      AppTokensForm,
      AppTokensPanel,
    },

    data() {
      return {
        appTokens: [...this.appTokensRef],
        state: UsersStore.state,
      };
    },

    methods: {
      onAppTokenAdded(appToken) {
        const newAppTokens = [
          ...this.appTokens,
          appToken,
        ];

        set(this, 'appTokens', newAppTokens);
      },

      onAppTokenDestroyed(appToken) {
        const currentAppTokens = this.appTokens;
        const index = currentAppTokens.findIndex(c => c.id === appToken.id);

        const appTokens = [
          ...currentAppTokens.slice(0, index),
          ...currentAppTokens.slice(index + 1),
        ];

        set(this, 'appTokens', appTokens);
      },
    },

    created() {
      this.$bus.$on('appTokenAdded', appToken => this.onAppTokenAdded(appToken));
      this.$bus.$on('appTokenDestroyed', appToken => this.onAppTokenDestroyed(appToken));
    },
  };
</script>
