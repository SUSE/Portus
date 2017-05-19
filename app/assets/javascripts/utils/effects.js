// after jquery was upgraded this effect was conflicting
// with lifeitup functions (probably layout_resizer)
// so setTimeout was the workaround I found to solve the error
export const fadeIn = function ($el) {
  setTimeout(() => {
    $el.hide().fadeIn(1000);
  }, 0);
};

// openCloseIcon toggles the state of the given icon with the
// 'fa-pencil'/'fa-close' classes.
export const openCloseIcon = function (icon) {
  if (icon.hasClass('fa-close')) {
    icon.removeClass('fa-close');
    icon.addClass('fa-pencil');
  } else {
    icon.removeClass('fa-pencil');
    icon.addClass('fa-close');
  }
};

// refreshFloatAlertPosition updates the position of a floating alert on scroll.
export const refreshFloatAlertPosition = function () {
  var box = $('.float-alert');

  if ($(this).scrollTop() < 60) {
    box.css('top', (72 - $(this).scrollTop()) + 'px');
  }

  $(window).scroll(() => {
    if ($(this).scrollTop() > 60) {
      box.css('top', '12px');
    } else {
      box.css('top', (72 - $(this).scrollTop()) + 'px');
    }
  });
};

// setTimeoutAlertDelay sets up the delay for hiding an alert.
// IDEA: if alerts are put into a component, this hack will no longer be needed.
export const setTimeOutAlertDelay = function () {
  setTimeout(() => {
    $('.alert-hide').click();
  }, 4000);
};

export default {
  fadeIn,
  openCloseIcon,
  refreshFloatAlertPosition,
  setTimeOutAlertDelay,
};
