class User < ApplicationRecord
  include Devise::JWT::RevocationStrategies::Denylist
  mount_uploader :profile_image, ProfileImageUploader
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :jwt_authenticatable, jwt_revocation_strategy: JwtDenylist

    def generate_reset_password_token
      self.reset_password_token = SecureRandom.hex(32)
      self.reset_password_sent_at = Time.now
      save
    end
end
