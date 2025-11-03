class Favorite < ApplicationRecord
  belongs_to :user
  belongs_to :scraper_record

  validates :user_id, uniqueness: { scope: :scraper_record_id }
end

