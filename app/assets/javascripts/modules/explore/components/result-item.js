import moment from 'moment';

import Tag from '~/modules/repositories/components/tag';

export default {
  template: '#js-result-item-tmpl',

  props: ['repository'],

  components: {
    Tag,
  },

  computed: {
    updatedAt() {
      return moment(this.repository.updated_at).fromNow();
    },
  },
};
