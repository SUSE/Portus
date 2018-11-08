# frozen_string_literal: true

class BaseValidateService
  attr_accessor :params

  def initialize(params = {})
    @params = params.dup
    @messages = {}
  end

  private

  def only_params
    params[:only]
  end

  def messages
    return @messages if only_params.nil?

    @messages.keep_if { |key, v| v.present? && only_params.include?(key.to_s) }
  end

  def valid?
    return @valid if only_params.nil?

    only_params.all? { |field| @messages[field.to_sym].blank? }
  end
end
