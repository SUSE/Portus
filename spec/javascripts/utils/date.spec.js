import DateUtil from '~/utils/date';

describe('DateUtil', () => {
  it('returns false if it\'s not a valid date string/object', () => {
    expect(DateUtil.isISO8601('asdasd')).toBe(false);
    expect(DateUtil.isISO8601(null)).toBe(false);
    expect(DateUtil.isISO8601('2018-222-222')).toBe(false);
    expect(DateUtil.isISO8601('')).toBe(false);
    expect(DateUtil.isISO8601('20180205T173027Z')).toBe(false);
  });

  it('returns true if it\'s a valid date string/object', () => {
    expect(DateUtil.isISO8601('2018-07-20T18:14:43.000Z')).toBe(true);
    expect(DateUtil.isISO8601('2018-07-20T18:14:43Z')).toBe(true);
    expect(DateUtil.isISO8601('2018-02-05T17:14Z')).toBe(true);
  });
});
