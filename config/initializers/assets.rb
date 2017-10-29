Rails.application.config.assets.version = "1.0"
Rails.application.config.assets.precompile += %w[*.woff2]
Rails.application.config.assets.precompile += %w[debug.js debug.css] if defined? Peek
