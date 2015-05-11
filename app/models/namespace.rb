class Namespace < ActiveRecord::Base

  NAME_ALLOWED_CHARS = 'a-z0-9\-_'

  has_many :repositories
  belongs_to :registry
  belongs_to :team
  validates :name,
            presence: true,
            format: {
              with: /\A[#{NAME_ALLOWED_CHARS}]+\Z/,
              message: 'Only allowed letters: [a-z0-9-_]' }

  def self.sanitize_name(name)
    name.downcase.gsub(/\s+/, '_').gsub(/[^#{NAME_ALLOWED_CHARS}]/, '')
  end

end
