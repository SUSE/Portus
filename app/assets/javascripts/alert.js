(function () {
  var float_alert = typeof exports !== 'undefined' && exports !== null ? exports : this;

  float_alert.refreshFloatAlertPosition = function () {
    var box = $('.float-alert');

    if ($(this).scrollTop() < 60) {
      box.css('top', (72 - $(this).scrollTop()) + 'px');
    }

    $(window).scroll(function scrollEvent() {
      if ($(this).scrollTop() > 60) {
        box.css('top', '12px');
      } else {
        box.css('top', (72 - $(this).scrollTop()) + 'px');
      }
    });
  };

  float_alert.setTimeOutAlertDelay = function () {
    setTimeout(function () {
      $('.alert-hide').click();
    }, 4000);
  };

  float_alert.setTimeOutAlertDelay();
}).call(this);
