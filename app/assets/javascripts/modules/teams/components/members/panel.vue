<template>
  <panel>
    <h5 slot="heading-left">
      <popover title="What's this?" trigger="hover-focus">
        <a tabindex="0">
          <i class="fa fa-info-circle"></i>
        </a>
        <template slot="popover">
          <p>There are three types of users inside of a team:<br><strong>Viewer:</strong> has read only access. Only pull operations are permitted.<br/><strong>Contributor:</strong> has read and write access. Both pull and push operations are permitted.<br/><strong>Owner:</strong> like
            'contributor', but can also manage the team.</p>
        </template>
      </popover>
      Members
    </h5>

    <toggle-link slot="heading-right" text="Add member" :state="state" state-key="membersFormVisible" class="toggle-link-new-member"></toggle-link>

    <div slot="body" class="table-responsive">
      <team-members-table :members="members" sort-by="display_name" :current-member="currentMember"></team-members-table>
    </div>
  </panel>
</template>

<script>
  import { Popover } from 'uiv';
  import TeamMembersTable from './table';

  export default {
    props: ['members', 'team', 'state', 'currentMember'],

    components: {
      TeamMembersTable,
      Popover,
    },
  };
</script>
