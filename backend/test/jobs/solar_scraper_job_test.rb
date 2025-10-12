# test/jobs/solar_scraper_job_test.rb
require "test_helper"

class SolarScraperJobTest < ActiveJob::TestCase
  test "should scrape solar imoveis properties" do
    # Mock do serviço para evitar requisições reais durante o teste
    mock_scraper = Minitest::Mock.new
    mock_scraper.expect :scrape_category, [] do |cat, options, &block|
      # Simula dados de teste
      test_data = {
        site: "solarimoveis",
        codigo: "274",
        categoria: "Venda",
        titulo: "Apartamento no bairro Copas Verdes",
        localizacao: "Rua Theobaldo Rossi - Copas Verdes - Erechim - RS",
        link: "https://solarimoveis-rs.com.br/detalhes-imovel-venda.php?id_imovel=274",
        imagem: "https://example.com/image.jpg",
        preco_brl: 399000.0,
        dormitorios: 2,
        suites: 1,
        banheiros: 2,
        vagas: 1,
        area_m2: 85.0,
        condominio: 500.0,
        iptu: 1200.0,
        mobiliacao: "mobiliado",
        descricao: "MEDIDOR DE AGUA INDIVIDUAL MEDIDOR DE GÁS INDIVIDUAL",
        amenities: ["Acabamento em Gesso", "Área de Serviço", "Cozinha Planejada"],
      }

      block.call(test_data) if block_given?
      []
    end

    SolarScraperService.stub :new, mock_scraper do
      assert_difference "ScraperRecord.count", 1 do
        SolarScraperJob.perform_now(:venda, max_pages: 1, fetch_details: true)
      end
    end

    # Verifica se o registro foi criado corretamente
    record = ScraperRecord.find_by(codigo: "274", site: "solarimoveis")
    assert_not_nil record
    assert_equal "Venda", record.categoria
    assert_equal "Apartamento no bairro Copas Verdes", record.titulo
    assert_equal 399000.0, record.preco_brl
    assert_equal 2, record.dormitorios
    assert_equal 1, record.suites
    assert_equal 2, record.banheiros
    assert_equal 1, record.vagas
    assert_equal 85.0, record.area_m2
    assert_equal 500.0, record.condominio
    assert_equal 1200.0, record.iptu
    assert_equal "mobiliado", record.mobiliacao
    assert_equal "MEDIDOR DE AGUA INDIVIDUAL MEDIDOR DE GÁS INDIVIDUAL", record.descricao
    assert_equal ["Acabamento em Gesso", "Área de Serviço", "Cozinha Planejada"], record.amenities

    mock_scraper.verify
  end

  test "should update existing record" do
    # Cria um registro existente
    existing_record = ScraperRecord.create!(
      site: "solarimoveis",
      codigo: "274",
      categoria: "Venda",
      titulo: "Título Antigo",
      preco_brl: 350000.0,
    )

    mock_scraper = Minitest::Mock.new
    mock_scraper.expect :scrape_category, [] do |cat, options, &block|
      test_data = {
        site: "solarimoveis",
        codigo: "274",
        categoria: "Venda",
        titulo: "Título Novo",
        preco_brl: 399000.0,
        dormitorios: 2,
        banheiros: 2,
        vagas: 1,
      }

      block.call(test_data) if block_given?
      []
    end

    SolarScraperService.stub :new, mock_scraper do
      assert_no_difference "ScraperRecord.count" do
        SolarScraperJob.perform_now(:venda, max_pages: 1, fetch_details: true)
      end
    end

    # Verifica se o registro foi atualizado
    existing_record.reload
    assert_equal "Título Novo", existing_record.titulo
    assert_equal 399000.0, existing_record.preco_brl
    assert_equal 2, existing_record.dormitorios
    assert_equal 2, existing_record.banheiros
    assert_equal 1, existing_record.vagas

    mock_scraper.verify
  end

  test "should handle scraping errors gracefully" do
    mock_scraper = Minitest::Mock.new
    mock_scraper.expect :scrape_category, nil do |cat, options, &block|
      raise StandardError, "Erro de rede"
    end

    SolarScraperService.stub :new, mock_scraper do
      assert_no_difference "ScraperRecord.count" do
        SolarScraperJob.perform_now(:venda, max_pages: 1, fetch_details: true)
      end
    end

    mock_scraper.verify
  end
end
