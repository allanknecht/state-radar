# app/services/solar_scraper_service.rb
require "nokogiri"

class SolarScraperService < BaseScraperService
  BASE_URL = "https://solarimoveis-rs.com.br/".freeze

  PATHS = {
    venda: "imoveis-para-venda.php",
    locacao: "imoveis-para-locacao.php",
  }.freeze

  def initialize(max_retries: 3, pause: 0.5)
    super(base_url: BASE_URL, max_retries: max_retries, pause: pause)
  end

  def scrape_category(categoria, max_pages: nil, fetch_details: true)
    path = PATHS.fetch(categoria) { raise ArgumentError, "categoria inválida: #{categoria}" }

    results = []
    page = 1

    loop do
      break if max_pages && page > max_pages

      url = "#{path}?pagina=#{page}"
      doc = get_doc(url)
      items = parse_list(doc, categoria)
      break if items.empty?

      items.each do |base|
        if fetch_details && base[:link].present?
          begin
            details = SolarPropertyDetailsExtractor.new(self).extract(base[:link])
            base.merge!(details)
            polite_sleep
          rescue => e
            warn "[Solar] detalhes falharam em #{base[:link]}: #{e.class} - #{e.message}"
          end
        end

        block_given? ? yield(base) : results << base
      end

      page += 1
      polite_sleep
    end

    results
  end

  # Expor método para uso interno
  def get_document(url)
    get_doc(url)
  end

  private

  def parse_list(doc, categoria)
    doc.css(".ltn__product-item").map { |item| parse_item(item, categoria) }.compact
  end

  def parse_item(node, categoria_hint)
    basic_info = SolarCardParser.new(node, categoria_hint, self).parse
    return nil if basic_info[:titulo].nil? && basic_info[:link].nil?

    basic_info.merge(site: "solarimoveis")
  end
end

# Classe responsável por extrair informações dos cards
class SolarCardParser
  def initialize(node, categoria_hint, scraper)
    @node = node
    @categoria_hint = categoria_hint
    @scraper = scraper
  end

  def parse
    {
      categoria: extract_category,
      codigo: extract_code,
      titulo: extract_title,
      localizacao: extract_location,
      link: extract_link,
      imagem: extract_image,
      preco_brl: extract_price,
      **extract_card_details,
    }
  end

  private

  def extract_category
    badge = @scraper.send(:squish, @node.at_css(".product-badge li")&.text)

    if badge&.match?(/loca[cç][ãa]o/i)
      "Locação"
    elsif badge&.match?(/venda/i)
      "Venda"
    else
      @categoria_hint == :locacao ? "Locação" : (@categoria_hint == :venda ? "Venda" : nil)
    end
  end

  def extract_code
    # Tenta extrair do badge primeiro
    badge = @scraper.send(:squish, @node.at_css(".product-badge li")&.text)
    code = badge&.match(/c[oó]d\.\s*im[oó]vel\s*(\d+)/i)&.captures&.first

    return code if code

    # Se não encontrar, tenta extrair do span com classe específica
    code_span = @node.at_css(".product-badge .code_style, .product-badge span")
    code_text = @scraper.send(:squish, code_span&.text)
    code_text&.match(/(\d+)/)&.captures&.first
  end

  def extract_title
    # Tenta diferentes seletores para o título
    title = @scraper.send(:squish, @node.at_css(".imov-title a, .product-title a")&.text)
    title
  end

  def extract_location
    # Tenta extrair localização de diferentes lugares
    location = @scraper.send(:squish, @node.at_css(".product-img-location li a, .imov-title a")&.text)
    location
  end

  def extract_link
    # Tenta diferentes seletores para o link
    href = @node.at_css(".imov-title a, .product-img a, .product-title a")&.[]("href")
    href ? @scraper.send(:absolutize, href) : nil
  end

  def extract_image
    img = @node.at_css(".product-img img")
    src = img&.[]("src") || img&.[]("data-src")
    src
  end

  def extract_price
    # Tenta diferentes seletores para o preço
    price_selectors = [
      ".product-price .venda",
      ".product-price .locacao",
      ".product-info-bottom .product-price",
      ".product-price",
    ]

    price_div = nil
    price_selectors.each do |selector|
      price_div = @node.at_css(selector)
      break if price_div
    end

    price_txt = @scraper.send(:squish, price_div&.text)
    @scraper.send(:parse_brl, price_txt)
  end

  def extract_card_details
    details = { dormitorios: nil, suites: nil, vagas: nil, area_m2: nil, condominio: nil, iptu: nil, banheiros: nil }

    # Tenta diferentes seletores para os detalhes
    detail_selectors = [
      ".ltn__list-item-2--- li",
      "ul.ltn__list-item-2--- li",
      ".property-details li",
    ]

    detail_selectors.each do |selector|
      @node.css(selector).each do |li|
        text = @scraper.send(:squish, li.text)
        icon = li.at_css("i")
        icon_class = icon&.[]("class") || ""

        # Extrai por ícone
        case icon_class
        when /flaticon-bed/
          details[:dormitorios] = text.to_i if text.match?(/\d+/)
        when /flaticon-clean/
          details[:banheiros] = text.to_i if text.match?(/\d+/)
        when /flaticon-car/
          details[:vagas] = text.to_i if text.match?(/\d+/)
        end

        # Extrai por texto (fallback)
        case text
        when /\b(\d+)\s*Dormit[oó]rios?/i
          details[:dormitorios] = $1.to_i
        when /\b(\d+)\s*Banheiros?/i
          details[:banheiros] = $1.to_i
        when /\b(\d+)\s*Suites?/i
          details[:suites] = $1.to_i
        when /\b(\d+)\s*Vagas?/i
          details[:vagas] = $1.to_i
        when /([\d\.\,]+)\s*m²/i
          details[:area_m2] = @scraper.send(:parse_decimal, $1)
        end
      end
    end

    details
  end
