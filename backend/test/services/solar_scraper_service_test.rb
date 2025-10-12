# test/services/solar_scraper_service_test.rb
require "test_helper"

class SolarScraperServiceTest < ActiveSupport::TestCase
  def setup
    @scraper = SolarScraperService.new(max_retries: 1, pause: 0.1)
  end

  test "should parse card data correctly" do
    html = <<~HTML
      <div class="ltn__product-item">
        <div class="product-badge">
          <ul class="d-flex flex-column">
            <li class="sale-badg">
              <span class="code_style">274</span>
            </li>
            <li class="sale-badg m-0">Apartamento</li>
          </ul>
        </div>
        <div class="product-price">
          <div class="venda">R$ 399.000,00</div>
        </div>
        <h2 class="imov-title">
          <a href="detalhes-imovel-venda.php?id_imovel=274">Centro - Erechim</a>
        </h2>
        <ul class="ltn__list-item-2--- ltn__list-item-2-before--- ltn__plot-brief mb-2">
          <li class="mt-0">
            <span>2</span>
            <i class="flaticon-bed"></i>
          </li>
          <li class="mt-0">
            <span>1</span>
            <i class="flaticon-clean"></i>
          </li>
          <li class="mt-0">
            <span>1</span>
            <i class="flaticon-car"></i>
          </li>
        </ul>
      </div>
    HTML

    doc = Nokogiri::HTML(html)
    card = doc.css(".ltn__product-item").first

    result = CardParser.new(card, :venda, @scraper).parse

    assert_equal "Venda", result[:categoria]
    assert_equal "274", result[:codigo]
    assert_equal "Centro - Erechim", result[:titulo]
    assert_equal "Centro - Erechim", result[:localizacao]
    assert_equal "https://solarimoveis-rs.com.br/detalhes-imovel-venda.php?id_imovel=274", result[:link]
    assert_equal 399000.0, result[:preco_brl]
    assert_equal 2, result[:dormitorios]
    assert_equal 1, result[:banheiros]
    assert_equal 1, result[:vagas]
    assert_equal "solarimoveis", result[:site]
  end

  test "should extract property details correctly" do
    html = <<~HTML
      <html>
        <body>
          <div class="ltn__blog-meta">
            <ul>
              <li class="ltn__blog-category">
                <a href="#">Cód: 274</a>
              </li>
              <li class="ltn__blog-category">
                <a class="bg-orange" href="#">VENDA</a>
              </li>
            </ul>
          </div>
          <h1>Apartamento no bairro Copas Verdes</h1>
          <label>
            <span class="ltn__secondary-color"><i class="flaticon-pin"></i></span>
            Rua Theobaldo Rossi - Copas Verdes - Erechim - RS
          </label>
          <div class="property-detail-feature-list clearfix mb-45">
            <ul>
              <li>
                <div class="property-detail-feature-list-item">
                  <img src="predio-comercial-branco.png" class="img-icon-details">
                  <div>
                    <h6>Condomínio</h6>
                    <small>R$ 500,00</small>
                  </div>
                </div>
              </li>
              <li>
                <div class="property-detail-feature-list-item">
                  <img src="iptu.png" class="img-icon-details">
                  <div>
                    <h6>IPTU</h6>
                    <small>R$ 1.200,00</small>
                  </div>
                </div>
              </li>
            </ul>
            <h4 class="mt-3 mb-0 ltn__widget-title ltn__widget-title-border-2">
              Valor do imóvel:<br>
              R$ 399.000,00
            </h4>
          </div>
          <h4 class="title-2">Descrição do Imóvel</h4>
          <p>MEDIDOR DE AGUA INDIVIDUAL MEDIDOR DE GÁS INDIVIDUAL</p>
          <h4 class="title-2">Características do Imóvel</h4>
          <div class="property-details-amenities mb-60">
            <div class="row">
              <div class="col-lg-12 col-md-12">
                <div class="ltn__menu-widget">
                  <ul>
                    <li>
                      <img src="caracteristicas.png">
                      <label class="checkbox-item p-0">Acabamento em Gesso</label>
                    </li>
                    <li>
                      <img src="caracteristicas.png">
                      <label class="checkbox-item p-0">Área de Serviço</label>
                    </li>
                    <li>
                      <img src="caracteristicas.png">
                      <label class="checkbox-item p-0">mobiliado</label>
                    </li>
                  </ul>
                </div>
              </div>
            </div>
          </div>
        </body>
      </html>
    HTML

    doc = Nokogiri::HTML(html)
    extractor = PropertyDetailsExtractor.new(@scraper)

    result = extractor.extract("https://example.com")

    assert_equal "Apartamento no bairro Copas Verdes", result[:titulo]
    assert_equal "Venda", result[:categoria]
    assert_equal "274", result[:codigo]
    assert_equal "Rua Theobaldo Rossi - Copas Verdes - Erechim - RS", result[:localizacao]
    assert_equal 399000.0, result[:preco_brl]
    assert_equal 500.0, result[:condominio]
    assert_equal 1200.0, result[:iptu]
    assert_equal "MEDIDOR DE AGUA INDIVIDUAL MEDIDOR DE GÁS INDIVIDUAL", result[:descricao]
    assert_equal ["Acabamento em Gesso", "Área de Serviço", "mobiliado"], result[:amenities]
    assert_equal "mobiliado", result[:mobiliacao]
  end

  test "should handle missing data gracefully" do
    html = <<~HTML
      <div class="ltn__product-item">
        <div class="product-badge">
          <ul class="d-flex flex-column">
            <li class="sale-badg">
              <span class="code_style">123</span>
            </li>
          </ul>
        </div>
        <h2 class="imov-title">
          <a href="detalhes-imovel-venda.php?id_imovel=123">Imóvel Teste</a>
        </h2>
      </div>
    HTML

    doc = Nokogiri::HTML(html)
    card = doc.css(".ltn__product-item").first

    result = CardParser.new(card, :venda, @scraper).parse

    assert_equal "123", result[:codigo]
    assert_equal "Imóvel Teste", result[:titulo]
    assert_nil result[:preco_brl]
    assert_nil result[:dormitorios]
    assert_nil result[:banheiros]
    assert_nil result[:vagas]
  end

  test "should parse price correctly" do
    assert_equal 399000.0, @scraper.send(:parse_brl, "R$ 399.000,00")
    assert_equal 1500.0, @scraper.send(:parse_brl, "R$ 1.500,00")
    assert_equal 500.0, @scraper.send(:parse_brl, "R$ 500,00")
    assert_nil @scraper.send(:parse_brl, "Consulte")
    assert_nil @scraper.send(:parse_brl, nil)
    assert_nil @scraper.send(:parse_brl, "")
  end

  test "should parse decimal correctly" do
    assert_equal 85.5, @scraper.send(:parse_decimal, "85,5 m²")
    assert_equal 120.0, @scraper.send(:parse_decimal, "120 m²")
    assert_equal 1500.75, @scraper.send(:parse_decimal, "1.500,75")
    assert_nil @scraper.send(:parse_decimal, "N/A")
    assert_nil @scraper.send(:parse_decimal, nil)
  end
end
