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
