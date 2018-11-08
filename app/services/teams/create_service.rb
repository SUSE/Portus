# frozen_string_literal: true

module Teams
  class CreateService < ::BaseService
    def execute
      @team = Team.new(params.except(:owner_id))
      @team.owners << owner

      create_activity! if @team.save

      @team
    end

    private

    def create_activity!
      @team.create_activity(:create,
                            owner:      current_user,
                            parameters: { team: @team.name })
    end

    def owner
      raise Pundit::NotAuthorizedError, "must be an admin" if cannot_set_owner?

      if params[:owner_id]
        user = User.find_by(id: params[:owner_id])
        raise ActiveRecord::RecordNotFound unless user

        user
      else
        current_user
      end
    end

    def cannot_set_owner?
      params[:owner_id] && !current_user.admin?
    end
  end
end
