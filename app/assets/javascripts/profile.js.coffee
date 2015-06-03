
jQuery ->
  email = $('#user_email').val()
  $('#user_email').keyup ->
    if $('#user_email').val() == email
      $('#edit_user.profile .btn').attr('disabled', 'disabled')
    else
      $('#edit_user.profile .btn').removeAttr('disabled')

  gravatar = $('#user_gravatar').is(':checked')
  $('#user_gravatar').click ->
    if $('#user_gravatar').is(':checked') == gravatar
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
