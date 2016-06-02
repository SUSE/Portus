//change topbar background
$(window).on('scroll', function() {
  var welcome_height = $('#welcome').outerHeight();
  var topbar_height = $('#portus-header').outerHeight();
  if ($(window).scrollTop() > welcome_height - topbar_height) {
    $("#portus-header").addClass("opaque");
    $("#mobile-menu").addClass("opaque");
  } else {
    $("#portus-header").removeClass("opaque");
    $("#mobile-menu").removeClass("opaque");
  }
})

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
  if (menu_open) {
    $("#mobile-menu").css({'opacity': '0'});
    menu_open = false
  } else {
    $("#mobile-menu").css({'opacity': '1'});
    menu_open = true;
  }
}