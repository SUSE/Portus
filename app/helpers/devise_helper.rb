module DeviseHelper
  def devise_error_messages!
    return '' if resource.errors.empty?

    render(
      template: 'shared/_notification.html.slim',
      layout: nil,
      locals: {
        alert: 'danger',
        messages: resource.errors.full_messages
      }
    ).to_s.html_safe
  end
end
