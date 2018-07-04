import Vue from 'vue';

import Result from '../components/result';

$(() => {
  if (!$('body[data-route="explore/index"]').length) {
    return;
  }

  // eslint-disable-next-line no-new
  new Vue({
    el: 'body[data-route="explore/index"] .vue-root',

    components: {
      Result,
    },
  });
});
