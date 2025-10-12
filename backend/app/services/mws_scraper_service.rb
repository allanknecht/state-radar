%w[
  MwsScraperService
  MwsScraperServiceCardParser
  MwsScraperServicePropertyDetailsExtractor
].each do |const_name|
  if Object.const_defined?(const_name, false)
    Object.send(:remove_const, const_name)
    puts "Removed constant: #{const_name}"
  end
end

class MwsScraperService < BaseScraperService
  BASE_URL = "https://mws-rs.com.br/".freeze

  PATHS = {
    venda: "imoveis-para-venda.php",
    locacao: "imoveis-para-locacao.php",
  }.freeze

  def initialize(max_retries: 3, pause: 0.5)
    super(base_url: BASE_URL, max_retries: max_retries, pause: pause)
  end

  private

  def site_name
    "MWS"
  end
end

class MwsScraperServiceCardParser < BaseCardParser
end

class MwsScraperServicePropertyDetailsExtractor < BasePropertyDetailsExtractor
end
