<template>
  <table class="table no-margin">
    <colgroup>
      <col class="col-20">
      <col class="col-80">
    </colgroup>
    <tbody>
      <tr v-if="namespace.orphan">
        <th class="v-align-top">Team</th>
        <td>
          None (aka orphan)

          <popover title="What's this?" trigger="hover-focus">
            <a tabindex="0">
              <i class="fa fa-info-circle"></i>
            </a>
            <template slot="popover">
              <p>An orphan namespace is a namespace that was created automatically
                via background sync job because it previously existed in your registry when Portus was set up.</p>
            </template>
          </popover>
      </td>
      </tr>
      <tr v-if="!namespace.global && !namespace.team.hidden">
        <th class="v-align-top">Team</th>
        <td><a :href="teamHref">{{ namespace.team.name }}</a></td>
      </tr>
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
      <tr v-if="!!namespace.permissions.role">
        <th class="v-align-top">Webhooks</th>
        <td><a :href="webhooksPath">{{ namespace.webhooks_count }} (click to view)</a></td>
      </tr>
      <tr>
        <th class="v-align-top">Description</th>
        <td v-html="description"></td>
      </tr>
    </tbody>
  </table>
</template>

<script>
  import { Popover } from 'uiv';

  export default {
    props: {
      namespace: {
        type: Object,
      },
      teamsPath: {
        type: String,
      },
      webhooksPath: {
        type: String,
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

      teamHref() {
        return `${this.teamsPath}/${this.namespace.team.id}`;
      },
    },

    methods: {
      is(visibility) {
        return this.namespace.visibility === visibility;
      },
    },

    components: {
      Popover,
    },
  };
</script>
