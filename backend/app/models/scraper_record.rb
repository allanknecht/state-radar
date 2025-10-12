class ScraperRecord < ApplicationRecord
  CATEGORIES = ["Venda", "Locação"].freeze
  SITES = ["solar", "simao", "mws"].freeze

  validates :site, presence: true, inclusion: { in: SITES }
  validates :codigo, presence: true,
                     uniqueness: { scope: [:site, :categoria] }
  validates :categoria, presence: true, inclusion: { in: CATEGORIES }
end
