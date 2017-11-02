import moment from 'moment';

const isValid = date => moment(date, moment.ISO_8601).isValid();

export default {
  isValid,
};
