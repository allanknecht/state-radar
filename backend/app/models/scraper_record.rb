class ScraperRecord < ApplicationRecord
  CATEGORIES = ["Venda", "Locação"].freeze
  SITES = ["solar", "simao", "mws"].freeze

  validates :site, presence: true, inclusion: { in: SITES }
  validates :codigo, presence: true,
                     uniqueness: { scope: [:site, :categoria] }
  validates :categoria, presence: true, inclusion: { in: CATEGORIES }

  has_many :favorites, dependent: :destroy
  has_many :users, through: :favorites

  def preco_formatado
    return "Preço indisponível" unless preco_brl.present?
    "R$ #{format_brl_currency(preco_brl)}"
  end

  def iptu_formatado
    return nil unless iptu.present?

    if iptu_parcelas.present?
      "#{iptu_parcelas}x de R$ #{format_brl_currency(iptu)}"
    else
      "R$ #{format_brl_currency(iptu)}"
    end
  end

  def condominio_formatado
    return nil unless condominio.present?

    if condominio_parcelas.present?
      "#{condominio_parcelas}x de R$ #{format_brl_currency(condominio)}"
    else
      "R$ #{format_brl_currency(condominio)}"
    end
  end

  private

  def format_brl_currency(value)
    formatted = sprintf("%.2f", value)

    integer_part, decimal_part = formatted.split(".")

    integer_part = integer_part.reverse.gsub(/(\d{3})(?=\d)/, '\\1.').reverse

    "#{integer_part},#{decimal_part}"
  end
end
