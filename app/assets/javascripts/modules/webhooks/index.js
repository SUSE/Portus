import WebhookShowPage from './pages/show';
import WebhooksIndexPage from './pages/index';

const WEBHOOK_SHOW_ROUTE = 'webhooks/show';
const WEBHOOK_INDEX_ROUTE = 'webhooks/index';

$(() => {
  const $body = $('body');
  const route = $body.data('route');

  if (route === WEBHOOK_SHOW_ROUTE) {
    // eslint-disable-next-line
    new WebhookShowPage($body);
  }

  if (route === WEBHOOK_INDEX_ROUTE) {
     // eslint-disable-next-line
      new WebhooksIndexPage($body);
  }
});
