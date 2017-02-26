jQuery(function ($) {
  $('a[rel~=popover], .has-popover').popover();
  return $('a[rel~=tooltip], .has-tooltip').tooltip();
});
