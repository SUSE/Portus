# frozen_string_literal: true

module API
  module Helpers
    # Helpers regarding the management of authentication tokens. This module
    # mostly contains methods that are shared across different paths.
    module ApplicationTokens
      # Create an application token for the given user with the given
      # ID. The `params` parameter contains the parameters to be passed to the
      # `ApplicationToken.create_token` method as `params`.
      #
      # This method already sends the proper HTTP response and code.
      def create_application_token!(user, id, params)
        if user.valid?
          application_token, plain_token = ApplicationToken.create_token(
            current_user: user,
            user_id:      id,
            params:       params
          )

          if application_token.errors.empty?
            status 201
            { plain_token: plain_token }
          else
            bad_request!(application_token.errors)
          end
        else
          bad_request!(user.errors)
        end
      end
    end
  end
end
