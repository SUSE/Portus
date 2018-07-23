<template>
  <tr :class="scopeClass">
    <td>
      <a :href="repositoryUrl">{{ namespace.name }}</a>
    </td>
    <td>{{ namespace.repositories_count }}</td>
    <td v-if="namespace.permissions.webhooks">
      <a :href="webhooksUrl">{{ namespace.webhooks_count }}</a>
    </td>
    <td v-else>{{ namespace.webhooks_count }}</td>
    <td>
      <time :datetime="namespace.created_at">{{ createdAt }}</time>
    </td>
    <td>
      <namespace-visibility :namespace="namespace"></namespace-visibility>
    </td>
  </tr>
</template>

<script>
  import dayjs from 'dayjs';

  import NamespaceVisibility from './visibility';

  export default {
    props: ['namespace', 'namespacesPath', 'webhooksPath'],

    components: {
      NamespaceVisibility,
    },

    computed: {
      scopeClass() {
        return `namespace_${this.namespace.id}`;
      },

      repositoryUrl() {
        return `${this.namespacesPath}/${this.namespace.id}`;
      },

      webhooksUrl() {
        return `${this.repositoryUrl}/${this.webhooksPath}`;
      },

      createdAt() {
        return dayjs(this.namespace.created_at).format('MMMM DD, YYYY HH:mm');
      },
    },
  };
</script>
