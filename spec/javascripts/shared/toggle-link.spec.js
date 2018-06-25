import { mount } from '@vue/test-utils';

import ToggleLink from '~/shared/components/toggle-link';

describe('toggle-link', () => {
  let wrapper;

  beforeEach(() => {
    wrapper = mount(ToggleLink, {
      propsData: {
        state: {
          key: false,
        },
        stateKey: 'key',
        text: '',
      },
    });
  });

  it('shows the passed text', () => {
    wrapper.setProps({ text: 'Text xD' });

    expect(wrapper.html()).toContain('Text xD');
  });

  it('changes the state on user click', () => {
    wrapper.find('.btn').trigger('click');

    expect(wrapper.vm.state.key).toBe(true);
  });

  it('shows `trueIcon` when state is true', () => {
    const icon = wrapper.find('.fa');
    wrapper.setProps({
      trueIcon: 'fa-true',
      state: { key: true },
    });

    expect(icon.classes()).toContain('fa-true');
  });

  it('shows `falseIcon` when state is false', () => {
    const icon = wrapper.find('.fa');
    wrapper.setProps({
      falseIcon: 'fa-false',
      state: { key: false },
    });

    expect(icon.classes()).toContain('fa-false');
  });

  it('changes icon when state changes', () => {
    const icon = wrapper.find('.fa');
    wrapper.setProps({
      trueIcon: 'fa-true',
      falseIcon: 'fa-false',
      state: { key: false },
    });

    expect(icon.classes()).toContain('fa-false');

    wrapper.find('.btn').trigger('click');

    expect(icon.classes()).toContain('fa-true');
  });
});
