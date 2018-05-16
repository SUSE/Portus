import Vue from 'vue';

import WebhooksIndexPage from './pages/index';
import WebhooksShowPage from './pages/show';

$(() => {
  if (!$('body[data-controller="webhooks"]').length) {
    return;
  }

  // eslint-disable-next-line no-new
  new Vue({
    el: '.vue-root',

    components: {
      WebhooksIndexPage,
      WebhooksShowPage,
    },
  });
});
