require 'rails_helper'

describe JwtToken do

  describe '.new' do

    it 'populates instance of account' do
      token = described_class.new(account: 'account_1')
      expect(token.account).to eq 'account_1'
    end

    it 'populates instance of scope' do
      token = described_class.new(scope: 'scope_1')
      expect(token.scope).to eq 'scope_1'
    end

    it 'populates instance of service' do
      token = described_class.new(service: 'service_1')
      expect(token.service).to eq 'service_1'
    end

  end

  describe '.jwt_kid' do

    it 'returns known by libtrust kid of a given key' do
      kid = JwtToken.jwt_kid(Rails.root.join('vagrant/conf/ca_bundle/server.key'))
      expect(kid).to eq 'PTWT:FNJE:7TW7:ULI7:DZQA:JJJI:RDJQ:2M76:HD6G:ZRSC:VPIF:O5BU'
    end

  end

end
