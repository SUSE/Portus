class Team < ActiveRecord::Base

  validates :name, presence: true

  has_many :namespaces

  # Users & owners
  has_many :team_users
  has_many :users, through: :team_users
  has_many :owners, -> { where 'team_users.owner': true },
    through: :team_users, source: :user

  before_create :downcase?

  private

  def downcase?
    name.downcase == name
  end

end
