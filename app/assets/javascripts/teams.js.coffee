$(document).on "page:change", ->
  $('#add_team_user_btn').on 'click', (event) =>
    $('#team_user_user').val('')
    $('#team_user_role').val('viewer')
    $('#add_team_user_form').toggle 400, "swing", ->
      if $('#add_team_user_form').is(':visible')
        $('#add_team_user_btn i').addClass("fa-chevron-up")
        $('#add_team_user_btn i').removeClass("fa-chevron-down")
        $('#team_user_user').focus()
      else
        $('#add_team_user_btn i').removeClass("fa-chevron-up")
        $('#add_team_user_btn i').addClass("fa-chevron-down")

  for btn_edit_role in $(".btn-edit-role")
    $(btn_edit_role).on 'click', (event) =>
      $('#team_user_' + event.currentTarget.value + ' td .role').toggle()
      $('#change_role_team_user_' + event.currentTarget.value).toggle()

  $('#add_namespace_btn').on 'click', (event) =>
    $('#namespace_namespace').val('')
    $('#add_namespace_form').toggle 400, "swing", ->
      if $('#add_namespace_form').is(':visible')
        $('#add_namespace_btn i').addClass("fa-chevron-up")
        $('#add_namespace_btn i').removeClass("fa-chevron-down")
        $('#namespace_namespace').focus()
      else
        $('#add_namespace_btn i').removeClass("fa-chevron-up")
        $('#add_namespace_btn i').addClass("fa-chevron-down")

  $('#add_team_btn').on 'click', (event) =>
    $('#team_name').val('')
    $('#add_team_form').toggle 400, "swing", ->
      if $('#add_team_form').is(':visible')
        $('#add_team_btn i').addClass("fa-chevron-up")
        $('#add_team_btn i').removeClass("fa-chevron-down")
        $('#team_name').focus()
      else
        $('#add_team_btn i').removeClass("fa-chevron-up")
        $('#add_team_btn i').addClass("fa-chevron-down")
