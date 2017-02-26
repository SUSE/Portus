/* global layout_resizer */

jQuery(function ($) {
  var email = $('#user_email').val();
  var display = $('#user_display_name').val();

  $('#user_email').keyup(function () {
    var val = $('#user_email').val();
    var dname = $('#user_display_name').val();

    if (dname === display && (val === email || val === '')) {
      $('#edit_user.profile .btn').attr('disabled', 'disabled');
    } else {
      $('#edit_user.profile .btn').removeAttr('disabled');
    }
  });

  $('#user_display_name').keyup(function () {
    var val = $('#user_display_name').val();
    var em = $('#user_email').val();

    if (val === display && (em === email || em === '')) {
      $('#edit_user.profile .btn').attr('disabled', 'disabled');
    } else {
      $('#edit_user.profile .btn').removeAttr('disabled');
    }
  });

  $('#edit_user.password .form-control').keyup(function () {
    var current = $('#user_current_password').val();
    var password = $('#user_password').val();
    var confirm = $('#user_password_confirmation').val();

    if (current !== '' && password !== '' && confirm !== '' && password === confirm) {
      $('#edit_user.password .btn').removeAttr('disabled');
    } else {
      $('#edit_user.password .btn').attr('disabled', 'disabled');
    }
  });

  $('#add_application_token_btn').on('click', function (_event) {
    $('#add_application_token_form').toggle(400, 'swing', function () {
      if ($('#add_application_token_form').is(':visible')) {
        $('#add_application_token_btn i').addClass('fa-minus-circle');
        $('#add_application_token_btn i').removeClass('fa-plus-circle');
        $('#application_token_application').val('');
        $('#application_token_application').focus();
      } else {
        $('#add_application_token_btn i').removeClass('fa-minus-circle');
        $('#add_application_token_btn i').addClass('fa-plus-circle');
      }
      layout_resizer();
    });
  });
});
