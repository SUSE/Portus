<template>
  <li class="result-item text-left">
    <div class="clearfix">
      <h4 class="result-item-name pull-left">{{ repository.full_name }}</h4>

      <div class="result-item-stars pull-right">
        {{ repository.stars }}
        &nbsp;
        <i class="fa fa-star"></i>
      </div>
    </div>

    <div class="clearfix">
      <div class="tags pull-left">
        <tag :tag="tag" v-for="tag in repository.tags[0]" :key="tag.id" :repository="repository"></tag>
      </div>

      <div class="pull-right">
        Updated {{ updatedAt }}
      </div>
    </div>
  </li>
</template>

<script>
  import dayjs from 'dayjs';

  import Tag from '~/modules/repositories/components/tags/tag';

  export default {
    props: ['repository'],

    components: {
      Tag,
    },

    computed: {
      updatedAt() {
        return dayjs(this.repository.updated_at).fromNow();
      },
    },
  };
</script>
