<template>
  <form id="new-namespace-form" class="form-horizontal collapse" role="form" name="form" ref="form" @submit.prevent="onSubmit" novalidate>
    <input type="hidden" name="namespace[team]" v-model="namespace.team" v-if="teamName" />

    <div class="form-group" :class="{ 'has-error': $v.namespace.name.$error }">
      <label class="control-label col-md-2" for="namespace_name">Name</label>
      <div class="col-md-7">
        <input type="text" name="namespace[name]" id="namespace_name" class="form-control" placeholder="New namespace's name" ref="firstField" @input="$v.namespace.name.$touch()" v-model.trim="namespace.name" />
        <span class="help-block">
          <span v-if="!$v.namespace.name.required">Name can't be blank</span>
          <span class="error-messages" v-if="errors.name && errors.name.length">
            <span class="error-message" v-for="(error, index) in errors.name" :key="index">
              Name {{ error }}
            </span>
          </span>
        </span>
      </div>
    </div>
    <div class="form-group has-feedback" :class="{ 'has-error': $v.namespace.team.$error }" v-if="!teamName">
      <label class="control-label col-md-2" for="namespace_team">Team</label>
      <div class="col-md-7">
        <vue-multiselect
          class="namespace_team"
          :class="{'multiselect--selected': selectedTeam != null}"
          v-model="selectedTeam"
          label="name"
          track-by="name"
          placeholder="Type to search"
          :loading="isLoading"
          :options="teams"
          :max-height="400"
          @close="onTouch"
          @select="onSelect"
          @remove="onRemove"
          @search-change="searchTeam">
          <span slot="noResult">Oops! No team found. Consider changing the search query.</span>
        </vue-multiselect>

        <span class="help-block">
          <span v-if="!$v.namespace.team.required">Team can't be blank</span>
        </span>
      </div>
    </div>
    <div class="form-group">
      <label class="control-label col-md-2" for="namespace_description">Description</label>
      <div class="col-md-7">
        <textarea id="namespace_description" name="namespace[description]" class="form-control fixed-size" placeholder="A short description of your namespace" v-model="namespace.description"></textarea>
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

  import { required } from 'vuelidate/lib/validators';

  import { handleHttpResponseError } from '~/utils/http';

  import FormMixin from '~/shared/mixins/form';

  import NamespacesService from '../services/namespaces';
  import NamespacesFormMixin from '../mixins/form';

  const { set } = Vue;

  export default {
    props: ['teamName'],

    mixins: [FormMixin, NamespacesFormMixin],

    data() {
      return {
        namespace: {
          name: '',
          team: this.teamName || '',
        },
        timeout: {
          validate: null,
          team: null,
        },
        errors: {
          name: [],
        },
      };
    },

    methods: {
      onSubmit() {
        NamespacesService.save(this.namespace).then((response) => {
          const namespace = response.data;

          this.toggleForm();
          this.$v.$reset();
          set(this, 'namespace', {
            name: '',
            team: this.teamName || '',
          });
          set(this, 'selectedTeam', '');

          this.$bus.$emit('namespaceCreated', namespace);
          this.$alert.$show(`Namespace '${namespace.name}' was created successfully`);
        }).catch(handleHttpResponseError);
      },
    },

    validations: {
      namespace: {
        name: {
          required,
          validate(value) {
            clearTimeout(this.timeout.validate);

            // required already taking care of this
            if (value === '') {
              set(this.errors, 'name', []);
              return true;
            }

            return new Promise((resolve) => {
              const validate = () => {
                const promise = NamespacesService.validate(value);

                promise.then((data) => {
                  set(this.errors, 'name', data.messages.name);
                  resolve(data.valid);
                });
              };

              this.timeout.validate = setTimeout(validate, 1000);
            });
          },
        },
        team: {
          required,
        },
      },
    },
  };
</script>
