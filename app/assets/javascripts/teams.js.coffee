$(document).on "page:change", ->
  $('#add_team_user_btn').on 'click', (event) =>
    $('#add_team_user_form').fadeToggle 400, "swing", ->
      if $('#add_team_user_form').css("display") == "block"
        $('#add_team_user_btn i').addClass("fa-chevron-up")
        $('#add_team_user_btn i').removeClass("fa-chevron-down")
      else
        $('#add_team_user_btn i').removeClass("fa-chevron-up")
        $('#add_team_user_btn i').addClass("fa-chevron-down")

  for btn_edit_role in $(".btn-edit-role")
    $(btn_edit_role).on 'click', (event) =>
      $('#change_role_team_user_' + event.currentTarget.value).fadeToggle()
