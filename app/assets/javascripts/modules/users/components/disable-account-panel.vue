<template>
  <panel>
    <h5 slot="heading-left">Disable account</h5>

    <div slot="body">
      <p>By disabling the account, you won't be able to access Portus with it, and any affiliations with any team will be lost.</p>
      <button type="button" class="btn btn-primary" @click.prevent="disable">Disable</button>
    </div>
  </panel>
</template>

<script>
  import { handleHttpResponseError } from '~/utils/http';

  import UsersService from '../service';

  export default {
    props: {
      userId: Number,
    },

    methods: {
      disable() {
        UsersService.toggleEnabled({ id: this.userId }).then(() => {
          this.$alert.$schedule("You've successfully disabled your own user account.");
          window.location.href = window.API_URL;
        }).catch(handleHttpResponseError);
      },
    },
  };
</script>
