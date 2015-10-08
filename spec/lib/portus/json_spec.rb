class MockBody
  def initialize(contents)
    @contents = contents
  end

  def read
    @contents
  end
end

class MockResponse
  def initialize(should_fail)
    @should_fail = should_fail
  end

  def body
    MockBody.new(@should_fail ? "<" : "{}")
  end

  def code
    9001 # It's over 9000!!
  end
end

describe Portus::JSON do
  it "returns a proper object on success" do
    res = Portus::JSON.parse(MockResponse.new(false))
    expect(res).to_not be_nil
    expect(res).to be_empty
  end

  it "returns nil on error" do
    expect(Rails.logger).to receive(:warn).with(/JSON: parser error!/)
    expect(Rails.logger).to receive(:warn).with(/A JSON text must at least contain two octets/)
    expect(Rails.logger).to receive(:warn).with(/HTTP Code: 9001/)
    expect(Rails.logger).to receive(:warn).with(/Body/)

    res = Portus::JSON.parse(MockResponse.new(true))
    expect(res).to be_nil
  end
end
