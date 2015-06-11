//= require jquery
//= require jquery.turbolinks
//= require jquery_ujs
//= require turbolinks
//= require bootstrap-sprockets
//= require_tree .


#needs to be at the end since wow.js is the last .js file loaded
wow = new WOW(
  {
    offset: 50
  }
)
wow.init();
