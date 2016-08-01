#search
$ ->
  #define the initial array
  keypressed = undefined
  crtl = 17
  space = 32
  keys = [
    {
      'key': crtl
      'v': false
    }
    {
      'key': space
      'v': false
    }
  ]

  searchKey = (k, b) ->
    $.each keys, (i) ->
      if keys[i].key == k
        keys[i].v = b
      return
    activateSearch()
    return

  activateSearch = ->
    performSearch = 0
    $.each keys, (i) ->
      if keys[i].v == true
        performSearch++
      if performSearch > 1
        openSearch()
      return
    return

  openSearch = ->
    if $(window).scrollTop() > 0
      $('html,body').unbind().animate { scrollTop: 0 }, 500
    $('.search-field').val('').focus()
    return

  $(document).on 'keydown', (e) ->
    if e.keyCode == crtl or e.keyCode == space
      #if crtl is currently pressed, the spacebar default action wont be triggered
      if keys[0].v
        e.preventDefault()
      keypressed = e.keyCode
      searchKey keypressed, true
    return
  $(document).on 'keyup', (e) ->
    if e.keyCode == crtl or e.keyCode == space
      keypressed = e.keyCode
      searchKey keypressed, false
    return
  return
