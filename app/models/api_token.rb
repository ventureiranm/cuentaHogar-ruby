# Token para el usuario final de la API. Solo se guarda el digest SHA-256:
# el token en texto plano se devuelve una única vez, al hacer login.
class ApiToken < ApplicationRecord
  TTL = 30.days

  belongs_to :user

  validates :token_digest, presence: true, uniqueness: true
  validates :expires_at, presence: true

  scope :active, -> { where(expires_at: Time.current..) }

  def self.issue_for(user)
    raw_token = SecureRandom.base58(32)
    api_token = user.api_tokens.create!(token_digest: digest(raw_token), expires_at: TTL.from_now)
    [ api_token, raw_token ]
  end

  def self.authenticate(raw_token)
    return if raw_token.blank?

    api_token = active.find_by(token_digest: digest(raw_token))
    api_token&.touch(:last_used_at)
    api_token
  end

  def self.digest(raw_token)
    OpenSSL::Digest::SHA256.hexdigest(raw_token.to_s)
  end

  def expired?
    expires_at <= Time.current
  end
end
