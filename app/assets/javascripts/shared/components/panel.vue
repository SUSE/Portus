<template>
  <div class="panel panel-default">
    <div class="panel-heading">
      <div class="row">
        <div class="col-sm-6">
          <slot name="heading-left"></slot>
        </div>
        <div class="col-sm-6 text-right">
          <slot name="heading-right"></slot>
        </div>
      </div>
    </div>

    <div class="panel-body" slot="body">
      <slot name="body"></slot>
    </div>

    <div class="panel-footer">
      <slot name="footer"></slot>
    </div>
  </div>
</template>
