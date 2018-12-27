import Vue from 'vue';

import TagsShowPage from './pages/show';

$(() => {
  if (!$('body[data-controller="tags"]').length) {
    return;
  }

  // eslint-disable-next-line no-new
  new Vue({
    el: '.vue-root',

    components: {
      TagsShowPage,
    },
  });
});
