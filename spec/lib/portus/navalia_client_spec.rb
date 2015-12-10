require "rails_helper"
require "json"

# This class mocks a response object by providing the `code` method. This
# method will return whatever has been passed in the initializer.
class NavaliaMockedStatusResponse
  def initialize(status, response_body)
    @status = status
    @response_body = response_body
  end

  def code
    @status
  end

  def body
    @response_body
  end
end
# This class mocks the `perform_request` by returning whatever has been request
# in the initializer.
class NavaliaPerformRequest < Portus::NavaliaClient
  # This class performes the request
  def initialize(status = 200)
    # call new on parent
    super("host", "token")
    @status = status
    @delete_response_body = nil
    response = [
      {
        "id"      => "get_test_id",
        "status"  => "building",
        "message" => "100",
        "log"     => ""
      }
    ]
    @get_response_body = response.to_json
    response = { "id" => "post_test_id" }
    @post_response_body = response.to_json
  end

  def perform_request(_endpoint, verb = "get", _authentication = nil, _headers = nil, _body = nil)
    # We don't care about the given parameters except for the verb
    raise "General exceptions" if @status.nil?
    case verb
    when "get"
      response_body = @get_response_body
    when "post"
      response_body = @post_response_body
    when "delete"
      response_body = @delete_response_body
    end
    NavaliaMockedStatusResponse.new(@status, response_body)
  end
end

describe Portus::NavaliaClient do
  context "is reachable or not" do
    it "returns the proper thing in all the scenarios" do
      n = NavaliaPerformRequest.new(nil)
      expect(n.reachable?).to be false
      n = NavaliaPerformRequest.new(200)
      expect(n.reachable?).to be true
    end
  end

  context "calling build" do
    it "calls POST build and returns an id" do
      n = NavaliaPerformRequest.new(200)
      response = n.build("url", "registry", "image_id")
      result = JSON.parse(response.body)["id"]
      expected = "post_test_id"
      expect(result).to eq(expected)
    end
  end

  context "calling delete" do
    it "calls DELETE build and returns no body" do
      n = NavaliaPerformRequest.new(200)
      response = n.delete(["test_id"])
      expect(response.body).to be_nil
    end
  end

  context "calling status" do
    it "calls GET build and returns a list" do
      n = NavaliaPerformRequest.new(200)
      response = n.status(["test_id"])
      result = JSON.parse(response.body).first["id"]
      expect(result).to eq("get_test_id")
    end
  end
end
