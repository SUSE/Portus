//Jquery to give the final touches to Portus layout

//search form in header
$(document).on('ready', function() {
  openSearchForm();
});

function openSearchForm () {
  $('.header-open-search').on('click', function () {
    $(this).fadeOut('300', function() {
      $(this).remove();
    });
    $('.header-search-form .btn-default').show('slow');
    $('.search-field').show('slow').focus();
  });
}
