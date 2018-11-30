<template>
  <a type="button" class="btn btn-primary btn-sm toggle-link" @click.prevent="toggle">
    <i class="fa" :class="icon"></i> {{ text }}
  </a>
</template>

<script>
  import Vue from 'vue';

  const { set } = Vue;

  export default {
    props: {
      state: {
        type: Object,
        required: true,
      },
      stateKey: {
        type: String,
        required: true,
      },
      text: {
        type: String,
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
          [this.falseIcon]: this.state[this.stateKey] === false,
          [this.trueIcon]: this.state[this.stateKey] === true,
        };
      },
    },

    methods: {
      toggle() {
        set(this.state, this.stateKey, !this.state[this.stateKey]);
      },
    },
  };
</script>
