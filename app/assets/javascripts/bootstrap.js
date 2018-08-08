import Vue from 'vue';

import dayjs from 'dayjs';
import relativeTime from 'dayjs/plugin/relativeTime';

import Alert from './utils/alert';

import { setTimeOutAlertDelay, refreshFloatAlertPosition } from './utils/effects';

dayjs.extend(relativeTime);

$(function () {
  // this is a fallback to always instantiate a vue instance
  // useful for isolated shared components like <sign-out-btn>
  // eslint-disable-next-line no-underscore-dangle
  if (!$('.vue-root')[0].__vue__) {
    // eslint-disable-next-line no-new
    new Vue({ el: '.vue-root' });
  }

  if ($.fn.popover) {
    $('a[rel~=popover], .has-popover').popover();
  }

  if ($.fn.tooltip) {
    $('a[rel~=tooltip], .has-tooltip').tooltip();
  }

  $('.alert .close').on('click', function () { $(this).closest('.alert-wrapper').fadeOut(); });

  // process scheduled alerts
  Alert.$process();

  refreshFloatAlertPosition();

  // disable effects during tests
  $.fx.off = $('body').data('disable-effects');
});

// necessary to be compatible with the js rendered
// on the server-side via jquery-ujs
window.setTimeOutAlertDelay = setTimeOutAlertDelay;
window.refreshFloatAlertPosition = refreshFloatAlertPosition;

// we are not a SPA and when user clicks on back/forward
// we want the page to be fully reloaded to take advantage of
// the url query params state
window.onpopstate = function (e) {
  // phantomjs seems to trigger an oppopstate event
  // when visiting pages, e.state is always null and
  // in our component we set an empty string
  if (e.state !== null) {
    window.location.reload();
  }
};

Vue.config.productionTip = process.env.NODE_ENV !== 'production';
