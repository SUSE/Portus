$(document).on('click', '.smoothScroll', function(){
  var target = $(this).data("linkto");
  var top = $("#"+target).offset().top - 20 //20 would be a padding so the titles are still visible
  if (target.length) {
    $('html,body').animate({
      scrollTop: top
    }, 1000);
    return false;
  }
})
