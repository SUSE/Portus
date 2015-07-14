//reset the scroll to 0 (top of page)
$(window).on('beforeunload', function() {
  $(window).scrollTop(0);
});

//init WOW
wow = new WOW(
  {
    offset: 30
  }
)
wow.init();

$(window).bind('scroll',function(e) {
  dockerIntoPortu()
})

var dockerIntoPortu = function () {

  var element = $(".fixit-container");
  var scrolledTop = element.offset().top - $(window).scrollTop();

  //when the container reaches the top of the window, start the animations
  if (scrolledTop < 0 ) {

    $(".fixit-element").addClass('animated zoomOutDown')

  }
}
