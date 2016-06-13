//change topbar background
function setTopbarBackground() {
  var welcome_height = $('#welcome').outerHeight();
  var topbar_height = $('#portus-header').outerHeight();
  if (!menu_open) {
    if ($(window).scrollTop() > welcome_height - topbar_height) {
      $("#portus-header").addClass("opaque");
      $("#mobile-menu").addClass("opaque");
    } else {
      $("#portus-header").removeClass("opaque");
      $("#mobile-menu").removeClass("opaque");
    }
  }
};
$(window).on('scroll', function() {
  setTopbarBackground();
});

// Set topbar opaque if the page haven't a welcome image
$(document).ready(function() {
    var welcome_height = $('#welcome').outerHeight();
    if (!welcome_height) {
        $("#portus-header").addClass("opaque");
        $("#mobile-menu").addClass("opaque");
    }
})

// Functions for the mobile version
$(document).on("click", '#open_main_menu', open_mobile_menu);
$("#mobile-menu").hide();
var menu_open = false
function open_mobile_menu () {
  var has_opaque = $("#portus-header").hasClass('opaque');
  if (menu_open) {
    menu_open = false
    $("#mobile-menu").removeClass('active');
    setTopbarBackground();
  } else {
    $("#mobile-menu").addClass('active');
    if (!has_opaque) {
      $("#portus-header").addClass("opaque");
    }
    menu_open = true;
  }
}
