import Vue from 'vue';

import dayjs from 'dayjs';
import relativeTime from 'dayjs/plugin/relativeTime';

import Alert from './shared/components/alert';

import { setTimeOutAlertDelay, refreshFloatAlertPosition } from './utils/effects';

dayjs.extend(relativeTime);

$(function () {
  if ($.fn.popover) {
    $('a[rel~=popover], .has-popover').popover();
  }

  if ($.fn.tooltip) {
    $('a[rel~=tooltip], .has-tooltip').tooltip();
  }

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
