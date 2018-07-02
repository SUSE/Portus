<template>
  <tr :class="scopeClass">
    <td class="table-icon">
      <i class="fa fa-lg" :class="teamIcon"></i>
    </td>
    <td>
      <a :href="teamPath">{{ team.name }}</a>
    </td>
    <td>{{ team.role }}</td>
    <td>{{ team.users_count }}</td>
    <td>{{ team.namespaces_count }}</td>
  </tr>
</template>

<script>
  export default {
    props: ['team', 'teamsPath'],

    computed: {
      scopeClass() {
        return `team_${this.team.id}`;
      },

      teamIcon() {
        if (this.team.users_count > 1) {
          return 'fa-users';
        }
        return 'fa-user';
      },

      teamPath() {
        return `${this.teamsPath}/${this.team.id}`;
      },
    },
  };
</script>
