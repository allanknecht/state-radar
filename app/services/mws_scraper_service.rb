# app/services/mws_scraper_service.rb
require "nokogiri"

class MwsScraperService < BaseScraperService
  BASE_URL = "https://mws-rs.com.br/".freeze

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
            details = MwsPropertyDetailsExtractor.new(self).extract(base[:link])
            base.merge!(details)
            polite_sleep
          rescue => e
            warn "[MWS] detalhes falharam em #{base[:link]}: #{e.class} - #{e.message}"
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
    basic_info = MwsCardParser.new(node, categoria_hint, self).parse
    return nil if basic_info[:titulo].nil? && basic_info[:link].nil?

    basic_info.merge(site: "mws-rs")
  end
end

# Classe responsável por extrair informações dos cards
class MwsCardParser
  def initialize(node, categoria_hint, scraper)
    @node = node
    @categoria_hint = categoria_hint
    @scraper = scraper
  end

  def parse
    loc = extract_location
    {
      categoria: extract_category,
      codigo: extract_code,
      titulo: extract_title,
      localizacao: loc,
      cidade: extract_city_from_location(loc),   # <- AQUI
      link: extract_link,
      imagem: extract_image,
      preco_brl: extract_price,
      **extract_card_details,
    }
  end

  private

  def extract_city_from_location(loc)
    text = @scraper.send(:squish, loc).to_s
    return nil if text.empty?

    candidate = if text.include?(",")
        text.split(",").last
      else
        text
      end

    normalize_city(candidate)
  end

  def normalize_city(str)
    c = @scraper.send(:squish, str).to_s
    c = c.gsub(/\/[A-Z]{2}\z/i, "") # remove "/RS"
      .gsub(/\s*-\s*[A-Z]{2}\z/i, "") # remove "- RS"
      .gsub(/\s*\([^)]*\)\z/, "") # remove "(...)" no fim
      .strip
    c.presence
  end

  def extract_category
    badge = @scraper.send(:squish, @node.at_css(".product-badge li")&.text)

    if badge&.match?(/loca[cç][ãa]o/i)
      "Locação"
    elsif badge&.match?(/vendas?/i) # <- parênteses corretos e sem ) extra
      "Venda"
    else
      @categoria_hint == :locacao ? "Locação" : (@categoria_hint == :venda ? "Venda" : nil)
    end
  end

  def extract_code
    badge = @scraper.send(:squish, @node.at_css(".product-badge li")&.text)
    badge&.match(/cód\.\s*im[óo]vel\s*(\d+)/i)&.captures&.first
  end

  def extract_title
    @scraper.send(:squish, @node.at_css(".product-title a")&.text)
  end

  def extract_location
    @scraper.send(:squish, @node.at_css(".product-img-location li a")&.text)
  end

  def extract_link
    href = @node.at_css(".product-title a, .product-img a")&.[]("href")
    href ? @scraper.send(:absolutize, href) : nil
  end

  def extract_image
    img = @node.at_css(".product-img img")
    src = img&.[]("src") || img&.[]("data-src")
    src
  end

  def extract_price
    price_txt = @scraper.send(:squish, @node.at_css(".product-info-bottom .product-price")&.text)
    @scraper.send(:parse_brl, price_txt)
  end

  def extract_card_details
    # CORRIGIDO: sintaxe do hash
    details = {
      dormitorios: nil,
      suites: nil,
      vagas: nil,
      area_m2: nil,
      banheiros: nil,
    }

    # CORRIGIDO: sintaxe do each
    @node.css(".ltn__plot-brief li").each do |li|
      text = @scraper.send(:squish, li.text)
      span_text = @scraper.send(:squish, li.at_css("span")&.text)

      # Extrai informações baseado no texto do span e descrição
      case text.downcase
      when /quartos/i
        details[:dormitorios] = span_text.to_i if span_text&.match?(/\d+/)
      when /suites?/i
        details[:suites] = span_text.to_i if span_text&.match?(/\d+/)
      when /vagas/i
        details[:vagas] = span_text.to_i if span_text&.match?(/\d+/)
      when /banheiros/i
        details[:banheiros] = span_text.to_i if span_text&.match?(/\d+/)
      when /área\s+(privativa|total)/i
        area_match = span_text&.match(/([\d\.\,]+)m²?/i)
        if area_match
          details[:area_m2] = @scraper.send(:parse_decimal, area_match[1])
        end
      end
    end

    details
  end
end

