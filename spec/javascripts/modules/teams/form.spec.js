import { mount } from '@vue/test-utils';

import Vue from 'vue';
import Vuelidate from 'vuelidate';
import sinon from 'sinon';

import NewTeamForm from '~/modules/teams/components/new-form';

Vue.use(Vuelidate);

describe('new-team-form', () => {
  let wrapper;

  const submitButton = () => wrapper.find('button[type="submit"]');
  const teamNameInput = () => wrapper.find('#team_name');

  beforeEach(() => {
    wrapper = mount(NewTeamForm, {
      propsData: {
        isAdmin: false,
        currentUserId: 0,
        owners: [{}],
      },
      mocks: {
        $bus: {
          $emit: sinon.spy(),
        },
      },
    });
  });

  context('when current user is admin', () => {
    beforeEach(() => {
      wrapper.setProps({
        isAdmin: true,
      });
    });

    it('shows owner select field', () => {
      expect(wrapper.text()).toContain('Owner');
    });
  });

  context('when current user is not admin', () => {
    beforeEach(() => {
      wrapper.setProps({
        isAdmin: false,
      });
    });

    it('hides owner select field', () => {
      expect(wrapper.text()).not.toContain('Owner');
    });
  });

  it('disables submit button if form is invalid', () => {
    expect(submitButton().attributes().disabled).toBe('disabled');
  });

  it('enables submit button if form is valid', () => {
    // there's a custom validation the involves a Promise and an ajax request.
    // this was the simpler way to bypass that validation.
    // tried to stub/mock/fake with sinon but wasn't able to make it work.
    // another solution would be using vue resource interceptors but that would
    // add unecessary complexity for the moment.
    // maybe when we move to axios we could use moxios for that which is much simpler.
    Object.defineProperty(wrapper.vm.$v.team.name, 'available', {
      value: true,
      writable: false,
    });

    teamNameInput().element.value = 'test';
    teamNameInput().trigger('input');
    expect(submitButton().attributes().disabled).toBeUndefined();
  });
});
