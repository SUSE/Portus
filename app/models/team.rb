class Team < ActiveRecord::Base

  belongs_to :owner, class_name: User
  has_many :namespaces

  validates :name, :owner, presence: true

  before_create :downcase!

  private

  def downcase!
    self.name.downcase!
  end

end
