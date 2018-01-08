# frozen_string_literal: true

# Code taken from Gitlab's routing_draw.rb file.
def draw(routes_module)
  instance_eval(File.read(Rails.root.join("config/routes/#{routes_module}.rb")))
end
