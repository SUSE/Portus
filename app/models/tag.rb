class Tag < ActiveRecord::Base
  belongs_to :repository
  belongs_to :author, class_name: 'User', foreign_key: 'user_id'

  has_many :fs_layers

  validates :name,
            presence: true,
            uniqueness: { scope: 'repository_id' },
            format: {
              with: /\A[A-Za-z0-9_\.\-]{1,128}\Z/,
              message: 'Only allowed letters: [A-Za-z0-9_.-]{1,128}' }

  def synchronize!
    manifest = repository.namespace.registry.client.manifest(repository.full_name, name)
    save_from_manifest!(manifest)
  end

  def save_from_manifest!(manifest)
    self.architecture = manifest['architecture']
    manifest['fsLayers'].map { |layer|  fs_layers.find_or_create_by!(blob_sum: layer['blobSum']) }
    self.save!
  end
end
