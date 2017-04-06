import Bloodhound from 'typeahead.js';

export default {
  set: function (url) {
    $('.remote .typeahead').typeahead('destroy');

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

    $('.remote .typeahead').typeahead({ highlight: true }, {
      displayKey: 'name',
      source: bloodhound.ttAdapter(),
    });
  },
};

// (function () {
//   var bloodhound;

//   this.set_typeahead = function (url) {
//     $('.remote .typeahead').typeahead('destroy');
//     bloodhound = new Bloodhound({
//       datumTokenizer: Bloodhound.tokenizers.obj.whitespace('name'),
//       queryTokenizer: Bloodhound.tokenizers.whitespace,
//       remote: {
//         cache: false,
//         url: url,
//         wildcard: '%QUERY',
//       },
//     });
//     bloodhound.initialize();
//     $('.remote .typeahead').typeahead({ highlight: true }, {
//       displayKey: 'name',
//       source: bloodhound.ttAdapter(),
//     });
//   };
// }).call(window);
