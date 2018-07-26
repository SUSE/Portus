import dateutil from '~/utils/date';

const stringComparator = (a, b) => a.localeCompare(b);

const numberComparator = (a, b) => a - b;

const dateComparator = (a, b) => new Date(a) - new Date(b);

function of(value) {
  let type = typeof value;

  if (dateutil.isISO8601(value)) {
    type = 'date';
  }

  switch (type) {
    case 'boolean':
    case 'number':
      return numberComparator;
    case 'date':
      return dateComparator;
    default:
      return stringComparator;
  }
}

export default {
  of,
};
