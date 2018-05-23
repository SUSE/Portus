<template>
  <table class="table no-margin">
    <colgroup>
      <col class="col-20">
      <col class="col-80">
    </colgroup>
    <tbody>
      <tr>
        <th>URL</th>
        <td>{{ webhook.url }}</td>
      </tr>
      <tr>
        <th>Request method</th>
        <td>{{ webhook.request_method }}</td>
      </tr>
      <tr>
        <th>Content type</th>
        <td>{{ webhook.content_type }}</td>
      </tr>
      <tr>
        <th>Username</th>
        <td>{{ username }}</td>
      </tr>
      <tr>
        <th>Password</th>
        <td>{{ password }}</td>
      </tr>
      <tr>
        <th>Status</th>
        <td>{{ status }}</td>
      </tr>
    </tbody>
  </table>
</template>

<script>
  export default {
    props: {
      webhook: {
        type: Object,
      },
    },

    computed: {
      username() {
        if (this.webhook.username) {
          return this.webhook.username;
        }

        return '—';
      },

      password() {
        if (this.webhook.password) {
          return '********';
        }

        return '—';
      },

      status() {
        if (this.webhook.enabled) {
          return 'Enabled';
        }

        return 'Disabled';
      },
    },
  };
</script>
