import range from '~/utils/range';

describe('Range', () => {
  it('returns throws exception if start > end', () => {
    expect(() => {
      range(1, -2);
    }).toThrowError();
  });

  it('returns an array of integers', () => {
    expect(range(-1, 1)).toEqual([-1, 0, 1]);
  });
});
