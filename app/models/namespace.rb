class Namespace < ActiveRecord::Base
  include PublicActivity::Common

  NAME_ALLOWED_CHARS = 'a-z0-9\-_'

  has_many :repositories
  belongs_to :registry
  belongs_to :team
  validates :name,
            presence: true,
            format: {
              with: /\A[#{NAME_ALLOWED_CHARS}]+\Z/,
              message: 'Only allowed letters: [a-z0-9-_]' }
  validates :public, inclusion: { in: [true] }, if: :global?

  def self.sanitize_name(name)
    name.downcase.gsub(/\s+/, '_').gsub(/[^#{NAME_ALLOWED_CHARS}]/, '')
  end

end
