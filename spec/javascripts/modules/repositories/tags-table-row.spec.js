import { mount } from '@vue/test-utils';

import TagsTableRow from '~/modules/repositories/components/tags/tags-table-row';

import sinon from 'sinon';

describe('tags-table-row', () => {
  let wrapper;
  const tag = [
    {
      id: 1,
      name: 'latest',
      author: {
        id: 2,
        name: 'vitoravelino',
      },
      digest: 'sha256:4cee1979ba0bf7db9fc5d28fb7b798ca69ae95a47c5fecf46327720df4ff352d',
      image_id: '5b0d59026729b68570d99bc4f3f7c31a2e4f2a5736435641565d93e7c25bd2c3',
      created_at: '2018-02-06T12:54:31.000Z',
      updated_at: '2018-02-06T12:54:31.000Z',
      scanned: 2,
      vulnerabilities: [],
    },
  ];

  beforeEach(() => {
    wrapper = mount(TagsTableRow, {
      propsData: {
        state: {
          selectedTags: [],
          repository: {},
        },
        tag,
        canDestroy: true,
        securityEnabled: true,
      },
      mocks: {
        $bus: {
          $emit: sinon.spy(),
        },
      },
    });
  });

  it('shows checkbox for selection if able to destroy', () => {
    expect(wrapper.find('input[type="checkbox"]').exists()).toBe(true);
  });

  it('shows security column if security is enabled', () => {
    expect(wrapper.find('.vulns').exists()).toBe(true);
  });

  it('shows digest as title of image id data', () => {
    expect(wrapper.find('.image-id span').attributes().title).toBe(tag[0].digest);
  });

  it('shows a short version of image id', () => {
    const shortFormat = tag[0].image_id.substring(0, 12);

    expect(wrapper.find('.image-id').text()).toBe(shortFormat);
  });

  it('shows pending if security scan didnt happen', () => {
    const otherTag = Object.assign({}, tag[0], { scanned: 0 });

    wrapper.setProps({ tag: [otherTag] });
    expect(wrapper.find('.vulns').text()).toBe('Pending');
  });

  it('shows in progress if security scan started but didnt finish', () => {
    const otherTag = Object.assign({}, tag[0], { scanned: 1 });

    wrapper.setProps({ tag: [otherTag] });
    expect(wrapper.find('.vulns').text()).toBe('In progress');
  });

  it('shows # of vulnerabilities if security scan finished', () => {
    expect(wrapper.find('.vulns').text()).toBe('Passed');
  });
});
