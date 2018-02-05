import Comparator from '~/utils/comparator';

describe('Comparator', () => {
  it('returns string comparator function', () => {
    expect(Comparator.of('string').name).toBe('stringComparator');
  });

  it('returns number comparator function', () => {
    expect(Comparator.of(1).name).toBe('numberComparator');
  });

  it('returns date comparator function', () => {
    expect(Comparator.of(new Date()).name).toBe('dateComparator');
  });

  it('returns string comparator function by default', () => {
    expect(Comparator.of(null).name).toBe('stringComparator');
  });

  describe('string comparator', () => {
    const comparator = Comparator.of('string');

    it('returns -1 if string a < b', () => {
      expect(comparator('a', 'b')).toBe(-1);
    });

    it('returns 0 if string a = b', () => {
      expect(comparator('a', 'a')).toBe(0);
    });

    it('returns 1 if string a > b', () => {
      expect(comparator('b', 'a')).toBe(1);
    });
  });

  describe('number comparator', () => {
    const comparator = Comparator.of(1);

    it('returns a negative number if a < b', () => {
      expect(comparator(1, 2)).toBeLessThanOrEqual(0);
    });

    it('returns 0 if number a = b', () => {
      expect(comparator(1, 1)).toBe(0);
    });

    it('returns a positive number > 0 if a > b', () => {
      expect(comparator(2, 1)).toBeGreaterThanOrEqual(0);
    });
  });

  describe('date comparator', () => {
    const comparator = Comparator.of(new Date());

    it('returns a negative number if date a < b', () => {
      const date1 = new Date('December 16, 1995 03:24:00');
      const date2 = new Date('December 17, 1995 03:24:00');

      expect(comparator(date1, date2)).toBeLessThanOrEqual(0);
    });

    it('returns 0 if date a = b', () => {
      const date1 = new Date('December 17, 1995 03:24:00');
      const date2 = new Date('December 17, 1995 03:24:00');

      expect(comparator(date1, date2)).toBe(0);
    });

    it('returns a positive number if date a > b', () => {
      const date1 = new Date('December 18, 1995 03:24:00');
      const date2 = new Date('December 17, 1995 03:24:00');

      expect(comparator(date1, date2)).toBeGreaterThanOrEqual(0);
    });
  });
});
