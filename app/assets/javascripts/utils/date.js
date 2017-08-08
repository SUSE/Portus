import moment from 'moment';

const isValid = date => moment(date).isValid();

export default {
  isValid,
};
