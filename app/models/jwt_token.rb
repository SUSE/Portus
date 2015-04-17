require 'ostruct'

class JwtToken < OpenStruct

  # TODO: expected to have account, service, scope for .new

  def encoded_token
    headers = { 'kid' => self.class.jwt_kid(private_key) }
    JWT.encode(claim.deep_stringify_keys, private_key, 'RS256', headers)
  end

  def claim
    Hash.new.tap do |hash|
      hash[:iss]     = Rails.application.secrets.machine_fqdn
      hash[:sub]     = account
      hash[:aud]     = service
      hash[:exp]     = expires_at
      hash[:nbf]     = not_before
      hash[:iat]     = issued_at
      hash[:jti]     = jwt_id
      hash[:access]  = authorized_access if scope
    end
  end

  def private_key
    @private_key ||= begin
      key_path = Rails.application.secrets.encryption_private_key_path
      binkey = File.binread(Rails.root.join(key_path))
      OpenSSL::PKey::RSA.new(binkey)
    end
  end

  private

  def authorized_access
    [ single_action ]
  end

  def single_action
    Hash.new.tap do |hash|
      hash[:type]    = scope.resource_type
      hash[:name]    = scope.resource.name
      hash[:actions] = scope.actions
    end
  end

  def jwt_id
    @jwt_id ||= SecureRandom.base58(42)
  end

  def expires_at
    (Time.zone.now + 5.minutes).to_i
  end

  def not_before
    # TODO: misaligned clocks on Portus, Registry and Client
    # https://github.com/SUSE/Portus/issues/9
    Time.zone.now.to_i - 5.seconds
  end

  def issued_at
    not_before
  end

  class << self

    def jwt_kid(private_key)
      sha256 = Digest::SHA256.new
      sha256.update(private_key.public_key.to_der)
      payload = StringIO.new(sha256.digest).read(30)
      Base32.encode(payload).split('').each_slice(4).each_with_object([]) do |slice, mem|
        mem << slice.join
        mem
      end.join(':')
    end

  end

end
