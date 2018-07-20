# frozen_string_literal: true

class PublicActivity::ActivityPolicy
  class Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve(count = 20)
      teams_ids = @user.teams.collect(&:id)
      public_visibility = Namespace.visibilities[:visibility_public]

      team_activities(teams_ids, count)
        .union_all(registry_activities(count))
        .union_all(namespace_activities(teams_ids, public_visibility, count))
        .union_all(repository_activities(teams_ids, public_visibility, count))
        .union_all(application_token_activities(count))
        .union_all(webhook_activities(count))
        .distinct
    end

    protected

    def registry_activities(count)
      @scope
        .where("activities.trackable_type = ? AND activities.trackable_id IN (?)",
               "Registry", Registry.get&.id)
        .order(id: :desc)
        .limit(count)
    end

    # Show Team events only if user is a member of the team
    def team_activities(teams_ids, count)
      @scope
        .where("activities.trackable_type = ? AND activities.trackable_id IN (?)",
               "Team", teams_ids)
        .order(id: :desc)
        .limit(count)
    end

    # Show Namespace events only if user is a member of the team controlling
    # the namespace or if the event is a public <-> private switch.
    def namespace_activities(teams_ids, public_visibility, count)
      @scope
        .joins("INNER JOIN namespaces " \
               "ON activities.trackable_id = namespaces.id")
        .where("activities.trackable_type = ? AND " \
               "(namespaces.team_id IN (?) OR " \
               "(activities.key = ? AND namespaces.visibility = ?))",
               "Namespace", teams_ids, "namespace.change_visibility",
               public_visibility)
        .order(id: :desc)
        .limit(count)
    end

    # Show tag events for repositories inside of namespaces controller by
    # a team the user is part of, or tags part of public namespaces.
    def repository_activities(teams_ids, public_visibility, count)
      @scope
        .joins("INNER JOIN repositories " \
               "ON activities.trackable_id = repositories.id " \
               "INNER JOIN namespaces " \
               "ON namespaces.id = repositories.namespace_id")
        .where("activities.trackable_type = ? AND " \
               "(namespaces.team_id IN (?) OR namespaces.visibility = ?)",
               "Repository", teams_ids, public_visibility)
        .order(id: :desc)
        .limit(count)
    end

    # Show application tokens activities related only to the current user
    def application_token_activities(count)
      @scope
        .where("activities.trackable_type = ? " \
               "AND activities.owner_id = ?",
               "ApplicationToken", @user.id)
        .order(id: :desc)
        .limit(count)
    end

    # webhook_activities returns all webhook activities which are accessibly to
    # the user.
    # NOTE: this method is potentially quite expensive. I'm sure it can be
    # optimized.
    # rubocop:disable Metrics/MethodLength
    def webhook_activities(count)
      # Show webhook events only if user is a member of the team controlling
      # the namespace.
      # Note: this works only for existing webhooks
      activities = @scope
                   .joins("INNER JOIN webhooks ON activities.trackable_id = webhooks.id " \
                          "INNER JOIN namespaces ON namespaces.id = webhooks.namespace_id " \
                          "INNER JOIN teams ON teams.id = namespaces.team_id " \
                          "INNER JOIN team_users ON teams.id = team_users.team_id")
                   .where("activities.trackable_type = ? AND team_users.user_id = ?",
                          "Webhook", user.id)
                   .order(id: :desc)
                   .limit(count)

      # Convert relation to array since we want to add single objects, and objects
      # cannot be added to relations.
      activities = activities.to_a

      # Get all namespaces the user has access to.
      user_namespaces = Namespace
                        .where(team_id: TeamUser.where(user_id: user.id).pluck(:team_id))
                        .pluck(:id)

      # Go through all webhooks and add those to the array whose namespace_id is
      # included in the user's accessible namespaces. This step is needed, as
      # there is no (easy) way to match these webhooks with their corresponding
      # namespace.
      @scope
        .where("activities.trackable_type = ?", "Webhook")
        .order(id: :desc)
        .limit(count)
        .distinct.find_each do |webhook|
          unless webhook.parameters.empty?
            activities << webhook if user_namespaces.include? webhook.parameters[:namespace_id]
          end
        end

      # "convert" array back to relation in order to use `union_all`.
      @scope.where(id: activities.map(&:id))
    end
    # rubocop:enable Metrics/MethodLength
  end
end
