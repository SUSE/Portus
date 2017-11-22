/* eslint-disable no-shadow */
import Vue from 'vue';

const bus = new Vue();

export default function install(Vue) {
  Object.defineProperties(Vue.prototype, {
    $bus: {
      get() {
        return bus;
      },
    },
  });
}
