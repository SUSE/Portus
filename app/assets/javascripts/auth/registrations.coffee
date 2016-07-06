$(document).on "page:change", ->
  $('#add_application_token_btn').on 'click', (event) ->
    $('#add_application_token_form').toggle 400, "swing", ->
      if $('#add_application_token_form').is(':visible')
        $('#add_application_token_btn i').addClass("fa-minus-circle")
        $('#add_application_token_btn i').removeClass("fa-plus-circle")
        $('#application_token_application').val("")
        $('#application_token_application').focus()
        layout_resizer()
      else
        $('#add_application_token_btn i').removeClass("fa-minus-circle")
        $('#add_application_token_btn i').addClass("fa-plus-circle")
        layout_resizer()

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
