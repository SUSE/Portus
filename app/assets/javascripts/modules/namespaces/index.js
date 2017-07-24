import NamespacesIndexPage from './pages/index';
import NamespacesShowPage from './pages/show';

const NAMESPACES_INDEX_ROUTE = 'namespaces/index';
const NAMESPACES_SHOW_ROUTE = 'namespaces/show';

$(() => {
  const $body = $('body');
  const route = $body.data('route');

  if (route === NAMESPACES_INDEX_ROUTE) {
    // eslint-disable-next-line
    new NamespacesIndexPage($body);
  }

  if (route === NAMESPACES_SHOW_ROUTE) {
    // eslint-disable-next-line
    new NamespacesShowPage($body);
  }
});
