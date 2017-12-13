import Vue from 'vue';

import NamespacesIndexPage from './pages/index';
import NamespacesShowPage from './pages/show';

import TeamLink from './components/team-link';

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

      // repositories panel is not a component yet
      TeamLink,
    },
  });
});
