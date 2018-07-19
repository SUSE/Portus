<template>
  <tr :class="scopeClass">
    <td>
      <a :href="repositoryPath">{{ repository.name }}</a>
    </td>
    <td v-if="showNamespaces">
      <a :href="namespacePath">{{ repository.namespace.name }}</a>
    </td>
    <td>{{ repository.tags_count }}</td>
    <td>{{ updatedAt }}</td>
  </tr>
</template>

<script>
  import dayjs from 'dayjs';

  export default {
    template: '#js-repository-table-row-tmpl',

    props: ['repository', 'repositoriesPath', 'namespacesPath', 'showNamespaces'],

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
        return dayjs(this.repository.updated_at).format('MMMM DD, YYYY HH:mm');
      },
    },
  };
</script>
