$(document).on "page:change", ->
  set_typeahead = (url) ->
    $('.remote .typeahead').typeahead 'destroy'
    bloodhound = new Bloodhound(
        datumTokenizer: Bloodhound.tokenizers.obj.whitespace('name'),
        queryTokenizer: Bloodhound.tokenizers.whitespace,
        remote:
          cache: false,
          url: url,
          wildcard: '%QUERY'
      )
    bloodhound.initialize()
    $('.remote .typeahead').typeahead null,
      displayKey: 'name',
      source: bloodhound.ttAdapter()

  $('#edit_namespace').on 'click', (event) ->
    set_typeahead('/teams/typeahead/%QUERY')

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
    team_id = $('.remote').attr('id')
    set_typeahead(team_id  +  '/typeahead/%QUERY')

  open_close_icon = (icon) ->
    if icon.hasClass('fa-close')
      icon.removeClass('fa-close')
      icon.addClass('fa-pencil')
    else
      icon.removeClass('fa-pencil')
      icon.addClass('fa-close')

  $('body').on('click', '.btn-edit-role', (event) ->
    el = $(this).find('i.fa')
    if $(this).hasClass('add')
      open_close_icon(el)
      $('#team_user_' + event.currentTarget.value + ' td .role').toggle()
      $('#change_role_team_user_' + event.currentTarget.value).toggle()
    else if $(this).hasClass('button_edit_team')
      $('.team_information').toggle()
      $('#update_team_' + event.currentTarget.value).toggle()
      $('#team_name').focus()
    else if $(this).hasClass('button_namespace_description')
      open_close_icon(el)
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
    set_typeahead('/namespaces/typeahead/%QUERY')

  $('#add_webhook_btn').unbind('click').on 'click', (event) ->
    $('#webhook_url').val('')
    $('#webhook_username').val('')
    $('#webhook_password').val('')

    $('#add_webhook_form').toggle 400, "swing", ->
      if $('#add_webhook_form').is(':visible')
        $('#add_webhook_btn i').addClass("fa-minus-circle")
        $('#add_webhook_btn i').removeClass("fa-plus-circle")
        $('#webhook_url').focus()
        layout_resizer()
      else
        $('#add_webhook_btn i').removeClass("fa-minus-circle")
        $('#add_webhook_btn i').addClass("fa-plus-circle")
        layout_resizer()

  $('body').on('click', '.btn-edit-webhook', (event) ->
    el = $(this).find('i.fa')
    if $(this).hasClass('button_edit_webhook')
      $('.webhook_information').toggle()
      $('#update_webhook_' + event.currentTarget.value).toggle()
      $('#webhook_url').focus()
      layout_resizer()
  )

  $('#add_webhook_header_btn').unbind('click').on 'click', (event) ->
    $('#webhook_header_name').val('')
    $('#webhook_header_value').val('')

    $('#add_webhook_header_form').toggle 400, "swing", ->
      if $('#add_webhook_header_form').is(':visible')
        $('#add_webhook_header_btn i').addClass("fa-minus-circle")
        $('#add_webhook_header_btn i').removeClass("fa-plus-circle")
        $('#webhook_header_name').focus()
        layout_resizer()
      else
        $('#add_webhook_header_btn i').removeClass("fa-minus-circle")
        $('#add_webhook_header_btn i').addClass("fa-plus-circle")
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
