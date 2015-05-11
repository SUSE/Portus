class Registry < ActiveRecord::Base
  has_many :namespaces
  validates :name, presence: true, uniqueness: true
  validates :hostname, presence: true, uniqueness: true
end
