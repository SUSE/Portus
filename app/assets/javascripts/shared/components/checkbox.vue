<style scoped>
  /* css partially extracted and adapted from https://lokesh-coder.github.io/pretty-checkbox/ */
  .pretty-checkbox {
    position: relative;
    display: inline-block;
    margin-right: 1em;
    white-space: nowrap;
    line-height: 1;
  }

  .pretty-checkbox input {
    position: absolute;
    left: 0;
    top: 0;
    min-width: 1em;
    width: 100%;
    height: 100%;
    z-index: 2;
    opacity: 0;
    margin: 0;
    padding: 0;
    cursor: pointer;
  }

  .pretty-checkbox .state label {
    position: initial;
    display: inline-block;
    font-weight: 400;
    margin: 0;
    text-indent: 1.5em;
    min-width: calc(1em + 2px);
  }

  .pretty-checkbox .state label:after,
  .pretty-checkbox .state label:before {
    content: '';
    width: calc(1em + 2px);
    height: calc(1em + 2px);
    display: block;
    box-sizing: border-box;
    border-radius: 0;
    border: 1px solid transparent;
    z-index: 0;
    position: absolute;
    left: 0;
    top: calc((0% - (100% - 1em)) - 8%);
    background-color: transparent;
  }

  .pretty-checkbox input:checked ~ .state.p-success label:after {
    background-color: currentColor !important;
  }

  .pretty-checkbox.p-svg input:checked ~ .state .svg {
    opacity: 1;
  }

  .pretty-checkbox.p-svg .state svg {
    margin: 0;
    width: 100%;
    height: 100%;
    text-align: center;
    display: -webkit-box;
    display: -ms-flexbox;
    display: flex;
    -webkit-box-flex: 1;
    -ms-flex: 1;
    flex: 1;
    -webkit-box-pack: center;
    -ms-flex-pack: center;
    justify-content: center;
    -webkit-box-align: center;
    -ms-flex-align: center;
    align-items: center;
    line-height: 1;
  }

  .pretty-checkbox.p-svg .state .svg {
    position: absolute;
    font-size: 1em;
    width: calc(1em + 2px);
    height: calc(1em + 2px);
    left: 0;
    z-index: 1;
    text-align: center;
    line-height: normal;
    top: calc((0% - (100% - 1em)) - 8%);
    border: 1px solid transparent;
    opacity: 0;
  }

  .pretty-checkbox .state label:before {
    border-color: #bdc3c7;
  }
</style>

<template>
  <div class="pretty-checkbox p-svg p-plain">
    <input type="checkbox" v-on="$listeners" v-bind="$attrs" :value="value" v-model="checkVal">
    <div class="state p-success">
      <svg class="svg svg-icon" viewBox="0 0 20 20">
        <path d="M7.629,14.566c0.125,0.125,0.291,0.188,0.456,0.188c0.164,0,0.329-0.062,0.456-0.188l8.219-8.221c0.252-0.252,0.252-0.659,0-0.911c-0.252-0.252-0.659-0.252-0.911,0l-7.764,7.763L4.152,9.267c-0.252-0.251-0.66-0.251-0.911,0c-0.252,0.252-0.252,0.66,0,0.911L7.629,14.566z" style="stroke: white;fill:white;"></path>
      </svg>
      <label v-bind:style="{ color: color }"><slot></slot></label>
    </div>
  </div>
</template>

<script>
  export default {
    inheritAttrs: false,

    props: {
      checked: null, // Passed in by v-model
      value: null,
      color: {
        type: String,
        default: '#337ab7',
      },
    },

    model: {
      prop: 'checked',
    },

    computed: {
      checkVal: {
        get() {
          return this.checked;
        },

        set(newVal) {
          this.$emit('input', newVal);
        },
      },
    },
  };
</script>
