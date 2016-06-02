module ChangeNameDescription
  extend ActiveSupport::Concern

  # Update the attributes name or description of a ActiveRecord-object.
  def change_name_description(object, symbol, params)
    authorize object

    new_name = params[:name]
    new_description = params[:description]
    old_description = object.description
    old_name = object.name

    change_description(object, symbol, old_description, new_description)
    change_name(object, symbol, old_name, new_name)
  end

  private

  # Create a PublicActivity for updating an attribute.
  def create_activity(object, symbol, ctx, old_value, new_value)
    object.create_activity "change_#{symbol}_#{ctx}".to_sym,
                                  owner:      current_user,
                                  recipient:  object,
                                  parameters: { old: old_value, new: new_value }
  end

  # Change description and track activity if successful.
  def change_description(object, symbol, old_description, new_description)
    return if new_description.nil? || old_description == new_description ||
        !object.update(description: new_description)
    create_activity(object, symbol, "description", old_description, new_description)
  end

  # Change name and track activity if successful.
  def change_name(object, symbol, old_name, new_name)
    return if old_name == new_name || new_name.blank? || !object.update(name: new_name)
    create_activity(object, symbol, "name", old_name, new_name)
  end
end
