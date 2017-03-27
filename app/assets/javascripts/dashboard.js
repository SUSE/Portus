jQuery(function ($) {
  $('#sidebar-tabs a').on('click', function (e) {
    e.preventDefault();
    $(this).tab('show');
  });
});
