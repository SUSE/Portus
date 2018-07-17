import { mount } from '@vue/test-utils';

import DeleteTagAction from '~/modules/repositories/components/tags/delete-tag-action';

import sinon from 'sinon';

describe('delete-tag-action', () => {
  let wrapper;

  beforeEach(() => {
    wrapper = mount(DeleteTagAction, {
      propsData: {
        state: {
          selectedTags: [],
        },
      },
      mocks: {
        $bus: {
          $emit: sinon.spy(),
        },
      },
    });
  });

  it('shows nothing if no tag is selected', () => {
    expect(wrapper.find('.label').exists()).toBe(false);
  });

  it('shows label in singular if only one tag is selected', () => {
    wrapper.setProps({ state: { selectedTags: [{}] } });

    expect(wrapper.text()).toBe('Delete tag');
  });

  it('shows label in plural if more than one tag is selected', () => {
    wrapper.setProps({ state: { selectedTags: [{}, {}] } });
    expect(wrapper.text()).toBe('Delete tags');
  });

  it('shows label in plural if more a tag with multiple labels is selected', () => {
    wrapper.setProps({ state: { selectedTags: [{ multiple: true }] } });
    expect(wrapper.text()).toBe('Delete tags');
  });

  it('emits deleteTags event if clicked', () => {
    wrapper.setProps({ state: { selectedTags: [{}] } });

    wrapper.find('.btn').trigger('click');
    expect(wrapper.vm.$bus.$emit.calledWith('deleteTags')).toBe(true);
  });
});
