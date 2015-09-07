module Portus
  # The Config class is a convenient wrapper around the different configuration
  # files that provides a simple way to retrieve the evaluated app config.
  class Config
    # The default file corresponds to the default config of the app. The local
    # file can overwrite values from the default file.
    def initialize(default, local)
      @default = default
      @local   = local
    end

    # Returns a hash with the app configuration contained in it.
    def fetch
      cfg = {}
      cfg = YAML.load(ERB.new(File.read(@default)).result) if File.file?(@default)

      if File.file?(@local)
        # Check for bad user input in the local config.yml file.
        local = YAML.load(ERB.new(File.read(@local)).result)
        unless local.is_a?(Hash)
          raise StandardError, "Wrong format for the config-local file!"
        end
        cfg = cfg.deep_merge(local)
      end

      add_enabled(cfg)
    end

    protected

    # Add the `enabled?` method to the given object. The `enabled?` method is
    # a convenient method that checks whether a specific feature is enabled or
    # not. This method takes advantage of the convention that each feature has
    # the "enabled" key inside of it. If this key exists in the checked
    # feature, and it's set to true, then this method will return true. It
    # returns false otherwise.
    def add_enabled(obj)
      obj.define_singleton_method(:enabled?) do |feature|
        return false if !self[feature] || self[feature].empty?
        self[feature]["enabled"].eql?(true)
      end
      obj
    end
  end
end
