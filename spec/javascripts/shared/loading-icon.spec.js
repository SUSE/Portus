import { mount } from '@vue/test-utils';

import LoadingIcon from '~/shared/components/loading-icon';

describe('loading-icon', () => {
  let wrapper;

  beforeEach(() => {
    wrapper = mount(LoadingIcon);
  });

  it('shows loading icon with normal size (2x)', () => {
    expect(wrapper.find('.fa-spinner').classes()).toContain('fa-2x');
  });

  it('shows loading icon with custom size', () => {
    wrapper.setProps({ size: 3 });
    expect(wrapper.find('.fa-spinner').classes()).toContain('fa-3x');
  });
});
