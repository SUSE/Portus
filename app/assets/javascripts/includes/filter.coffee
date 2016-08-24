filter_input = exports ? this
filter_input.activateFilter = (input_selector = '#filter_input', form_selector = '#filter_form') ->
  $(input_selector).on 'keyup', ->
    $.get $(form_selector).attr('action'), $(form_selector).serializeArray(), null, 'script'
    return