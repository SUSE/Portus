class Namespace < ActiveRecord::Base
  include NameValidator
  include PublicActivity::Common

  has_many :repositories
  belongs_to :registry
  belongs_to :team
  validates :public, inclusion: { in: [true] }, if: :global?

  def self.sanitize_name(name)
    name.downcase.gsub(/\s+/, '_').gsub(/[^#{NAME_ALLOWED_CHARS}]/, '')
  end
end
