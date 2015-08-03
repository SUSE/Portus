class Namespace < ActiveRecord::Base
  include NameValidator
  include PublicActivity::Common

  has_many :repositories
  belongs_to :registry
  belongs_to :team
  validates :public, inclusion: { in: [true] }, if: :global?

  def self.sanitize_name(name)
    name.downcase.gsub(/\s+/, "_").gsub(/[^#{NAME_ALLOWED_CHARS}]/, "")
  end

  # Returns a String containing the cleaned name for this namespace. The
  # cleaned name will be the registry's hostname if this is a global namespace,
  # or the name of the namespace itself otherwise.
  def clean_name
    global? ? registry.hostname : name
  end
end
