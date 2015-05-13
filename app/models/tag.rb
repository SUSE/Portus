class Tag < ActiveRecord::Base
  include PublicActivity::Common

  belongs_to :repository

end
