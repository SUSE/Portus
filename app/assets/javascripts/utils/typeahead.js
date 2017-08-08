import Bloodhound from 'typeahead.js';

export const setTypeahead = function (el, url) {
  $(el).typeahead('destroy');

  const bloodhound = new Bloodhound({
    datumTokenizer: Bloodhound.tokenizers.obj.whitespace('name'),
    queryTokenizer: Bloodhound.tokenizers.whitespace,
    remote: {
      cache: false,
      url: url,
      wildcard: '%QUERY',
    },
  });
  bloodhound.initialize();

  return $(el).typeahead({ highlight: true }, {
    displayKey: 'name',
    source: bloodhound.ttAdapter(),
  });
};

export default {
  setTypeahead,
};
