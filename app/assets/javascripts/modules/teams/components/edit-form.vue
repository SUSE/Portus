<template>
  <form id="edit-team-form" role='form' ref="form" @submit.prevent="onSubmit" novalidate>
    <div class="form-group" :class="{ 'has-error': $v.teamCopy.name.$error }">
      <label class="control-label" for="team_name">Name</label>
      <input type="text" id="team_name" name="team[name]" class="form-control" placeholder="Team's name" @input="$v.teamCopy.name.$touch()" v-model.trim="teamCopy.name" required />
      <span class="help-block">
        <span v-if="!$v.teamCopy.name.required">Name can't be blank</span>
        <span v-if="!$v.teamCopy.name.available">Name is reserved or has already been taken</span>
      </span>
    </div>
    <div class="form-group">
      <label class="control-label" for="team_description">Description</label>
      <textarea id="team_description" name="team[description]" class="form-control fixed-size" placeholder="A short description of your team" v-model="teamCopy.description"></textarea>
    </div>
    <div class="form-group">
      <button type="submit" class="btn btn-primary" :disabled="$v.$invalid">Save</button>
    </div>
  </form>
</template>

<script>
  import Vue from 'vue';

  import { required } from 'vuelidate/lib/validators';

  import { handleHttpResponseError } from '~/utils/http';

  import TeamsService from '../service';

  const { set } = Vue;

  export default {
    props: ['team', 'visible'],

    data() {
      return {
        teamCopy: {},
        timeout: {
          name: null,
        },
      };
    },

    methods: {
      onSubmit() {
        TeamsService.update(this.teamCopy).then((response) => {
          const team = response.data;

          this.$bus.$emit('teamUpdated', team);
          this.$alert.$show(`Team '${team.name}' was updated successfully`);
        }).catch(handleHttpResponseError);
      },

      copyOriginal() {
        set(this, 'teamCopy', { ...this.team });
      },
    },

    watch: {
      visible: {
        handler: 'copyOriginal',
        immediate: true,
      },
    },

    validations: {
      teamCopy: {
        name: {
          required,
          available(value) {
            clearTimeout(this.timeout.name);

            // required already taking care of this
            if (value === '' || value === this.team.name) {
              return true;
            }

            return new Promise((resolve) => {
              const searchTeam = () => {
                const promise = TeamsService.exists(value, { unscoped: true });

                promise.then((exists) => {
                  // leave it for the back-end
                  if (exists === null) {
                    resolve(true);
                  }

                  // if it doesn't exist, valid
                  resolve(!exists);
                });
              };

              this.timeout.name = setTimeout(searchTeam, 1000);
            });
          },
        },
      },
    },
  };
</script>
