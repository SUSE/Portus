import { setTypeahead } from '~/utils/typeahead';

import { openCloseIcon } from '~/utils/effects';

jQuery(function ($) {
  $('#add_team_user_btn').on('click', function () {
    var team_id;

    $('#team_user_user').val('');
    $('#team_user_role').val('viewer');
    $('#add_team_user_form').toggle(400, 'swing', function () {
      if ($('#add_team_user_form').is(':visible')) {
        $('#add_team_user_btn i').addClass('fa-minus-circle');
        $('#add_team_user_btn i').removeClass('fa-plus-circle');
        $('#team_user_user').focus();
      } else {
        $('#add_team_user_btn i').removeClass('fa-minus-circle');
        $('#add_team_user_btn i').addClass('fa-plus-circle');
      }
      layout_resizer();
    });
    team_id = $('.remote').attr('id');
    setTypeahead('.remote .typeahead', team_id + '/typeahead/%QUERY');
  });

  $('body').on('click', '.btn-edit-role', function (event) {
    var el = $(this).find('i.fa');

    if ($(this).hasClass('add')) {
      openCloseIcon(el);
      $('#team_user_' + event.currentTarget.value + ' td .role').toggle();
      $('#change_role_team_user_' + event.currentTarget.value).toggle();
    } else if ($(this).hasClass('button_edit_team')) {
      $('.team_information').toggle();
      $('#update_team_' + event.currentTarget.value).toggle();
      $('#team_name').focus();
    }
  });

  $('#add_team_btn').on('click', function () {
    $('#team_name').val('');
    $('#team_description').val('');

    $('#add_team_form').toggle(400, 'swing', function () {
      if ($('#add_team_form').is(':visible')) {
        $('#add_team_btn i').addClass('fa-minus-circle');
        $('#add_team_btn i').removeClass('fa-plus-circle');
        $('#team_name').focus();
      } else {
        $('#add_team_btn i').removeClass('fa-minus-circle');
        $('#add_team_btn i').addClass('fa-plus-circle');
      }
      layout_resizer();
    });
  });
});
