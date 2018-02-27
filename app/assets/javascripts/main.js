import Alert from '~/shared/components/alert';

import 'jquery-ujs';

// Bootstrap
import 'bootstrap/js/transition';
import 'bootstrap/js/tab';
import 'bootstrap/js/tooltip';
import 'bootstrap/js/popover';
import 'bootstrap/js/dropdown';
import 'bootstrap/js/button';
import 'bootstrap/js/collapse';

// Life it up
import 'vendor/lifeitup_layout';

import './bootstrap';
import './vue-shared';
import './polyfill';

// modules
import './modules/admin/registries';
import './modules/users';
import './modules/dashboard';
import './modules/explore';
import './modules/repositories';
import './modules/namespaces';
import './modules/teams';
import './modules/webhooks';

import { setTimeOutAlertDelay, refreshFloatAlertPosition } from './utils/effects';

// Actions to be done to initialize any page.
$(function () {
  // process scheduled alerts
  Alert.$process();

  refreshFloatAlertPosition();

  // necessary to be compatible with the js rendered
  // on the server-side via jquery-ujs
  window.setTimeOutAlertDelay = setTimeOutAlertDelay;
  window.refreshFloatAlertPosition = refreshFloatAlertPosition;
});
