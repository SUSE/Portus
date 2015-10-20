module ApplicationHelper
  # Render the user profile picture depending on the gravatar configuration.
  def user_image_tag(email)
    if APP_CONFIG.enabled?("gravatar")
      gravatar_image_tag(email)
    else
      image_tag "user.svg", class: "user-picture"
    end
  end

  # Render the image tag that is suitable for activities.
  def activity_time_tag(ct)
    time_tag ct, time_ago_in_words(ct), title: ct
  end
end
