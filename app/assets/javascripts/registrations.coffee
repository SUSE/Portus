$(document).on "page:change", ->
  $('#add_application_token_btn').on 'click', (event) ->
      $('#add_application_token_form').toggle 400, "swing", ->
        if $('#add_application_token_form').is(':visible')
          $('#add_team_btn i').addClass("fa-minus-circle")
          $('#add_team_btn i').removeClass("fa-plus-circle")
          $('#team_name').focus()
          layout_resizer()
        else
          $('#add_team_btn i').removeClass("fa-minus-circle")
          $('#add_team_btn i').addClass("fa-plus-circle")
          layout_resizer()
