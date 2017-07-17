const ALERT_ELEMENT = '#float-alert';
const TEXT_ALERT_ELEMENT = '#float-alert p';
const HIDE_TIMEOUT = 5000;

function show(text, autohide = true) {
  $(TEXT_ALERT_ELEMENT).html(text);
  $(ALERT_ELEMENT).fadeIn();

  if (autohide) {
    setTimeout(() => $(ALERT_ELEMENT).fadeOut(), HIDE_TIMEOUT);
  }
}

export default {
  show,
};
