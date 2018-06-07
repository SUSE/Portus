# frozen_string_literal: true

module API
  module Helpers
    # Helpers of repositories
    module Repositories
      def can_destroy_repository?(repository, user)
        RepositoryPolicy.new(user, repository).destroy?
      end
    end
  end
end
