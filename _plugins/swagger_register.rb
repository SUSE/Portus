# frozen_string_literal: true

# Register the API definitions, which is needed by the `definition_extractor.rb`
# plugin.
# rubocop:disable Style/GlobalVars
Jekyll::Hooks.register :documents, :pre_render do |doc|
  data = doc.site.data["api"]
  $definitions = data["definitions"] if data && $definitions.nil?
end
# rubocop:enable Style/GlobalVars
