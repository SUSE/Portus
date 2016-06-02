//change topbar background
$(window).on('scroll', function() {
  var welcome_height = $('#welcome').outerHeight();
  var topbar_height = $('#portus-header').outerHeight();

  if ($(window).scrollTop() > welcome_height - topbar_height) {
    $("#portus-header").addClass("opaque");
  } else {
    $("#portus-header").removeClass("opaque");
  }
})
