set_typehead = exports ? this
set_typehead.set_typeahead = (url) ->
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