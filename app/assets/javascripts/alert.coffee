float_alert = exports ? this
float_alert.refreshFloatAlertPosition = ->
  box = $('.float-alert')
  top = box.css('top')
  if $(this).scrollTop() < 60
    box.css('top', 72 - $(this).scrollTop() + 'px')

  $(window).scroll ->
    if $(this).scrollTop() > 60
      # box.stop().animate { 'top': '12px' }, 70
      box.css('top', 12 + 'px')
    else
      box.css('top', 72 - $(this).scrollTop() + 'px')
      # box.stop().animate { 'top': top }, 70
    return
  return

float_alert.setTimeOutAlertDelay = ->
  setTimeout ->
    $(".alert-hide").click()
  , 4000

float_alert.setTimeOutAlertDelay()
