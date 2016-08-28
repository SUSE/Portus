open_close_icon = exports ? this
open_close_icon.open_close_icon = (icon) ->
    if icon.hasClass('fa-close')
      icon.removeClass('fa-close')
      icon.addClass('fa-pencil')
    else
      icon.removeClass('fa-pencil')
      icon.addClass('fa-close')