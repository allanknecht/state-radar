class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :jwt_authenticatable, jwt_revocation_strategy: self

  include Devise::JWT::RevocationStrategies::JTIMatcher

  before_create :ensure_jti

  private

  def ensure_jti
    self.jti ||= SecureRandom.uuid
  end
end
