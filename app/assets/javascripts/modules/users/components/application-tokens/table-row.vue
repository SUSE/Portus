<template>
  <tr :class="scopeClass">
    <td>{{ appToken.application }}</td>
    <td>
      <button class="btn btn-default delete-app-token-btn"
        data-placement="left"
        data-toggle="popover"
        data-title="Please confirm"
        data-content="<p>Are you sure you want to remove this token?</p>
        <a class='btn btn-default'>No</a> <a class='btn btn-primary yes'>Yes</a>"
        data-template="<div class='popover popover-app-token-delete' role='tooltip'><div class='arrow'></div><h3 class='popover-title'></h3><div class='popover-content'></div></div>'"
        data-html="true"
        role="button">
        <i class="fa fa-trash"></i>
      </button>
    </td>
  </tr>
</template>

<script>
  import { handleHttpResponseError } from '~/utils/http';

  import UsersService from '../../service';

  export default {
    props: ['appToken'],

    computed: {
      scopeClass() {
        return `application_token_${this.appToken.id}`;
      },
    },

    methods: {
      destroy() {
        UsersService.destroyToken(this.appToken.id).then(() => {
          this.$bus.$emit('appTokenDestroyed', this.appToken);
          this.$alert.$show(`Token '${this.appToken.application}' was removed successfully`);
        }).catch(handleHttpResponseError);
      },
    },

    mounted() {
      const REMOVE_BTN = '.delete-app-token-btn';
      const POPOVER_DELETE = '.popover-app-token-delete';

      // TODO: refactor bootstrap popover to a component
      $(this.$el).on('inserted.bs.popover', REMOVE_BTN, () => {
        const $yes = $(POPOVER_DELETE).find('.yes');
        $yes.click(this.destroy.bind(this));
      });
    },
  };
</script>
