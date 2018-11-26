import { mount } from '@vue/test-utils';

import TablePagination from '~/shared/components/table-pagination';

describe('table-pagination', () => {
  let wrapper;

  beforeEach(() => {
    const $config = { pagination: { beforeAfter: 2 } };

    wrapper = mount(TablePagination, {
      propsData: {
        total: 10,
        totalPages: 4,
        itensPerPage: 3,
        currentPage: 1,
      },
      mocks: {
        $config,
      },
    });
  });

  it('shows "No entry" if total is zero', () => {
    wrapper.setProps({ total: 0, totalPages: 1 });
    expect(wrapper.html()).toContain('No entry');
  });

  it('shows no pagination element', () => {
    wrapper.setProps({ total: 0, totalPages: 1 });
    expect(wrapper.find('.previous').exists()).toBe(false);
    expect(wrapper.find('.next').exists()).toBe(false);
    expect(wrapper.find('.page').exists()).toBe(false);
  });

  it('shows "Showing from" if total > zero', () => {
    expect(wrapper.html()).toContain('Showing from');
  });

  it('shows start/end/total item number (current page = 1)', () => {
    expect(wrapper.html()).toContain('Showing from 1 to 3 of 10');
  });

  it('shows start item number (current page = 2)', () => {
    wrapper.setProps({ currentPage: 2 });
    expect(wrapper.html()).toContain('Showing from 4 to 6 of 10');
  });

  it('shows "Previous" enabled if current page = 1', () => {
    expect(wrapper.find('.previous').classes()).toContain('disabled');
  });

  it('shows "Previous" disabled if current page > 1', () => {
    wrapper.setProps({ currentPage: 2 });
    expect(wrapper.find('.previous').classes()).not.toContain('disabled');
  });

  it('shows "Next" disabled if current page = last', () => {
    wrapper.setProps({ currentPage: wrapper.vm.totalPages });
    expect(wrapper.find('.next').classes()).toContain('disabled');
  });

  it('shows "Next" enabled if current page < last', () => {
    expect(wrapper.find('.next').classes()).not.toContain('disabled');
  });

  it('increases current page when clicking on "Next" if page != last', () => {
    const $next = wrapper.find('.next a');

    expect(wrapper.vm.currentPage).toBe(1);
    $next.trigger('click');
    expect(wrapper.emitted('update')[0]).toEqual([2]);

    // simulates that table component updated 'currentPage'
    // via two way data binding
    wrapper.setProps({ currentPage: 2 });
    $next.trigger('click');
    expect(wrapper.emitted('update')[1]).toEqual([3]);
  });

  it('current page still the same when clicking on "Next" if page = last', () => {
    const $next = wrapper.find('.next a');
    wrapper.setProps({ currentPage: wrapper.vm.totalPages });

    expect(wrapper.vm.currentPage).toBe(wrapper.vm.totalPages);
    $next.trigger('click');
    expect(wrapper.emitted('update')).toBeUndefined();
  });

  it('decreases current page when clicking on "Previous" if page != last', () => {
    const $previous = wrapper.find('.previous a');
    wrapper.setProps({ currentPage: wrapper.vm.totalPages });

    expect(wrapper.vm.currentPage).toBe(wrapper.vm.totalPages);
    $previous.trigger('click');
    expect(wrapper.emitted('update')[0]).toEqual([wrapper.vm.totalPages - 1]);

    // simulates that table component updated 'currentPage'
    // via two way data binding
    wrapper.setProps({ currentPage: wrapper.vm.totalPages - 1 });
    $previous.trigger('click');
    expect(wrapper.emitted('update')[1]).toEqual([wrapper.vm.totalPages - 2]);
  });

  it('current page still the same when clicking on "Previous" if page = 1', () => {
    const $previous = wrapper.find('.previous a');
    wrapper.setProps({ currentPage: 1 });

    expect(wrapper.vm.currentPage).toBe(1);
    $previous.trigger('click');
    expect(wrapper.emitted('update')).toBeUndefined();
  });

  it('highlights current page', () => {
    let $active = wrapper.find('.active');

    expect($active.text()).toBe(wrapper.vm.currentPage.toString());
    wrapper.setProps({ currentPage: 2 });

    $active = wrapper.find('.active');
    expect($active.text()).toBe(wrapper.vm.currentPage.toString());
  });

  it('goes to the specific page when clicking on page number', () => {
    const $pages = wrapper.findAll('.page');
    const $pageOne = $pages.at(0);
    const $pageTwo = $pages.at(1);

    // click page 2
    $pageTwo.find('a').trigger('click');
    expect(wrapper.emitted('update')[0]).toEqual([2]);

    // click page 1
    $pageOne.find('a').trigger('click');
    expect(wrapper.emitted('update')[1]).toEqual([1]);
  });
});
