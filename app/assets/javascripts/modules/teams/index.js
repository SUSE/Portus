import Vue from 'vue';

import TeamsIndexPage from './pages/index';

import './pages/show';

$(() => {
  if (!$('body[data-route="teams/index"]').length) {
    return;
  }

  // eslint-disable-next-line no-new
  new Vue({
    el: '.vue-root',

    components: {
      TeamsIndexPage,
    },
  });
});