# Classe responsável por extrair detalhes da página individual
class MwsPropertyDetailsExtractor
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
    loc_detail = extract_location_from_detail(doc)
    {
      titulo: squish(doc.at_css("h1")&.text),
      categoria: extract_category_from_meta(doc),
      codigo: extract_code_from_meta(doc),
      localizacao: loc_detail,
      cidade: extract_city_from_detail(doc, loc_detail), # <- AQUI
      preco_brl: extract_price_from_detail(doc),
    }
  end

  def extract_city_from_detail(doc, loc_text)
    # 1) Tenta pela label sob o h1 (ex.: "... - ERECHIM/RS")
    city = city_from_location_string(loc_text)
    return city if city

    # 2) Tenta pelo h1 contendo "em CIDADE"
    h1 = squish(doc.at_css("h1")&.text).to_s
    if (m = h1.match(/\bem\s+([A-ZÁÂÃÀÉÊÍÓÔÕÚÇ][A-Za-zÁÂÃÀÉÊÍÓÔÕÚÇ\s\-]+)\b/i))
      return normalize_city(m[1])
    end

    nil
  end

  def city_from_location_string(text)
    t = squish(text).to_s
    return nil if t.empty?

    # Padrão Solar/MWS comum: "... - BAIRRO - CIDADE/UF"
    if (m = t.match(/-\s*([^-\n\/]+)(?:\/[A-Z]{2})?\s*\z/))
      return normalize_city(m[1])
    end

    # fallback: último token após vírgula
    if t.include?(",")
      return normalize_city(t.split(",").last)
    end

    normalize_city(t)
  end

  def normalize_city(str)
    s = squish(str).to_s
    s = s.gsub(/\/[A-Z]{2}\z/i, "").gsub(/\s*-\s*[A-Z]{2}\z/i, "").strip
    s.presence
  end

  def extract_category_from_meta(doc)
    # Tenta extrair categoria dos meta dados
    categoria = doc.css(".ltn__blog-category a")
                   .map { |a| squish(a.text) }
                   .find { |t| t =~ /venda|loca/i }

    case categoria&.downcase
    when /venda/ then "Venda"
    when /loca/ then "Locação"
    else
      # Fallback: tenta do widget title
      widget_title = doc.at_css(".ltn__widget-title")&.text
      case widget_title&.downcase
      when /venda/ then "Venda"
      when /loca/ then "Locação"
      end
    end
  end

  def extract_code_from_meta(doc)
    # Tenta extrair código dos meta dados
    code_text = doc.css(".ltn__blog-category a")
                   .map { |a| squish(a.text) }
                   .find { |t| t =~ /cód/i }
    code_text&.match(/(\d+)/)&.captures&.first
  end

  def extract_location_from_detail(doc)
    # Extrai localização do label sob o h1
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

    # 1. Procura no widget do valor do imóvel
    price_widget = doc.css("h4").find { |n| n.text =~ /valor do im[óo]vel/i }
    if price_widget
      price_text = squish(price_widget.text)
      price = parse_brl(price_text)
      return price if price
    end

    # 2. Procura na lista de características
    doc.css(".property-detail-feature-list-item").each do |item|
      h6_text = squish(item.at_css("h6")&.text)
      if h6_text =~ /valor\s+(do\s+)?(aluguel|venda|im[óo]vel)/i
        price_text = squish(item.at_css("small")&.text)
        price = parse_brl(price_text)
        return price if price
      end
    end

    nil
  end

  def extract_property_details(doc)
    details = extract_details_hash(doc)

    {
      dormitorios: extract_int(details, "Quartos", "Dormitórios"),
      suites: extract_int(details, "Suítes"),
      banheiros: extract_int(details, "Banheiros"),
      lavabos: extract_lavabo_count(details, doc),
      **extract_vagas_info(details),
      mobiliacao: extract_mobiliacao(details, doc),
      tipo_imovel: extract_property_type(details),
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
    # Primeiro tenta da hash de detalhes
    lavabo_count = extract_int(details, "Lavabo", "Lavabos")
    return lavabo_count if lavabo_count

    # Depois verifica nas amenidades
    amenities_text = extract_all_amenities_text(doc)
    if amenities_text.any? { |text| text =~ /lavabo/i }
      return 1
    end

    nil
  end

  def extract_vagas_info(details)
    vagas_text = extract_first_value(details, "Vagas", "Garagens")
    vagas = extract_int(details, "Vagas", "Garagens")
    vagas_min, vagas_max = normalize_vagas_range(vagas_text)

    { vagas: vagas, vagas_min: vagas_min, vagas_max: vagas_max }
  end

  def extract_property_type(details)
    details["Tipo do imóvel"] || details["Tipo de imóvel"]
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
    anchor = doc.css("h4.title-2").find { |n| n.text =~ /[ÁáAa]reas do im[óo]vel/i }
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
      when label.include?("terreno")
        areas[:area_terreno_m2] = num
      end
    end

    {
      area_m2: areas[:area_privativa_m2] || areas[:area_construida_m2] || areas[:area_total_m2],
      area_privativa_m2: areas[:area_privativa_m2],
      area_total_m2: areas[:area_total_m2],
      area_terreno_m2: areas[:area_terreno_m2],
    }
  end

  def extract_description(doc)
    # Procura seção de descrição
    desc_section = doc.css("h4.title-2").find { |h4| h4.text =~ /descri[cç][ãa]o do im[óo]vel/i }
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

    # Extrai de múltiplas seções
    ["Características do Imóvel", "Infraestrutura do Condomínio"].each do |section_name|
      section_amenities = extract_amenities_from_section(doc, section_name)
      amenities.concat(section_amenities)
    end

    amenities.uniq.sort
  end

  def extract_amenities_from_section(doc, section_title)
    amenities = []

    doc.css("h4.title-2").each do |h4|
      title = squish(h4.text)
      next unless title =~ /#{Regexp.escape(section_title)}/i

      # Procura lista de amenidades depois do h4
      sibling = h4.next_element
      while sibling
        break if sibling.name =~ /^h[1-6]$/

        if sibling.css(".ltn__menu-widget ul li").any?
          sibling.css(".ltn__menu-widget ul li").each do |li|
            text = squish(li.text)
            # Remove ícones e texto extra
            clean_text = text.gsub(/^\s*\u2713\s*/, "").gsub(/\s*<br>\s*$/, "").strip
            amenities << clean_text unless clean_text.empty?
          end
          break
        end

        sibling = sibling.next_element
      end
    end

    amenities
  end

  def extract_all_amenities_text(doc)
    amenities_text = []
    doc.css(".ltn__menu-widget ul li").each do |li|
      text = squish(li.text)
      clean_text = text.gsub(/^\s*\u2713\s*/, "").gsub(/\s*<br>\s*$/, "").strip
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
