<template>
  <form id="new-team-form" class="form-horizontal collapse" role='form' ref="form" @submit.prevent="onSubmit" novalidate>
    <div class="form-group" :class="{ 'has-error': $v.team.name.$error }">
      <label class="control-label col-md-2" for="team_name">Name</label>
      <div class="col-md-7">
        <input type="text" id="team_name" name="team[name]" class="form-control" placeholder="New team's name" @input="$v.team.name.$touch()" v-model.trim="team.name" ref="firstField" required />
        <span class="help-block">
          <span v-if="!$v.team.name.required">Name can't be blank</span>
          <span v-if="!$v.team.name.available">Name is reserved or has already been taken</span>
        </span>
      </div>
    </div>
    <div class="form-group" v-if="isAdmin">
      <label class="control-label col-md-2" for="team_owner_id">Owner</label>
      <div class="col-md-7">
        <select name="team[owner_id]" id="team_owner_id" v-model="team.owner_id" class="form-control">
          <option :value="o.id" v-for="o in owners" :key="o.id">
            {{ o.username }}
          </option>
        </select>
      </div>
    </div>
    <div class="form-group">
      <label class="control-label col-md-2" for="team_description">Description</label>
      <div class="col-md-7">
        <textarea id="team_description" name="team[description]" class="form-control fixed-size" placeholder="A short description of your team" v-model="team.description"></textarea>
      </div>
    </div>
    <div class="form-group">
      <div class="col-md-offset-2 col-md-7">
        <button type="submit" class="btn btn-primary" :disabled="$v.$invalid">Save</button>
      </div>
    </div>
  </form>
</template>

<script>
  import Vue from 'vue';

  import { required, requiredIf } from 'vuelidate/lib/validators';

  import FormMixin from '~/shared/mixins/form';

  import { handleHttpResponseError } from '~/utils/http';

  import TeamsService from '../service';

  const { set } = Vue;

  export default {
    props: {
      currentUserId: Number,
      isAdmin: Boolean,
      owners: {
        type: Array,
        required: true,
      },
    },

    mixins: [FormMixin],

    data() {
      return {
        team: {
          name: '',
          owner_id: this.currentUserId,
        },
        timeout: {
          name: null,
        },
      };
    },

    methods: {
      onSubmit() {
        const params = { ...this.team };

        if (!this.isAdmin) {
          delete params.owner_id;
        }

        TeamsService.save(params).then((response) => {
          const team = response.data;

          this.toggleForm();
          this.$v.$reset();
          set(this, 'team', {
            name: '',
          });

          this.$bus.$emit('teamCreated', team);
          this.$alert.$show(`Team '${team.name}' was created successfully`);
        }).catch(handleHttpResponseError);
      },
    },

    validations: {
      team: {
        owner_id: {
          required: requiredIf(function () {
            return window.isAdmin;
          }),
        },

        name: {
          required,
          available(value) {
            clearTimeout(this.timeout.name);

            // required already taking care of this
            if (value === '') {
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
