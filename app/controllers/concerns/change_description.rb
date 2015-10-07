module ChangeDescription
  extend ActiveSupport::Concern

  def change_description(model_object, model_symbol)
    authorize model_object
    model_params = params.require(model_symbol).permit(:description)
    old_description = model_object.description
    model_object.update(model_params)

    model_object.create_activity "change_#{model_symbol}_description".to_sym,
                                  owner:      current_user,
                                  recipient:  model_object,
                                  parameters: {
                                    old_description: old_description,
                                    new_description: model_params["description"]
                                  }
  end
end
