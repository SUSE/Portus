
jQuery ->
  email = $('#user_email').val()
  $('#user_email').keyup ->
    val = $('#user_email').val()
    if val == email || val == ''
      $('#edit_user.profile .btn').attr('disabled', 'disabled')
    else
      $('#edit_user.profile .btn').removeAttr('disabled')

  $('#edit_user.password .form-control').keyup ->
    current = $('#user_current_password').val()
    password = $('#user_password').val()
    confirm = $('#user_password_confirmation').val()

    if current != '' && password != '' && confirm != '' && password == confirm
      $('#edit_user.password .btn').removeAttr('disabled')
    else
      $('#edit_user.password .btn').attr('disabled', 'disabled')
