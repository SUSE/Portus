<template>
  <panel>
    <h5 slot="heading-left">Registry: <strong>{{ registry.name }}</strong></h5>

    <div slot="body">
      <registry-form :url="url" :registry="registry" :can-change-hostname="canChangeHostname" :show-force="showForce"></registry-form>
    </div>
  </panel>
</template>

<script>
  import RegistryForm from '../components/form';

  export default {
    props: {
      url: String,
      registry: Object,
      canChangeHostname: Boolean,
      showForce: Boolean,
    },

    components: {
      RegistryForm,
    },
  };
</script>
