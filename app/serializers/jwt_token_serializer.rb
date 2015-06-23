class JwtTokenSerializer < ActiveModel::Serializer
  def token
    object.encoded_token
  end

  attributes :token
end
