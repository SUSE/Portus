<template>
  <form :action="url" method="post" class="form-horizontal" role="form">
    <input type="hidden" name="_method" value="patch" v-if="registry.id" />
    <input type="hidden" name="authenticity_token" :value="csrf" />
    <div class="form-group" :class="{ 'has-error': $v.registryCopy.name.$error }">
      <label class="control-label col-md-2" for="registry_name">Name</label>
      <div class="col-md-7">
        <input type="text" name="registry[name]" id="registry_name" class="form-control" autofocus="true" ref="name" v-model.trim="registryCopy.name" @input="$v.registryCopy.name.$touch()" />
        <span class="help-block">
          <span v-if="!$v.registryCopy.name.required">Name can't be blank</span>
          <span v-for="(error, index) in errors.name" :key="index">Name {{ error }}</span>
        </span>
      </div>
    </div>
    <div class="form-group" :class="{ 'has-error': $v.registryCopy.hostname.$error }" v-if="canChangeHostname">
      <label class="control-label col-md-2" for="registry_hostname">Hostname</label>
      <div class="col-md-7">
        <input type="text" name="registry[hostname]" id="registry_hostname" class="form-control" placeholder="registry.test.lan:5000" v-model.trim="registryCopy.hostname" @input="$v.registryCopy.hostname.$touch()" />
        <span class="help-block">
          <span v-if="!$v.registryCopy.hostname.required">Hostname can't be blank<br /></span>
          <span v-for="(error, index) in errors.hostname" :key="index">
            <span v-if="!isReachableError(error)">Hostname {{ error }}<br /></span>
            <span v-if="isReachableError(error)">{{ error }} You can skip this check by clicking on the "Skip remote checks" checkbox.<br /></span>
          </span>
        </span>
      </div>
    </div>
    <div class="form-group">
      <label class="control-label col-md-2" for="registry_use_ssl" title="Set this to enable SSL in the communication between Portus and the Registry">Use SSL</label>
      <div class="col-md-7">
        <input name="registry[use_ssl]" type="hidden" value="0">
        <input type="checkbox" name="registry[use_ssl]" id="registry_use_ssl" v-model="registryCopy.use_ssl" value="1" />
      </div>
    </div>
    <div id="advanced" class="collapse">
      <div class="form-group">
        <label for="registry_external_hostname" class="control-label col-md-2" title="Set this if the name that clients use to communicate with the registry is different than the name that Portus uses to connect">External Registry Name</label>
        <div class="col-md-7">
          <input type="text" name="registry[external_hostname]" id="registry_exetrnal_hostname" class="form-control" placeholder="(Optional)" v-model="registryCopy.external_hostname" />
          <span class="help-block">Portus uses the hostname field to communicate with the registry, but this may be on an internal network and inaccessible to the client. Clients may connect to the registry by a name different to the hostname above, for example if it is behind a reverse proxy. This field must be set to prevent Portus from ignoring registry events originating from this external hostname.</span>
        </div>
      </div>
    </div>
    <div class="form-group has-error" v-if="display.force && canChangeHostname">
      <label for="force" class="control-label col-md-2" title="Force the creation of the registry, even if it's not reachable.">Skip remote checks</label>
      <div class="col-md-7">
        <input type="checkbox" name="force" id="force" value="true" v-model="registryCopy.force" />
      </div>
    </div>
    <div class="form-group">
      <div class="col-md-offset-2 col-md-7">
        <div class="btn-toolbar" role="toolbar">
          <div class="btn-group" role="group">
            <button type="submit" class="btn btn-primary" :disabled="submitDisabled">Save</button>
          </div>
          <div class="btn-group" role="group">
            <span data-toggle="collapse" data-target="#advanced">
              <button class="btn btn-primary" type="button" data-toggle="button" aria-expanded="false" aria-controls="advanced" @click="showAdvanced=!showAdvanced">{{ showHide }} Advanced</button>
            </span>
          </div>
        </div>
      </div>
    </div>
  </form>
</template>

<script>
  import Vue from 'vue';

  import { required } from 'vuelidate/lib/validators';

  import CSRF from '~/utils/csrf';

  import RegistriesService from '../service';

  const { set } = Vue;

  const timeouts = {};

  export default {
    props: {
      registry: {
        type: Object,
        default: function () {
          return {
            name: '',
            hostname: '',
            external_hostname: '',
            use_ssl: false,
          };
        },
      },
      url: {
        type: String,
        required: true,
      },
      showForce: {
        type: Boolean,
        default: false,
      },
      canChangeHostname: Boolean,
      submitName: String,
    },

    data() {
      return {
        registryCopy: {
          ...this.registry,
          force: false,
        },
        errors: {
          name: [],
          hostname: [],
        },
        display: {
          force: this.showForce || false,
        },
        csrf: CSRF.token(),
        showAdvanced: false,
      };
    },

    validations: {
      registryCopy: {
        name: {
          required,
          remote(value) {
            return this.validate('name', value);
          },
        },
        hostname: {
          required,
          remote(value) {
            // workaround to force validation when use_ssl changes
            void this.registryCopy.use_ssl;

            set(this.display, 'force', false);

            const promise = this.validate('hostname', value);

            if (promise.then) {
              promise.then(() => {
                const hasHostnameErrors = (this.errors.hostname || []).length > 0;
                set(this.display, 'force', hasHostnameErrors);
              });
            }

            return promise;
          },
        },
      },
    },

    methods: {
      isReachableError(error) {
        return error.indexOf('Error') !== -1
            || error.indexOf('connection') !== -1
            || error.indexOf('SSLError') !== -1
            || error.indexOf('OpenTimeout') !== -1
            || error.indexOf('SSLError') !== -1;
      },

      hasReachableError() {
        const errors = this.errors.hostname || [];

        return errors.some(e => this.isReachableError(e));
      },

      validate(field, value) {
        clearTimeout(timeouts[field]);

        // required already taking care of this
        if (value === '' || value === this.registry[field]) {
          set(this.errors, field, []);
          return true;
        }

        return new Promise((resolve) => {
          const validateRequest = () => {
            const promise = RegistriesService.validate(this.registryCopy, field);

            promise.then(({ valid, messages }) => {
              set(this.errors, field, messages[field]);

              resolve(valid);
            });
          };

          set(this.errors, field, []);
          timeouts[field] = setTimeout(validateRequest, 1000);
        });
      },
    },

    computed: {
      submitDisabled() {
        const nameInvalid = this.$v.registryCopy.name.$invalid;
        const hostnameRequiredInvalid = !this.$v.registryCopy.hostname.required;
        const hostnameReachableInvalid = this.hasReachableError() && !this.registryCopy.force;

        return nameInvalid
            || hostnameRequiredInvalid
            || hostnameReachableInvalid
            || this.$v.$pending;
      },

      showHide() {
        if (this.showAdvanced) {
          return 'Hide';
        }

        return 'Show';
      },
    },
  };
</script>
