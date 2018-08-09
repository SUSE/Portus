<template>
  <span>
    <a class="topbar btn btn-default" id="logout" data-placement="bottom" data-toggle="tooltip" :title="title" rel="nofollow" href="#" v-bind="$attrs" @click.prevent="onClick">
      <i class="fa fa-sign-out"></i>
    </a>
    <form method="post" :action="href" class="hidden" ref="form">
      <input name="_method" value="delete" type="hidden" />
      <input name="authenticity_token" :value="csrfToken" type="hidden" />
    </form>
  </span>
</template>

<script>
  import CSRF from '~/utils/csrf';

  export default {
    inheritAttrs: false,

    props: {
      href: String,
      title: {
        type: String,
        default: 'Sign out',
      },
    },

    computed: {
      csrfToken() {
        return CSRF.token();
      },
    },

    methods: {
      onClick() {
        this.$refs.form.submit();
      },
    },
  };
</script>
