import Vue from 'vue';

import RepositoriesIndexPage from './pages/index';
import RepositoriesShowPage from './pages/show';

$(() => {
  if (!$('body[data-controller="repositories"]').length) {
    return;
  }

  // eslint-disable-next-line no-new
  new Vue({
    el: '.vue-root',

    components: {
      RepositoriesIndexPage,
      RepositoriesShowPage,
    },
  });
});
