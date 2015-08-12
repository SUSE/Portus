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

  # From the given repository name that can be prefix by the name of the
  # namespace, returns two values:
  #   1. The namespace where the given repository belongs to.
  #   2. The name of the repository itself.
  def self.get_from_name(name)
    if name.include?("/")
      namespace, name = name.split("/", 2)
      namespace = Namespace.find_by(name: namespace)
    else
      namespace = Namespace.find_by(global: true)
    end
    [namespace, name]
  end

  # Returns a String containing the cleaned name for this namespace. The
  # cleaned name will be the registry's hostname if this is a global namespace,
  # or the name of the namespace itself otherwise.
  def clean_name
    global? ? registry.hostname : name
  end
end
