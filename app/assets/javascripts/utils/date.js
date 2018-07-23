import dayjs from 'dayjs';

const isISO8601 = (date) => {
  const type = typeof date;
  const regex = /(\d{4}-[01]\d-[0-3]\dT[0-2]\d:[0-5]\d:[0-5]\d\.\d+([+-][0-2]\d:[0-5]\d|Z))|(\d{4}-[01]\d-[0-3]\dT[0-2]\d:[0-5]\d:[0-5]\d([+-][0-2]\d:[0-5]\d|Z))|(\d{4}-[01]\d-[0-3]\dT[0-2]\d:[0-5]\d([+-][0-2]\d:[0-5]\d|Z))/;

  if (type === 'object') {
    return dayjs(date).isValid();
  }

  if (type !== 'string'
    || !regex.test(date)) {
    return false;
  }

  return dayjs(date).isValid();
};

export default {
  isISO8601,
};
