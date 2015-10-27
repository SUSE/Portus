$(document).on "page:change", ->
  $('#add_team_user_btn').on 'click', (event) ->
    $('#team_user_user').val('')
    $('#team_user_role').val('viewer')
    $('#add_team_user_form').toggle 400, "swing", ->
      if $('#add_team_user_form').is(':visible')
        $('#add_team_user_btn i').addClass("fa-minus-circle")
        $('#add_team_user_btn i').removeClass("fa-plus-circle")
        $('#team_user_user').focus()
        layout_resizer()
      else
        $('#add_team_user_btn i').removeClass("fa-minus-circle")
        $('#add_team_user_btn i').addClass("fa-plus-circle")
        layout_resizer()

  $('body').on('click', '.btn-edit-role', (event) ->
    el = $(this).find('i.fa')
    if el.hasClass('fa-pencil')
      el.removeClass('fa-pencil')
      el.addClass('fa-close')
    else
      el.removeClass('fa-close')
      el.addClass('fa-pencil')
    if $(this).hasClass('add')
      $('#team_user_' + event.currentTarget.value + ' td .role').toggle()
      $('#change_role_team_user_' + event.currentTarget.value).toggle()
    else if $(this).hasClass('button_team_description')
      $('.description').toggle()
      $('#change_description_team_' + event.currentTarget.value).toggle()
    else if $(this).hasClass('button_namespace_description')
      $('.description').toggle()
      $('#change_description_namespace_' + event.currentTarget.value).toggle()
  )

  $('#add_namespace_btn').unbind('click').on 'click', (event) ->
    $('#namespace_namespace').val('')

    # When we are creating this on the namespaces page.
    if $('#namespace_team') && $('#namespace_team').is(':visible')
      $('#namespace_team').val('')
      $('#namespace_description').val('')

    $('#add_namespace_form').toggle 400, "swing", ->
      if $('#add_namespace_form').is(':visible')
        $('#add_namespace_btn i').addClass("fa-minus-circle")
        $('#add_namespace_btn i').removeClass("fa-plus-circle")
        $('#namespace_namespace').focus()
        layout_resizer()
      else
        $('#add_namespace_btn i').removeClass("fa-minus-circle")
        $('#add_namespace_btn i').addClass("fa-plus-circle")
        layout_resizer()

  $('#add_team_btn').on 'click', (event) ->
    $('#team_name').val('')
    $('#add_team_form').toggle 400, "swing", ->
      if $('#add_team_form').is(':visible')
        $('#add_team_btn i').addClass("fa-minus-circle")
        $('#add_team_btn i').removeClass("fa-plus-circle")
        $('#team_name').focus()
        layout_resizer()
      else
        $('#add_team_btn i').removeClass("fa-minus-circle")
        $('#add_team_btn i').addClass("fa-plus-circle")
        layout_resizer()
