/* eslint-disable max-len, vars-on-top */

// to render the layout correctly in every browser/screen
var alreadyResizing = false;
window.$ = window.jQuery;

window.layout_resizer = function layout_resizer() {
  alreadyResizing = true;

  var screenHeight = $(window).height();
  var headerHeight = $('header').outerHeight();
  var footerHeight = $('footer').outerHeight();
  var asideHeight = $('aside ul').outerHeight();
  var sectionHeight = $('section').outerHeight();


  if ((headerHeight + footerHeight + asideHeight) > screenHeight && asideHeight > sectionHeight) {
    $('.container-fluid').css({
      height: asideHeight + 'px',
    });
  } else if ((headerHeight + footerHeight + sectionHeight) > screenHeight && asideHeight < sectionHeight) {
    $('.container-fluid').css({
      height: sectionHeight + 'px',
    });
  } else {
    $('.container-fluid').css({
      height: screenHeight - headerHeight - footerHeight + 'px',
    });
  }

  alreadyResizing = false;
};

$(window).on('load', function () {
  layout_resizer();
});

$(window).on('resize', function () {
  layout_resizer();
});

$(document).bind('DOMSubtreeModified', function () {
  if (!alreadyResizing) {
    layout_resizer();
  }
});

// triger the function to resize and to get the images size when a panel has been displayed
$(document).on('shown.bs.tab', 'a[data-toggle="tab"]', function () {
  layout_resizer();
});

// BOOTSTRAP INITS
$(function () {
  if ($.fn.popover) {
    $('body').popover({
      selector: '[data-toggle="popover"]',
      trigger: 'focus',
    });
    // to destroy the popovers that are hidden
    $('[data-toggle="popover"]').on('hidden.bs.popover', function () {
      var popover = $('.popover').not('.in');
      if (popover) {
        popover.remove();
      }
    });
  }
});

// init tooltip
$(function () {
  if ($.fn.tooltip) {
    $('[data-toggle="tooltip"]').tooltip();
  }
});

// Hide alert box instead of closing it
$(document).on('click', '.alert-hide', function () {
  $(this).parent().parent().fadeOut();
});
