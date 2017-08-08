class ApplicationSerializer < ActiveModel::Serializer
  delegate :current_user, to: :scope
end
