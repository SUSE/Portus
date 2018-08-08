<template>
  <panel>
    <h5 slot="heading-left">
      <a data-placement="right"
        data-toggle="popover"
        data-container=".panel-heading"
        data-content="<p>Information about the team.</p>"
        data-original-title="What's this?"
        tabindex="0" data-html="true">
        <i class="fa fa-info-circle"></i>
      </a>
      <strong class="team-name"> {{ team.name }} </strong>
      team
    </h5>

    <div slot="heading-right" v-if="team.updatable">
      <toggle-link text="Edit team" :state="state" state-key="editFormVisible" class="toggle-link-edit-team" true-icon="fa-close" false-icon="fa-pencil"></toggle-link>
    </div>

    <div slot="body">
      <team-info :team="team" v-if="!state.editFormVisible"></team-info>
      <team-edit-form :team="team" :visible="state.editFormVisible" v-else></team-edit-form>
    </div>

  </panel>
</template>

<script>
  import TeamEditForm from './edit-form';
  import TeamInfo from './info';

  export default {
    props: {
      team: {
        type: Object,
      },
      state: {
        type: Object,
      },
    },

    components: {
      TeamEditForm,
      TeamInfo,
    },
  };
</script>
