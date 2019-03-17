# frozen_string_literal: true

require "uri"

# Validates URLs and transforms them into valid ones if needed.
class HttpValidator < ActiveModel::EachValidator
  # Validator for the url.
  def validate_each(record, attribute, value)
    uri = URI.parse(value)
    return if uri.is_a?(URI::HTTP) || uri.is_a?(URI::HTTPS)
    return if generic_enforce_valid(record, uri, value)

    record.errors[attribute] << "is not a valid URL"
  rescue URI::InvalidURIError
    record.errors[attribute] << "is not a valid URL"
  end

  # It returns true if the given uri is URI::Generic and the value does not
  # start like "ftp://". In this case, it will modify the record so the url is
  # set to its proper value.
  def generic_enforce_valid(record, uri, value)
    return false unless uri.is_a?(URI::Generic)

    if value.match(%r{^\w+://.+}).nil?
      record.url = "http://" + value
      true
    else
      false
    end
  end
end
