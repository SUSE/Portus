import { mount } from '@vue/test-utils';

import sinon from 'sinon';

import range from '~/utils/range';

import TagsTable from '~/modules/repositories/components/tags/tags-table';

describe('tags-table', () => {
  let wrapper;
  const tags = range(1, 10).map(i => [
    {
      id: i,
      name: 'latest',
      author: {
        id: i,
        name: 'vitoravelino',
      },
      digest: `sha256:${i}cee1979ba0bf7db9fc5d28fb7b798ca69ae95a47c5fecf46327720df4ff352d`,
      image_id: '5b0d59026729b68570d99bc4f3f7c31a2e4f2a5736435641565d93e7c25bd2c3',
      created_at: '2018-02-06T12:54:31.000Z',
      updated_at: '2018-02-06T12:54:31.000Z',
      scanned: 2,
      vulnerabilities: [],
    },
  ]);

  beforeEach(() => {
    const $config = {
      pagination: {
        beforeAfter: 2,
        perPage: 3,
      },
    };

    wrapper = mount(TagsTable, {
      propsData: {
        currentPage: 2,
        state: {
          selectedTags: [],
          repository: {},
        },
        tags,
        canDestroy: true,
        securityEnabled: true,
      },
      mocks: {
        $config,
        $bus: {
          $emit: sinon.spy(),
        },
      },
    });
  });

  it('shows checkbox column if able to delete row', () => {
    expect(wrapper.find('table input[type="checkbox"]').exists()).toBe(true);
  });

  it('shows security column if security is enabled', () => {
    expect(wrapper.find('.vulns').exists()).toBe(true);
  });

  it('filters tags based on current page and itens per page', () => {
    let currentTags = wrapper.vm.filteredTags.map(t => t[0].id);

    expect(currentTags).toEqual([1, 2, 3]);

    wrapper.setData({ currentPage: 2 });
    currentTags = wrapper.vm.filteredTags.map(t => t[0].id);

    expect(currentTags).toEqual([4, 5, 6]);
  });
});
