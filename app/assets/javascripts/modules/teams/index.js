import TeamsShowPage from './pages/show';

const TEAMS_SHOW_ROUTE = 'teams/show';

$(() => {
  const $body = $('body');
  const route = $body.data('route');

  if (route === TEAMS_SHOW_ROUTE) {
    // eslint-disable-next-line
    new TeamsShowPage($body);
  }
});
