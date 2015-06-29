class ChangeRegistryIdFromNamespace < ActiveRecord::Migration
  def change
    # If there are namespaces without a registry_id set, try to migrate them to
    # the existing registry. Otherwise just fail and tell the user to create a
    # registry.
    registry = Registry.first
    if registry
      Namespace.where(registry_id: nil).update_all(registry_id: registry.id)
      PublicActivity::Activity.
        where(trackable_type: 'Namespace').
        update_all(trackable_id: registry.id)
    else
      fail <<-HERE.strip_heredoc
      It appears that you dont have a Registry!
      Please, create one and re-run this migration.
      HERE
    end

    change_column_null(:namespaces, :registry_id, false)
  end
end
