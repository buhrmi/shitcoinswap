class Identity < ApplicationRecord
  belongs_to :user

  validates :provider, presence: true
  validates :provider_id, presence: true
  validates :provider_id, uniqueness: { scope: :provider }

  def self.from_omniauth!(auth_hash)
    Identity
    .where(provider: auth_hash.provider, provider_id: auth_hash.uid).first_or_create! do |i|
      i.info = auth_hash.info.to_h
      i.user ||= User.where(email: auth_hash.info.email).first_or_create! do |u|
        u.name = auth_hash.info.name
        u.handle = auth_hash.info.nickname
        u.bio = auth_hash.info.description
        u.password = u.password_confirmation = SecureRandom.base58(10)
        if auth_hash.provider == "tiktok-loginkit" && auth_hash.info.nickname
          u.socials = {
            tiktok: auth_hash.info.nickname
          }
        end
        if auth_hash.provider == "twitter" && auth_hash.info.nickname
          u.socials = {
            x: auth_hash.info.nickname
          }
        end
      end
    end
  end
end
