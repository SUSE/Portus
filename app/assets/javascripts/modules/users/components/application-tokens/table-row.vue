<template>
  <tr :class="scopeClass">
    <td>{{ appToken.application }}</td>
    <td>
      <popover title="Please confirm" placement="left" v-model="confirm">
        <button class="btn btn-default delete-app-token-btn" role="button">
          <i class="fa fa-trash"></i>
        </button>
        <template slot="popover">
          <div class='popover-content'>
            <p>Are you sure you want to remove this token?</p>
            <a class='btn btn-default' @click="confirm = false">No</a>
            <a class='btn btn-primary yes' @click="destroy">Yes</a>
          </div>
        </template>
      </popover>
    </td>
  </tr>
</template>

<script>
  import { handleHttpResponseError } from '~/utils/http';

  import UsersService from '../../service';
  import { Popover } from 'uiv';

  export default {
    data() {
      return {
        confirm: false,
      };
    },

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

    components: {
      Popover,
    },
  };
</script>
