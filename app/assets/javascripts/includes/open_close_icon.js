(function () {
  var open_close_icon = typeof exports !== 'undefined' && exports !== null ? exports : this;

  open_close_icon.open_close_icon = function (icon) {
    if (icon.hasClass('fa-close')) {
      icon.removeClass('fa-close');
      icon.addClass('fa-pencil');
    } else {
      icon.removeClass('fa-pencil');
      icon.addClass('fa-close');
    }
  };
}).call(this);
