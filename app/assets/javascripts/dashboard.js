jQuery(function () {
  $('#starred a').on('click', function (e) {
    e.preventDefault();
    return $(this).tab('show');
  });

  $('#all a').on('click', function (e) {
    e.preventDefault();
    return $(this).tab('show');
  });

  return $('#personal a').on('click', function (e) {
    e.preventDefault();
    return $(this).tab('show');
  });
});
