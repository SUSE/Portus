module ChangeNameDescription
  extend ActiveSupport::Concern

  # Update the attributes name or description of a ActiveRecord-object.
  def change_name_description(object, symbol)
    authorize object

    new_name = params.require(symbol).permit(:name)
    new_description = params.require(symbol).permit(:description)
    old_description = object.description
    old_name = object.name

    unless old_description == new_description["description"]
      object.update(new_description)
      create_activity(object, symbol, old_description, new_description)
    end

    return if old_name == new_name["name"] || new_name.empty?
    object.update(new_name)
    create_activity(object, symbol, old_name, new_name)
  end

  private

  # Create a PublicActivity for updating an attribute.
  def create_activity(object, symbol, old_value, new_value)
    ctx, new_value = new_value.first
    object.create_activity "change_#{symbol}_#{ctx}".to_sym,
                                  owner:      current_user,
                                  recipient:  object,
                                  parameters: { old: old_value, new: new_value }
  end
end
