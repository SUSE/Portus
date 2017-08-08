<template>
  <a type="button" class="btn btn-xs btn-link toggle-link" @click="onClick">
    <i class="fa" :class="icon"></i> {{ text }}
  </a>
</template>

<script>
  export default {
    props: {
      state: {
        type: Boolean,
        required: true,
      },
      text: {
        type: String,
        required: true,
      },
      onClick: {
        type: Function,
        required: true,
      },
      trueIcon: {
        default: 'fa-minus-circle',
      },
      falseIcon: {
        default: 'fa-plus-circle',
      },
    },

    computed: {
      icon() {
        return {
          [this.falseIcon]: this.state === false,
          [this.trueIcon]: this.state === true,
        };
      },
    },
  };
</script>
