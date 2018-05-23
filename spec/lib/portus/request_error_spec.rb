# frozen_string_literal: true

describe ::Portus::RequestError do
  it "sumarizes the given request error" do
    e = StandardError.new

    expect do
      raise ::Portus::RequestError.new(exception: e, message: "something")
    end.to raise_error(::Portus::RequestError, "StandardError: something")
  end
end
