class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :jwt_authenticatable, jwt_revocation_strategy: self

  include Devise::JWT::RevocationStrategies::JTIMatcher

  before_create :ensure_jti

  has_many :favorites, dependent: :destroy
  has_many :favorite_scraper_records, through: :favorites, source: :scraper_record

  private

  def ensure_jti
    self.jti ||= SecureRandom.uuid
  end
end
