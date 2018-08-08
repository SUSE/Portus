const ALERT_ELEMENT = '#float-alert';
const TEXT_ALERT_ELEMENT = '#float-alert p';
const HIDE_TIMEOUT = 5000;
const STORAGE_KEY = 'portus.alerts.schedule';

const storage = window.localStorage;

const $show = (text, autohide = true, timeout = HIDE_TIMEOUT) => {
  $(TEXT_ALERT_ELEMENT).html(text);
  $(ALERT_ELEMENT).fadeIn();

  if (autohide) {
    setTimeout(() => $(ALERT_ELEMENT).fadeOut(), timeout);
  }
};

const scheduledMessages = () => JSON.parse(storage.getItem(STORAGE_KEY)) || [];
const storeMessages = messages => storage.setItem(STORAGE_KEY, JSON.stringify(messages));

// the idea is to simulate the alert that is showed after a redirect
// e.g.: something happened that requires a page reload/redirect and
// we need to show this info to the user.
const $schedule = (text) => {
  const messages = scheduledMessages();
  messages.push(text);
  storeMessages(messages);
};

const $process = () => {
  const messages = scheduledMessages();
  messages.forEach(m => $show(m, false));
  storage.clear(STORAGE_KEY);
};

export default {
  $show,
  $schedule,
  $process,
};
