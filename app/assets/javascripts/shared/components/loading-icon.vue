<template>
  <div class="text-center">
    <i class="fa fa-spin fa-spinner" :class="cssClass"></i>
  </div>
</template>

<script>
  export default {
    props: {
      size: {
        type: [String, Number],
        default: 2,
      },
    },

    computed: {
      cssClass() {
        return `fa-${this.size}x`;
      },
    },
  };
</script>
