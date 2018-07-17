<template>
  <visibility-chooser :is-global="namespace.global" :visibility="namespace.visibility" :can-change="namespace.permissions.visibility" :locked="onGoingRequest" @update:visibility="change">
    <template slot="privateIcon">
      <i class="fa fa-fw fa-spinner fa-spin" v-if="showLoading('private')"></i>
      <i class="fa fa-fw fa-lock" v-else></i>
    </template>
    <template slot="protectedIcon">
      <i class="fa fa-fw fa-spinner fa-spin" v-if="showLoading('protected')"></i>
      <i class="fa fa-fw fa-users" v-else></i>
    </template>
    <template slot="publicIcon">
      <i class="fa fa-fw fa-spinner fa-spin" v-if="showLoading('public')"></i>
      <i class="fa fa-fw fa-globe" v-else></i>
    </template>
  </visibility-chooser>
</template>

<script>
  import Vue from 'vue';

  import NamespacesService from '../services/namespaces';

  import VisibilityChooser from './visibility-chooser';

  const { set } = Vue;

  export default {
    props: ['namespace'],

    components: {
      VisibilityChooser,
    },

    data() {
      return {
        newVisibility: null,
        onGoingRequest: false,
      };
    },

    methods: {
      showLoading(visibility) {
        return this.onGoingRequest
            && visibility === this.newVisibility;
      },

      change(visibility) {
        const currentVisibility = this.namespace.visibility;

        if (visibility === currentVisibility) {
          return;
        }

        set(this, 'onGoingRequest', true);
        set(this, 'newVisibility', visibility);

        NamespacesService.update(this.namespace.id, { namespace: { visibility } }).then(() => {
          set(this.namespace, 'visibility', visibility);
          this.$alert.$show(`Visibility of '${this.namespace.name}' namespace updated`);
        }).catch(() => {
          this.$alert.$show('An error happened while updating namespace visibility');
        }).finally(() => {
          set(this, 'onGoingRequest', false);
          set(this, 'newVisibility', null);
        });
      },
    },
  };
</script>
