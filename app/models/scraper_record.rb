class ScraperRecord < ApplicationRecord
  CATEGORIES = ["Venda", "Locação"].freeze

  validates :site, presence: true
  validates :codigo, presence: true, uniqueness: { scope: :site }
  validates :categoria, inclusion: { in: CATEGORIES }, allow_nil: true
end
