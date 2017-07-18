import SearchComponent from './components/search';
import DashboardPage from './pages/dashboard';

const DASHBOARD_INDEX = 'dashboard/index';

$(() => {
  const $body = $('body');
  const route = $body.data('route');

  // Enable the search component globally if the HTML code is there.
  if ($('#search').length > 0) {
    // eslint-disable-next-line
    new SearchComponent($body);
  }

  if (route === DASHBOARD_INDEX) {
    // eslint-disable-next-line
    new DashboardPage($body);
  }
});
