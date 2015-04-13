require 'sinatra'
require 'json'

get '/v2/token' do
  puts request.params.inspect
  "hello world"
end

post '/event' do
  puts "received event"
  puts request.inspect

  request.body.rewind  # in case someone already read it
  data = JSON.parse request.body.read
  puts data.inspect

  [200, 'DONE']
end

error Sinatra::NotFound do
  content_type 'text/plain'
  [404, 'Not Found']
end
