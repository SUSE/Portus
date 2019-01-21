<template>
  <panel>
    <h5 slot="heading-left">Application tokens</h5>

    <div slot="heading-right" v-if="canCreate">
      <toggle-link text="Create" :state="state" state-key="newFormVisible" class="toggle-link-new-app-token"></toggle-link>
    </div>

    <div slot="body">
      <app-tokens-table :app-tokens="appTokens" sort-by="application"></app-tokens-table>
    </div>
  </panel>
</template>

<script>
  import AppTokensTable from './table';

  export default {
    props: {
      appTokens: Array,
      maxTokens: Number,
      state: Object,
    },

    components: {
      AppTokensTable,
    },

    computed: {
      canCreate() {
        return this.appTokens.length < this.maxTokens;
      },
    },
  };
</script>
