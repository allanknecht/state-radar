class ScrapperRecord < ApplicationRecord
  CATEGORIAS = ["Venda", "Locação"].freeze

  validates :site, presence: true
  validates :codigo, presence: true, uniqueness: { scope: :site }
  validates :categoria, inclusion: { in: CATEGORIAS }, allow_nil: true

  def preco_brl=(v)
    super(v.is_a?(String) ? BigDecimal(v) : v)
  end
end
