# frozen_string_literal: true

require "json"

module Jekyll
  # Extract the definition schema for the given response.
  module DefinitionExtractor
    # Extracts the response type definition from the input as JSON.
    def definition_extractor(input)
      res = extract_from_input(input.last)
      JSON.pretty_generate(res)
    end

    protected

    # Extracts the object to converted into JSON from the given input.
    def extract_from_input(input)
      ref, is_array = schema_ref(input)
      return unless ref

      res = {}
      d = definition_from_ref(ref)
      d.each { |k, v| res[k] = from_type(v) }
      is_array ? [res] : res
    end

    # Returns the value to be set for the given type.
    # rubocop:disable Metrics/CyclomaticComplexity
    def from_type(val)
      case val["type"]
      when "integer"
        0
      when "string"
        string_format(val)
      when "boolean"
        true
      when "array"
        ["#{val["items"]["type"]}s"]
      when /Array\[(\w+)\]/
        ["#{Regexp.last_match(1).downcase}s"]
      when "object"
        "<object>: #{val["description"]}"
      else
        # Check if this is a hash with some other entities inside of it.
        extract_from_input("schema" => val) if val["$ref"]
      end
    end
    # rubocop:enable Metrics/CyclomaticComplexity

    # Returns a string representing the format of it.
    def string_format(val)
      val["format"] ? "<#{val["format"]}>" : "string"
    end

    # Returns the schema reference from the given input.
    def schema_ref(input)
      schema = input["schema"]
      return unless schema

      ref = schema["$ref"]
      is_array = ref.nil?
      ref ||= schema["items"]["$ref"]
      return unless ref

      [ref.split("/").last, is_array]
    end

    # Returns the property for the definition referenced by the given argument.
    def definition_from_ref(ref)
      definitions[ref]["properties"]
    end

    # Returns the definitions set by Swagger. This method depends on the
    # `swagger_register.rb` plugin.
    def definitions
      # rubocop:disable Style/GlobalVars
      o = $definitions
      msg = "The $definitions variable has not been set"
      raise StandardError, msg unless $definitions
      # rubocop:enable Style/GlobalVars
      o
    end
  end
end

Liquid::Template.register_filter(Jekyll::DefinitionExtractor)
