# rubocop:disable Metrics/CyclomaticComplexity
# rubocop:disable Metrics/PerceivedComplexity
module Portus
  # The Portus::Migrate module implements some methods that are used to handle a
  # change from different versions of Portus where there is an old (and
  # deprecated) way of doing things and a preferred new one.
  module Migrate
    # The duration parameter is the given original value, and the default
    # parameter is an Integer with the value to be used whenever there is
    # an error. Otherwise, if the given duration is not an integer and has
    # a good (old) string format, then a deprecation error will be raised.
    #
    # TODO: (mssola) remove in the next version.
    def self.from_humanized_time(duration, default)
      return duration.minutes if duration.respond_to? :minutes

      # If it's not a String then just return the given default value.
      return default.minutes unless duration.is_a? String

      # If we got an empty String then return the default value.
      return default.minutes if duration.empty?

      raw_value, method = duration.split(".")
      value = raw_value.to_i

      # When we found a callable method, notify about deprecation
      if !method.nil? && value.respond_to?(method)
        raise DeprecationError, "The 'x.minutes' format is deprecated for configuration values " \
                                "such as `jwt_expiration_time`. From now on these values are " \
                                "expected to be integers representing minutes."
      elsif value > 0
        # If it's a string containing a positive number, then convert it and return it.
        value.minutes
      else
        # Otherwise, if it has a bad (old) format, then just return the default.
        Rails.logger.warn "Unsupported time format (#{duration}), fallback to default."
        default.minutes
      end
    end

    # Provides a compatibility layer for Portus 2.1 for users that haven't
    # migrated yet from `jwt_expiration_time` to `registry.jwt_expiration_time`.
    #
    # TODO: (mssola) remove in the next version.
    def self.registry_config(key)
      return APP_CONFIG["registry"][key]["value"] if APP_CONFIG["registry"]

      raise DeprecationError, "The usage of '#{key}' is deprecated and it's now under the "\
                              "'registry' configuration section."
    end
  end
end
# rubocop:enable Metrics/PerceivedComplexity
# rubocop:enable Metrics/CyclomaticComplexity
