<template>
  <div class="panel panel-default">
    <div class="panel-heading">
      <div class="row">
        <div :class="headingLeftClass">
          <slot name="heading-left"></slot>
        </div>
        <div class="col-sm-6 text-right" v-if="hasHeadingRight">
          <slot name="heading-right"></slot>
        </div>
      </div>
    </div>

    <div class="panel-body" slot="body">
      <slot name="body"></slot>
    </div>

    <div class="panel-footer">
      <slot name="footer"></slot>
    </div>
  </div>
</template>

<script>
  export default {
    computed: {
      headingLeftClass() {
        if (this.hasHeadingRight) {
          return 'col-sm-6';
        }

        return 'col-sm-12';
      },

      hasHeadingRight() {
        return !!this.$slots['heading-right'];
      },
    },
  };
</script>
