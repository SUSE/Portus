# frozen_string_literal: true

module TeamUsers
  class BaseService < ::BaseService
    attr_reader :message

    protected

    # Responds with an error if the client is trying to remove the only owner of
    # the team through either the update or the destroy methods.
    def owners_remaining?(team_user)
      return true unless team_user.only_owner?
      return true unless params[:role].nil? || params[:role] != "owner"

      @message = "Cannot remove the only owner of the team"
      false
    end
  end
end
