import Vue from 'vue';

import WebhooksIndexPage from './pages/index';
import WebhooksShowPage from './pages/show';
import LegacyWebhookShowPage from './pages/legacy-show';

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

const WEBHOOK_SHOW_ROUTE = 'webhooks/show';

$(() => {
  const $body = $('body');
  const route = $body.data('route');

  if (route === WEBHOOK_SHOW_ROUTE) {
    // eslint-disable-next-line
    new LegacyWebhookShowPage($body);
  }
});
