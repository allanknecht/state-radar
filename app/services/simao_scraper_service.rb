# app/services/simao_scraper_service.rb

# Force remove all related constants to prevent superclass mismatch (dev/reload safety)
%w[
  SimaoScraperService
  SimaoScraperServiceCardParser
  SimaoScraperServicePropertyDetailsExtractor
].each do |const_name|
  Object.send(:remove_const, const_name) if Object.const_defined?(const_name, false)
end

class SimaoScraperService < BaseScraperService
  BASE_URL = "https://www.simaoimoveis.com.br/".freeze

  PATHS = {
    venda: "imoveis-para-venda.php",
    locacao: "imoveis-para-locacao.php",
  }.freeze

  def initialize(max_retries: 3, pause: 0.5)
    super(base_url: BASE_URL, max_retries: max_retries, pause: pause)
  end

  protected

  def build_page_url(path, page)
    "#{path}?&pagina=#{page}"
  end

  def site_name
    "Simao"
  end
end

class SimaoScraperServiceCardParser < BaseCardParser
  # All common functionality is inherited
end

class SimaoScraperServicePropertyDetailsExtractor < BasePropertyDetailsExtractor
  # All common functionality is inherited
end
