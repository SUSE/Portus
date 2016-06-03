
jQuery ->
  email = $('#user_email').val()
  display = $('#user_display_name').val()

  $('#user_email').keyup ->
    val = $('#user_email').val()
    dname = $('#user_display_name').val()

    if dname == display && (val == email || val == '')
      $('#edit_user.profile .btn').attr('disabled', 'disabled')
    else
      $('#edit_user.profile .btn').removeAttr('disabled')

  $('#user_display_name').keyup ->
    val = $('#user_display_name').val()
    em = $('#user_email').val()

    if val == display && (em == email || em == '')
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
