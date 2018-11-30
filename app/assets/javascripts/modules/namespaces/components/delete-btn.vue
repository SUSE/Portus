<template>
  <span>
    <button
      class="btn btn-danger btn-sm namespace-delete-btn"
      data-container="body"
      data-placement="left"
      data-toggle="popover"
      data-content="<p>Are you sure you want to remove this namespace?</p>
      <a class='btn btn-default'>No</a> <a class='btn btn-primary yes'>Yes</a>"
      data-template="<div class='popover popover-namespace-delete' role='tooltip'><div class='arrow'></div><h3 class='popover-title'></h3><div class='popover-content'></div></div>'"
      data-html="true"
      role="button"
      title="Delete image"
      :disabled="state.isDeleting">
      <i class="fa fa-trash"></i>
      Delete
    </button>
  </span>
</template>

<script>
  import Vue from 'vue';

  import { handleHttpResponseError } from '~/utils/http';

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

    mounted() {
      const DELETE_BTN = '.namespace-delete-btn';
      const POPOVER_DELETE = '.popover-namespace-delete';

      // TODO: refactor bootstrap popover to a component
      $(this.$el).on('inserted.bs.popover', DELETE_BTN, () => {
        const $yes = $(POPOVER_DELETE).find('.yes');
        $yes.click(this.deleteNamespace.bind(this));
      });
    },
  };
</script>
