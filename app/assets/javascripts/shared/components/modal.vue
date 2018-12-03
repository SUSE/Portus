<template>
  <transition name="modal-fade" @enter="enter">
    <div class="modal-background" tabindex="-1" role="dialog" @click.prevent="onClickToClose" @keydown="onKeydownToClose" ref="background">
      <div class="modal-dialog" role="document">
        <div class="modal-content">
          <div class="modal-header">
            <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true" ref="close">&times;</span></button>
            <slot name="title"></slot>
          </div>
          <div class="modal-body">
            <slot name="body"></slot>
          </div>
          <div class="modal-footer">
            <slot name="footer"></slot>
          </div>
        </div> <!-- /.modal-content -->
      </div> <!-- /.modal-dialog -->
    </div> <!-- /.modal-background -->
  </transition>
</template>

<script>
  import { KEY_ESCAPE } from 'keycode-js';

  export default {
    methods: {
      enter() {
        this.$emit('enter');
      },

      onKeydownToClose(e) {
        const inputFocused = document.activeElement.nodeName === 'INPUT';
        const isEscape = e.keyCode === KEY_ESCAPE;

        if (!isEscape || inputFocused) {
          return;
        }

        this.close();
      },

      onClickToClose(e) {
        if (e.target !== this.$refs.background
         && e.target !== this.$refs.close) {
          return;
        }
        this.close();
      },

      close() {
        this.$emit('close');
      },
    },
  };
</script>

<style scoped>
  .modal-background {
    position: fixed;
    top: 0;
    bottom: 0;
    left: 0;
    right: 0;
    background: rgba(0, 0, 0, 0.4);

    z-index: 200;
  }

  .modal-fade-enter,
  .modal-fade-leave-active {
    opacity: 0;
  }

  .modal-fade-enter-active,
  .modal-fade-leave-active {
    transition: opacity .5s ease
  }
</style>
