module ScraperConfiguration
  SCRAPER_CONFIGS = {
    mws: {
      base_url: "https://mws-rs.com.br/",
      site_identifier: "mws-rs",
      paths: {
        venda: "imoveis-para-venda.php",
        locacao: "imoveis-para-locacao.php",
      },
    },
    simao: {
      base_url: "https://www.simaoimoveis.com.br/",
      site_identifier: "simaoimoveis",
      paths: {
        venda: "imoveis-para-venda.php",
        locacao: "imoveis-para-locacao.php",
      },
      url_pattern: "?&pagina=",
    },
    solar: {
      base_url: "https://solarimoveis-rs.com.br/",
      site_identifier: "solarimoveis",
      paths: {
        venda: "imoveis-para-venda.php",
        locacao: "imoveis-para-locacao.php",
      },
    },
  }.freeze

  def self.for(scraper_name)
    SCRAPER_CONFIGS[scraper_name.to_sym] || raise(ArgumentError, "Unknown scraper: #{scraper_name}")
  end
end
