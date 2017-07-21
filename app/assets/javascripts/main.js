import 'jquery';
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

import './vue-shared';

// Require tree.
// NOTE: This should be moved into proper modules.
import './bootstrap';
import './namespaces';
import './repositories';
import './teams';

// new modules structure
import './modules/users';
import './modules/dashboard';
import './modules/repositories';

import { setTimeOutAlertDelay, refreshFloatAlertPosition } from './utils/effects';

// Actions to be done to initialize any page.
$(function () {
  refreshFloatAlertPosition();

  // necessary to be compatible with the js rendered
  // on the server-side via jquery-ujs
  window.setTimeOutAlertDelay = setTimeOutAlertDelay;
  window.refreshFloatAlertPosition = refreshFloatAlertPosition;
});
