class Tag < ActiveRecord::Base

  belongs_to :repository
  belongs_to :author, class_name: 'User', foreign_key: 'user_id'

end
