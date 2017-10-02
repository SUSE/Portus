import moment from 'moment';

export default {
  template: '#js-repository-table-row-tmpl',

  props: ['repository', 'repositoriesPath', 'namespacesPath'],

  computed: {
    scopeClass() {
      return `repository_${this.repository.id}`;
    },

    repositoryPath() {
      return `${this.repositoriesPath}/${this.repository.id}`;
    },

    namespacePath() {
      return `${this.namespacesPath}/${this.repository.namespace.id}`;
    },

    updatedAt() {
      return moment(this.repository.updated_at).format('MMMM DD, YYYY HH:mm');
    },
  },
};
