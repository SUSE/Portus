require 'rails_helper'

describe JwtToken do

  let(:fake_kid) do
    FFaker.letterify((['????']*12).join(':')).upcase
  end

  let(:scope) { Namespace::AuthScope.new('repository:samalba/my-app:push') }

  before do
    allow(scope).to receive(:resource).and_return(double(name: 'samalba'))
  end

  describe '.new' do

    it 'populates instance of account' do
      token = described_class.new(account: 'account_1')
      expect(token.account).to eq 'account_1'
    end

    it 'populates instance of scope' do
      token = described_class.new(scope: scope)
      expect(token.scope).to eq scope
    end

    it 'populates instance of service' do
      token = described_class.new(service: 'service_1')
      expect(token.service).to eq 'service_1'
    end

  end

  describe '.jwt_kid' do

    # TODO: @eotchi add more keys to test against
    it 'returns known by libtrust kid of a given key' do
      kid = JwtToken.jwt_kid(subject.private_key)
      expect(kid).to eq 'PTWT:FNJE:7TW7:ULI7:DZQA:JJJI:RDJQ:2M76:HD6G:ZRSC:VPIF:O5BU'
    end

  end

  describe '#encoded_token' do

    subject do
      described_class.new(account: 'jlhawn', scope: scope, service: 'registry.docker.com')
    end

    it 'calls JWT#encode with claim with stringified_keys' do
      expect(JWT).to receive(:encode).with(
                         subject.claim.deep_stringify_keys,
                         subject.private_key,
                         'RS256',
                         { 'kid' => described_class.jwt_kid(subject.private_key) }
      )
      subject.encoded_token
    end

  end

  describe '#private_key' do

    it 'returns private key which location is provided by Rails secrets' do
      key_contents = File.read(Rails.root.join(Rails.application.secrets.encryption_private_key_path))
      expect(subject.private_key.to_s).to eq key_contents
    end

    it 'returns OpenSSL::PKey::RSA instance' do
      expect(subject.private_key).to be_a_kind_of OpenSSL::PKey::RSA
    end

    it 'is private' do
      expect(subject.private_key.private?).to be true
    end

  end

  describe '#claim' do

    subject do
      described_class.new(
        account: 'jlhawn',
        scope:   scope,
        service: 'registry.docker.com'
      )
    end

    describe 'basic fields' do

      describe ':iss' do

        it 'is set to portus fqdn' do
          expect(subject.claim[:iss]).to eq Rails.application.secrets.machine_fqdn
        end

      end

      describe ':sub' do

        it 'is set to account instance variable' do
          expect(subject.claim[:sub]).to eq subject.account
        end

      end

      describe ':aud' do

        it 'is set to service instance variable' do
          expect(subject.claim[:aud]).to eq subject.service
        end

      end

      describe ':exp' do

        it 'is set to #expires_at' do
          fake_exp = Time.zone.now + 2.minutes
          allow(subject).to receive(:expires_at).and_return(fake_exp)
          expect(subject.claim[:exp]).to eq fake_exp
        end

      end

      describe ':nbf' do

        it 'is set to #not_before' do
          fake_nbf = Time.zone.now
          allow(subject).to receive(:not_before).and_return(fake_nbf)
          expect(subject.claim[:nbf]).to eq fake_nbf
        end

      end

      describe ':iat' do

        it 'is set to #not_before' do
          fake_nbf = Time.zone.now
          allow(subject).to receive(:not_before).and_return(fake_nbf)
          expect(subject.claim[:iat]).to eq fake_nbf
        end

      end

      describe ':jti' do

        it 'is set to #jwt_id' do
          fake_jti = SecureRandom.base58(42)
          allow(subject).to receive(:jwt_id).and_return(fake_jti)
          expect(subject.claim[:jti]).to eq fake_jti
        end

      end

    end

    describe 'access' do

      it 'has type of array' do
        expect(subject.claim[:access]).to be_a_kind_of Array
      end

      it 'holds one entity' do
        expect(subject.claim[:access].size).to be 1
      end

      describe ':type' do

        it 'has type set to scope#requested_resource_type' do
          expect(subject.claim[:access].first[:type]).to eq scope.send(:requested_resource_type)
        end

      end

      describe ':name' do

        it 'has name set to scope#requested_resource_name' do
          expect(subject.claim[:access].first[:name]).to eq scope.resource.name
        end

      end

      describe ':actions' do

        it 'has actions set to actions from scope' do
          expect(subject.claim[:access].first[:actions]).to eq scope.actions
        end

      end

    end

  end

end
