import DateUtil from '~/utils/date';

describe('DateUtil', () => {
  it('returns false if it\'s not a valid ISO8601 date', () => {
    expect(DateUtil.isValid('asdasd')).toBe(false);
    expect(DateUtil.isValid('2018-02-2')).toBe(false);
    expect(DateUtil.isValid('2018-2-22')).toBe(false);
  });

  it('returns true if it\'s a valid ISO8601 date', () => {
    expect(DateUtil.isValid('2018-02-05T17:30:27+00:00')).toBe(true);
    expect(DateUtil.isValid('2018-02-05T17:30:27Z')).toBe(true);
    expect(DateUtil.isValid('20180205T173027Z')).toBe(true);
  });
});
