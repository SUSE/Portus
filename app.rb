require 'sinatra'

get '/v2/token' do
  puts request.params.inspect
  "hello world"
end

error Sinatra::NotFound do
  content_type 'text/plain'
  [404, 'Not Found']
end
