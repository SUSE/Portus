<template>
  <div class="btn-group">
    <a
      id="toggle_star"
      href="#"
      class="btn btn-primary"
      data-placement="bottom"
      data-toggle="tooltip"
      rel="nofollow"
      :title="title"
      >
      <i class="fa" :class="starClass"></i>
      <span id="star-counter" class="badge">{{ repository.stars }}</span>
    </a>
  </div>
</template>

<script>
  export default {
    props: {
      repository: {
        type: Object,
      },
    },

    computed: {
      starClass() {
        if (this.repository.starred) {
          return 'fa-star';
        }

        return 'fa-star-o';
      },

      title() {
        if (this.repository.starred) {
          return 'Unstar repository';
        }

        return 'Star repository';
      },
    },
  };
</script>
