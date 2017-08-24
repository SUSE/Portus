import Vue from 'vue';

import ResultItem from '../components/result-item';

const { set } = Vue;

$(() => {
  if (!$('body[data-route="explore/index"]').length) {
    return;
  }

  // eslint-disable-next-line no-new
  new Vue({
    el: 'body[data-route="explore/index"] .vue-root',

    components: {
      ResultItem,
    },

    data() {
      return {
        repositories: [],
      };
    },

    mounted() {
      set(this, 'repositories', window.repositories);
    },
  });
});