end

# Classe responsável por extrair detalhes da página individual
class SolarPropertyDetailsExtractor
  def initialize(scraper)
    @scraper = scraper
  end

  def extract(url)
    doc = @scraper.get_document(url)

    basic_info = extract_basic_info(doc)
    property_details = extract_property_details(doc)
    areas = extract_areas(doc)
    description = extract_description(doc)
    amenities = extract_amenities(doc)

    basic_info
      .merge(property_details)
      .merge(areas)
      .merge(descricao: description, amenities: amenities)
      .compact
  end

  private

  def extract_basic_info(doc)
    {
      titulo: squish(doc.at_css("h1")&.text),
      categoria: extract_category_from_meta(doc),
      codigo: extract_code_from_meta(doc),
      localizacao: extract_location_from_detail(doc),
      preco_brl: extract_price_from_detail(doc),
    }
  end

  def extract_category_from_meta(doc)
    # Tenta extrair categoria dos meta dados ou breadcrumbs
    categoria = doc.css(".ltn__blog-category a, .ltn__blog-meta a")
                   .map { |a| squish(a.text) }
                   .find { |t| t =~ /venda|loca/i }

    case categoria&.downcase
    when /venda/ then "Venda"
    when /loca/ then "Locação"
    else
      # Fallback: tenta do widget title ou URL
      widget_title = doc.at_css(".widget h4.ltn__widget-title")&.text
      case widget_title&.downcase
      when /venda/ then "Venda"
      when /loca/ then "Locação"
      end
    end
  end

  def extract_code_from_meta(doc)
    # Tenta extrair código de diferentes lugares
    code_candidates = [
      doc.css(".ltn__blog-category a").map { |a| squish(a.text) },
      doc.css(".ltn__blog-meta a").map { |a| squish(a.text) },
    ].flatten

    code_text = code_candidates.find { |t| t =~ /c[oó]d/i }
    code_text&.match(/(\d+)/)&.captures&.first
  end

  def extract_location_from_detail(doc)
    # Tenta extrair localização do label sob o h1
    location_text = squish(doc.at_css("h1 ~ label")&.text)

    if location_text && location_text.include?("Rua")
      # Remove ícone e mantém endereço completo
      location_text.gsub(/.*?Rua/, "Rua").strip
    else
      location_text
    end
  end

  def extract_price_from_detail(doc)
    # Múltiplas estratégias para encontrar o preço

    # 1. Procura na lista de características
    doc.css(".property-detail-feature-list-item").each do |item|
      h6_text = squish(item.at_css("h6")&.text)
      if h6_text =~ /valor\s+(do\s+)?(aluguel|venda|im[oó]vel)/i
        price_text = squish(item.at_css("small")&.text)
        price = parse_brl(price_text)
        return price if price
      end
    end

    # 2. Procura em h4 com informação de valor
    h4 = doc.css("h4").find { |n| n.text =~ /valor do im[oó]vel/i }
    if h4
      text = squish(h4.text)
      price = parse_brl(text)
      return price if price
    end

    # 3. Procura em qualquer elemento que contenha "R$"
    price_elements = doc.css("*").select { |el| el.text.include?("R$") }
    price_elements.each do |el|
      price = parse_brl(el.text)
      return price if price && price > 1000 # Filtro básico
    end

    nil
  end

  def extract_property_details(doc)
    details = extract_details_hash(doc)

    {
      dormitorios: extract_int(details, "Dormitórios", "Dormitorios", "Quartos"),
      suites: extract_int(details, "Suítes", "Suites"),
      banheiros: extract_int(details, "Banheiros"),
      lavabos: extract_lavabo_count(details, doc),
      **extract_vagas_info(details),
      condominio: extract_condominio(details),
      iptu: extract_iptu(details),
      mobiliacao: extract_mobiliacao(details, doc),
    }
  end

  def extract_details_hash(doc)
    details = {}
    doc.css(".property-detail-feature-list .property-detail-feature-list-item").each do |block|
      label = squish(block.at_css("h6")&.text)
      value = squish(block.at_css("small")&.text)
      next if label.to_s.empty? || value.to_s.empty?
      details[label] = value
    end
    details
  end

  def extract_int(details, *keys)
    value = keys.map { |k| details[k] }.compact.first
    value.to_s.match(/\d+/)&.[](0)&.to_i
  end

  def extract_lavabo_count(details, doc)
    lavabo_count = extract_int(details, "Lavabo", "Lavabos")
    return lavabo_count if lavabo_count

    # Verifica nas amenidades
    amenities_text = extract_all_amenities_text(doc)
    if amenities_text.any? { |text| text =~ /lavabo/i }
      return 1
    end

    nil
  end

  def extract_vagas_info(details)
    vagas_text = extract_first_value(details, "Garagens", "Vagas")
    vagas = extract_int(details, "Garagens", "Vagas")
    vagas_min, vagas_max = normalize_vagas_range(vagas_text)

    { vagas: vagas, vagas_min: vagas_min, vagas_max: vagas_max }
  end

  def extract_condominio(details)
    condominio_value = details["Condomínio"]
    return nil if condominio_value == "Consulte"
    parse_brl(condominio_value)
  end

  def extract_iptu(details)
    iptu_value = details["IPTU"]
    return nil if iptu_value == "Consulte"
    parse_brl(iptu_value)
  end

  def extract_mobiliacao(details, doc)
    # Verifica nos detalhes primeiro
    values_to_check = details.values + [squish(doc.at_css("h1")&.text)]

    # Adiciona descrição
    description_text = extract_description(doc)
    values_to_check << description_text if description_text

    raw = values_to_check.compact.find { |v| v =~ /mobiliad/i }
    return raw&.downcase if raw

    # Verifica nas amenidades
    amenities_text = extract_all_amenities_text(doc)
    furniture_amenities = amenities_text.select { |text|
      text =~ /(mobiliad|mobili[aá]do|sem\s+mobil|mobil[ií]a)/i
    }

    return furniture_amenities.first&.downcase if furniture_amenities.any?
    nil
  end

  def extract_areas(doc)
    areas = {}

    # Procura seção de áreas
    anchor = doc.css("h4.title-2").find { |n| n.text =~ /[ÁÃáa]reas do im[oó]vel/i }
    return { area_m2: nil, area_privativa_m2: nil } unless anchor

    # Encontra container de áreas
    container = anchor.next_element
    while container && !container["class"].to_s.include?("property-detail-feature-list")
      break if container.name =~ /^h[1-6]$/
      container = container.next_element
    end
    return { area_m2: nil, area_privativa_m2: nil } unless container

    container.css(".property-detail-feature-list-item").each do |block|
      label = squish(block.at_css("h6")&.text).to_s.downcase
      value = squish(block.at_css("small")&.text).to_s
      next if label.empty? || value.empty?

      num = parse_decimal(value[/[\d\.,]+/])
      next unless num

      case
      when label.include?("privativa")
        areas[:area_privativa_m2] = num
      when label.match?(/constru/i)
        areas[:area_construida_m2] = num
      when label.include?("total")
        areas[:area_total_m2] = num
      when label.include?("comum")
        areas[:area_comum_m2] = (areas[:area_comum_m2] || 0) + num
      end
    end

    {
      area_m2: areas[:area_privativa_m2] || areas[:area_construida_m2] || areas[:area_total_m2],
      area_privativa_m2: areas[:area_privativa_m2],
      area_privativa_comum_m2: areas[:area_comum_m2],
    }
  end

  def extract_description(doc)
    # Procura seção de descrição
    desc_section = doc.css("h4.title-2").find { |h4| h4.text =~ /descri[cç][ãa]o do im[oó]vel/i }
    return nil unless desc_section

    # Pega próximos elementos até encontrar outro h4
    content_parts = []
    sibling = desc_section.next_element

    while sibling
      break if sibling.name =~ /^h[1-6]$/ || sibling["class"].to_s.include?("title-2")

      case sibling.name
      when "p"
        text = squish(sibling.text)
        content_parts << text unless text.empty?
      when "ul"
        list_items = sibling.css("li").map { |li| "• #{squish(li.text)}" }
        content_parts << list_items.join("\n") unless list_items.empty?
      end

      sibling = sibling.next_element
    end

    content_parts.reject(&:empty?).join("\n\n").presence
  end

  def extract_amenities(doc)
    amenities = []
    ["Características do Imóvel", "Características do Condomínio", "Próximidades", "Proximidades"].each do |section_name|
      amenities.concat(extract_amenities_from_section(doc, section_name))
    end
    amenities.uniq.sort
  end

  def extract_amenities_from_section(doc, section_title)
    amenities = []

    doc.css("h4.title-2").each do |h4|
      title = squish(h4.text)
      next unless title =~ /#{Regexp.escape(section_title)}/i

      # Procura container de amenidades
      container = h4.xpath("following-sibling::*")
                    .find { |n| n["class"].to_s.include?("property-details-amenities") }
      next unless container

      container.css("label.checkbox-item").each do |label|
        text = squish(label.text)
        clean_text = text.gsub(/input.*$/i, "").strip
        amenities << clean_text unless clean_text.empty?
      end
    end

    amenities
  end

  def extract_all_amenities_text(doc)
    amenities_text = []
    doc.css(".property-details-amenities label.checkbox-item").each do |label|
      text = squish(label.text)
      clean_text = text.gsub(/input.*$/i, "").strip
      amenities_text << clean_text unless clean_text.empty?
    end
    amenities_text
  end

  # Métodos auxiliares delegados ao scraper
  def squish(str); @scraper.send(:squish, str); end
  def parse_brl(str); @scraper.send(:parse_brl, str); end
  def parse_decimal(str); @scraper.send(:parse_decimal, str); end
  def extract_first_value(hash, *keys); keys.map { |k| hash[k] }.compact.first; end
  def normalize_vagas_range(texto); @scraper.send(:normalize_vagas_range, texto); end
end
