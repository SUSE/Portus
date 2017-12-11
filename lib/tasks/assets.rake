# frozen_string_literal: true

# Tasks taken from Gitlab's yarn.rake and assets.rake files.

namespace :portus do
  namespace :assets do
    desc "Compile all frontend assets"
    task compile: [
      "assets:precompile",
      "webpack:compile"
    ]
  end
end
