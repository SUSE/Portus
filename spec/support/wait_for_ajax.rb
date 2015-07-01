
# Theoretically, Capybara is clever enough to wait for asynchronous events to
# happen (e.g. AJAX). Sadly, this is not always true. For more, read:
#
#   https://robots.thoughtbot.com/automatically-wait-for-ajax-with-capybara
#
# Therefore, we add the "wait_for_ajax" method, that will be used for these
# corner cases.
module WaitForAjax
  # Wait for all the AJAX requests to have concluded. It respects the timeout
  # defined by `Capybara.default_wait_time`.
  def wait_for_ajax
    Timeout.timeout(Capybara.default_wait_time) do
      loop until finished_all_ajax_requests?
    end
  end

  private

  def finished_all_ajax_requests?
    page.evaluate_script('jQuery.active').zero?
  end
end

RSpec.configure do |config|
  config.include WaitForAjax, type: :feature
end
