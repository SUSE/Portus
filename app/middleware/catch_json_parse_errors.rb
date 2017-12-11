# frozen_string_literal: true

# The class intercepts ActionDispatch::ParamsParser::ParseError if request
# accept application/json.
class CatchJsonParseErrors
  def initialize(app)
    @app = app
  end

  def call(env)
    @app.call(env)
  rescue ActionDispatch::ParamsParser::ParseError => error
    raise error unless env["HTTP_ACCEPT"].match?(%r{application/json})
    error_output = "There was a problem in the JSON you submitted: #{error}"
    [
      400, { "Content-Type" => "application/json" },
      [{ status: 400, error: error_output }.to_json]
    ]
  end
end
