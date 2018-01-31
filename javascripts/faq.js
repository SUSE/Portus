import 'bootstrap/js/collapse';

$(document).ready(function () {
  var parent;

  $('.collapse').collapse();

  $('.collapse').on('show.bs.collapse', function (sender) {
    parent = sender.target.previousElementSibling;
    parent.classList.add('active');
  });
  $('.collapse').on('hide.bs.collapse', function (sender) {
    parent = sender.target.previousElementSibling;
    parent.classList.remove('active');
  });
});
