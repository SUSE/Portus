require 'ostruct'

class JwtToken < OpenStruct

  def self.jwt_kid(private_key_path)
    binkey = File.binread(private_key_path)
    ssl_key = OpenSSL::PKey::RSA.new(binkey)
    sha256 = Digest::SHA256.new
    sha256.update(ssl_key.public_key.to_der)
    payload = StringIO.new(sha256.digest).read(30)
    Base32.encode(payload).split('').each_slice(4).inject([]) do |mem, slice|
      mem << slice.join
      mem
    end.join(':')
  end

end
