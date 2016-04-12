# == Schema Information
#
# Table name: stars
#
#  id            :integer          not null, primary key
#  user_id       :integer
#  repository_id :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

class Star < ActiveRecord::Base
  belongs_to :repository
  belongs_to :user

  validates :repository, presence: true
  validates :user, presence: true, uniqueness: { scope: :repository }
end
