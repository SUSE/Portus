filter_input = exports ? this
filter_input.activateFilter = (input_selector = '#filter_input', form_selector = '#filter_form', extra_data_selector = '') ->
  $(input_selector).on 'keyup', ->
    $.get $(form_selector).attr('action'), getFormData(form_selector, extra_data_selector), null, 'script'
    return

filter_input.getFormData = (form_selector = '#filter_form', extra_data_selector = '') ->
    data = $(form_selector).serializeArray()
    data = data.concat $(extra_data_selector).serializeArray()
    console.log data
    return data
