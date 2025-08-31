class ScraperRecord < ApplicationRecord
  CATEGORIES = ["Venda", "Locação"].freeze

  validates :site, presence: true
  validates :codigo, presence: true,
                     uniqueness: { scope: [:site, :categoria] }
  validates :categoria, presence: true, inclusion: { in: CATEGORIES }
end
