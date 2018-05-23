<template>
  <table class="table no-margin">
    <colgroup>
      <col class="col-20">
      <col class="col-80">
    </colgroup>
    <tbody>
      <tr>
        <th>Visibility</th>
        <td v-if="is('private')" :title="privateTitle" class="visibility-info">
          <i class="fa fa-fw fa-lock" ></i> Private
        </td>
        <td v-if="is('protected')" title="Logged-in users can pull images from this namespace"  class="visibility-info">
          <i class="fa fa-fw fa-lock" ></i> Protected
        </td>
        <td v-if="is('public')" title="Anyone can pull images from this namespace"  class="visibility-info">
          <i class="fa fa-fw fa-lock" ></i> Public
        </td>
      </tr>
      <tr>
        <th class="v-align-top">Description</th>
        <td v-html="description"></td>
      </tr>
    </tbody>
  </table>
</template>

<script>
  export default {
    props: {
      namespace: {
        type: Object,
      },
    },

    computed: {
      description() {
        if (!this.namespace.description) {
          return 'No description has been posted yet';
        }

        return this.namespace.description_md;
      },

      privateTitle() {
        if (this.isGlobal) {
          return 'The global namespace cannot be private';
        }

        return 'Team members can pull images from this namespace';
      },
    },

    methods: {
      is(visibility) {
        return this.namespace.visibility === visibility;
      },
    },
  };
</script>
