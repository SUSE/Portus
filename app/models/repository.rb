class Repository < ActiveRecord::Base

  has_many :images
  belongs_to :team
  validates :name, presence: true

end
