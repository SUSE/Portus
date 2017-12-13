# frozen_string_literal: true

class BaseService
  attr_accessor :current_user, :params

  def initialize(user, params = {})
    @current_user = user
    @params = params.dup
  end
end
