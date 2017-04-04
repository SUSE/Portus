// setTypeahead sets up the typeahead plugin for the given url. This function
// also assumes that there is an element with the following selector
// ".remote .typeahead".
export const setTypeahead = function (url) {
  var bloodhound;

  $('.remote .typeahead').typeahead('destroy');
  bloodhound = new Bloodhound({
    datumTokenizer: Bloodhound.tokenizers.obj.whitespace('name'),
    queryTokenizer: Bloodhound.tokenizers.whitespace,
    remote: {
      cache: false,
      url: url,
      wildcard: '%QUERY',
    },
  });

  bloodhound.initialize();

  $('.remote .typeahead').typeahead({ highlight: true }, {
    displayKey: 'name',
    source: bloodhound.ttAdapter(),
  });
};

export default {
  setTypeahead,
};
