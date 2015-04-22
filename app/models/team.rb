class Team < ActiveRecord::Base

  belongs_to :owner, class_name: User
  has_many :namespaces

  validates :name, :owner, presence: true

end
