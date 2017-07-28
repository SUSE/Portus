import TeamsShowPage from './pages/show';
import TeamsIndexPage from './pages/index';

const TEAMS_SHOW_ROUTE = 'teams/show';
const TEAMS_INDEX_ROUTE = 'teams/index';

$(() => {
  const $body = $('body');
  const route = $body.data('route');

  if (route === TEAMS_SHOW_ROUTE) {
    // eslint-disable-next-line
    new TeamsShowPage($body);
  }

  if (route === TEAMS_INDEX_ROUTE) {
    // eslint-disable-next-line
    new TeamsIndexPage($body);
  }
});
