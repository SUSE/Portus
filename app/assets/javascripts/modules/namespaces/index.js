import Vue from 'vue';

import NamespacesIndexPage from './pages/index';
import NamespacesShowPage from './pages/show';

$(() => {
  if (!$('body[data-controller="namespaces"]').length) {
    return;
  }

  // eslint-disable-next-line no-new
  new Vue({
    el: '.vue-root',

    components: {
      NamespacesIndexPage,
      NamespacesShowPage,
    },
  });
});
