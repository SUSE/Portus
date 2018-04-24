import { mount } from '@vue/test-utils';

import Tag from '~/modules/repositories/components/tags/tag';

import sinon from 'sinon';

describe('tag', () => {
  let wrapper;
  const commandToPull = 'docker pull localhost:5000/opensuse/portus:latest';

  beforeEach(() => {
    wrapper = mount(Tag, {
      propsData: {
        // not real data but the one used in the component
        tag: {
          name: 'latest',
        },
        repository: {
          registry_hostname: 'localhost:5000',
          full_name: 'opensuse/portus',
        },
      },
      mocks: {
        $alert: {
          $show: sinon.spy(),
        },
      },
    });
  });

  it('shows tag name', () => {
    expect(wrapper.find('.label').text()).toBe('latest');
  });

  it('computes command to pull properly', () => {
    expect(wrapper.vm.commandToPull).toBe(commandToPull);
  });

  it('copies command to pull to the clipboard', () => {
    // document in test env doesn't have execCommand
    document.execCommand = sinon.spy();

    wrapper.find('.label').trigger('click');
    expect(document.execCommand.calledWith('copy')).toBe(true);
  });

  it('calls $alert plugin notifying user', () => {
    const message = 'Copied pull command to clipboard';

    wrapper.find('.label').trigger('click');
    expect(wrapper.vm.$alert.$show.calledWith(message)).toBe(true);
  });
});
