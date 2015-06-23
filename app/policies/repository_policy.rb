class RepositoryPolicy
  class Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      @scope
        .joins(namespace: { team: :users })
        .where('namespaces.public = :namespace_public OR ' \
               'users.id = :user_id',
               namespace_public: true, user_id: @user.id)
    end
  end
end
