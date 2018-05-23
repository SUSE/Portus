<template>
  <div class="btn-group">
    <button
      class="btn btn-default private-btn"
      type="button"
      :title="privateTitle"
      :class="{
        'btn-primary': isPrivate,
      }"
      :disabled="isGlobal || !enabled"
      @click="$emit('update:visibility', 'private')"
    >
      <slot name="privateIcon">
        <i class="fa fa-fw fa-lock"></i>
      </slot>
    </button>

    <button
      class="btn btn-default protected-btn"
      title="Logged-in users can pull images from this namespace"
      type="button"
      :class="{
        'btn-primary': isProtected,
      }"
      :disabled="!enabled"
      @click="$emit('update:visibility', 'protected')"
    >
      <slot name="protectedIcon">
        <i class="fa fa-fw fa-users"></i>
      </slot>
    </button>

    <button
      class="btn btn-default public-btn"
      title="Anyone can pull images from this namespace"
      type="button"
      :class="{
        'btn-primary': isPublic
      }"
      :disabled="!enabled"
      @click="$emit('update:visibility', 'public')"
    >
      <slot name="publicIcon">
        <i class="fa fa-fw fa-globe"></i>
      </slot>
    </button>
  </div>
</template>

<script>
  export default {
    props: ['isGlobal', 'visibility', 'canChange', 'locked'],

    computed: {
      isPrivate() {
        return this.visibility === 'private';
      },

      isProtected() {
        return this.visibility === 'protected';
      },

      isPublic() {
        return this.visibility === 'public';
      },

      enabled() {
        return this.canChange && !this.locked;
      },

      privateTitle() {
        if (this.isGlobal) {
          return 'The global namespace cannot be private';
        }

        return 'Team members can pull images from this namespace';
      },
    },
  };
</script>
