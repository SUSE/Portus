import { mount } from '@vue/test-utils';

import VulnerabilitiesPreview from '~/modules/vulnerabilities/components/preview';

describe('vulnerabilities-preview', () => {
  let wrapper;

  beforeEach(() => {
    wrapper = mount(VulnerabilitiesPreview, {
      propsData: {
        vulnerabilities: [],
      },
    });
  });

  context('when no vulnerabilities', () => {
    it('shows passed', () => {
      expect(wrapper.find('.severity-passed').text()).toBe('Passed');
    });
  });

  context('when vulnerabilities', () => {
    it('shows highest severity and total number', () => {
      const vulnerabilities = [
        { severity: 'High' },
        { severity: 'High' },
        { severity: 'Low' },
        { severity: 'Low' },
      ];

      wrapper.setProps({ vulnerabilities });
      expect(wrapper.find('.severity-high').text()).toBe('2 High');
      expect(wrapper.find('.total').text()).toBe('4 total');
    });

    it('shows highest severity and total number [2]', () => {
      const vulnerabilities = [
        { severity: 'Critical' },
        { severity: 'High' },
        { severity: 'High' },
        { severity: 'Low' },
        { severity: 'Low' },
      ];

      wrapper.setProps({ vulnerabilities });
      expect(wrapper.find('.severity-critical').text()).toBe('1 Critical');
      expect(wrapper.find('.total').text()).toBe('5 total');
    });
  });
});
