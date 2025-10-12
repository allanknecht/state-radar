%w[
  SolarScraperService
  SolarScraperServiceCardParser
  SolarScraperServicePropertyDetailsExtractor
].each do |const_name|
  Object.send(:remove_const, const_name) if Object.const_defined?(const_name, false)
end

class SolarScraperService < BaseScraperService
  BASE_URL = "https://solarimoveis-rs.com.br/".freeze

  PATHS = {
    venda: "imoveis-para-venda.php",
    locacao: "imoveis-para-locacao.php",
  }.freeze

  def initialize(max_retries: 3, pause: 0.5)
    super(base_url: BASE_URL, max_retries: max_retries, pause: pause)
  end

  private

  def site_name
    "Solar"
  end
end

class SolarScraperServiceCardParser < BaseCardParser
end

class SolarScraperServicePropertyDetailsExtractor < BasePropertyDetailsExtractor
end
