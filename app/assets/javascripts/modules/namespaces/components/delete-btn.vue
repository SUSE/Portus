<template>
  <span>
    <popover title="Delete namespace" placement="left" v-model="confirm">
      <button class="btn btn-danger btn-sm" role="button" :disabled="state.isDeleting">
        <i class="fa fa-trash"></i>
        Delete
      </button>
      <template slot="popover">
        <div class='popover-content'>
          <p>Are you sure you want to remove this namespace?</p>
          <a class='btn btn-default' @click="confirm = false">No</a>
          <a class='btn btn-primary yes' @click="deleteNamespace">Yes</a>
        </div>
      </template>
    </popover>
  </span>
</template>

<script>
  import Vue from 'vue';

  import { handleHttpResponseError } from '~/utils/http';

  import { Popover } from 'uiv';
  import NamespacesStore from '../store';
  import NamespacesService from '../services/namespaces';

  const { set } = Vue;

  export default {
    props: {
      namespace: {
        type: Object,
        required: true,
      },
      redirectPath: String,
    },

    data() {
      return {
        state: NamespacesStore.state,
        confirm: false,
      };
    },

    methods: {
      deleteNamespace() {
        set(this.state, 'isDeleting', true);

        NamespacesService.remove(this.namespace.id).then(() => {
          this.$alert.$schedule('Namespace removed with all its repositories');
          window.location.href = this.redirectPath;
        }).catch(handleHttpResponseError)
          .finally(() => set(this.state, 'isDeleting', false));
      },
    },

    components: {
      Popover,
    },
  };
</script>
