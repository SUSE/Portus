class FsLayer < ActiveRecord::Base
  belongs_to :tag
  validates :blob_sum, presence: true
end
