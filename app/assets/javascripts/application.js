import 'jquery';
import 'jquery-ujs';

// Bootstrap
import 'bootstrap/js/transition';
import 'bootstrap/js/tab';
import 'bootstrap/js/tooltip';
import 'bootstrap/js/popover';

// Life it up
import 'vendor/lifeitup_layout';

import './vue_shared';

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
  setTimeOutAlertDelay();
  refreshFloatAlertPosition();
});
