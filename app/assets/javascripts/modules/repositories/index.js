import Vue from 'vue';

import RepositoriesIndexPage from './pages/index';

import './pages/show';

$(() => {
  if (!$('body[data-route="repositories/index"]').length) {
    return;
  }

  // eslint-disable-next-line no-new
  new Vue({
    el: '.vue-root',

    components: {
      RepositoriesIndexPage,
    },
  });
});
