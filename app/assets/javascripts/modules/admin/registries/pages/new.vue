<template>
  <panel>
    <h5 slot="heading-left">New Registry</h5>

    <div slot="body">
      <p>Portus needs the information from the form below in order to fetch information from your registry and keep everything up to date (e.g. so tags are added after users push to the registry). Make sure that:</p>

      <ul>
        <li>If you check the SSL checkbox, SSL is properly configured on both sides.</li>
        <li>You include the port to the hostname (e.g. "registry.test.lan:5000").</li>
      </ul>

      <p>If you have any doubts about this, just check our <a href="http://port.us.org/documentation.html" target="_blank">documentation</a>. In particular, make sure to check <a href="http://port.us.org/docs/Configuring-Portus.html" target="_blank"> how to configure Portus</a> and <a href="http://port.us.org/docs/Configuring-the-registry.html" target="_blank"> how to configure your private registry</a>.</p>

      <br/>

      <registry-form :url="url" :can-change-hostname="canChangeHostname" :show-force="showForce"></registry-form>
    </div>
  </panel>
</template>

<script>
  import RegistryForm from '../components/form';

  export default {
    props: {
      url: String,
      canChangeHostname: Boolean,
      showForce: Boolean,
    },

    components: {
      RegistryForm,
    },
  };
</script>
