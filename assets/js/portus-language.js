//*****************init i18n

var lang = new Lang('en');
//languages setup - please list here all new language packs
window.lang.dynamic('es', 'assets/js/langpack/es.json');

//change language on click
$(document).on("click", ".change-language", function() {
  var languageSelected = $(this).data('language-value');
  var languageString = $(this).html();
  $("body").fadeOut(300, function() {
    window.lang.change(languageSelected);
    $(".selected-language").html(languageString);
    $(this).fadeIn(300);
  });

  return false;
})
//*****************
