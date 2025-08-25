# app/services/simao_scraper_service.rb
require "nokogiri"

class SimaoScraperService < BaseScraperService
  BASE_URL = "https://www.simaoimoveis.com.br/".freeze

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

      url = "#{path}?&pagina=#{page}"
      doc = get_doc(url)
      items = parse_list(doc, categoria)
      break if items.empty?

      items.each do |base|
        if fetch_details && base[:link].present?
          begin
            details = PropertyDetailsExtractor.new(self).extract(base[:link])
            base.merge!(details)
            polite_sleep
          rescue => e
            warn "[Simao] detalhes falharam em #{base[:link]}: #{e.class} - #{e.message}"
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
    basic_info = CardParser.new(node, categoria_hint, self).parse
    return nil if basic_info[:titulo].nil? && basic_info[:link].nil?

    basic_info.merge(site: "simaoimoveis")
  end
end

# Classe responsável por extrair informações dos cards
class CardParser
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

    if badge&.match?(/loca[cç][aã]o/i)
      "Locação"
    elsif badge&.match?(/venda/i)
      "Venda"
    else
      @categoria_hint == :locacao ? "Locação" : (@categoria_hint == :venda ? "Venda" : nil)
    end
  end

  def extract_code
    badge = @scraper.send(:squish, @node.at_css(".product-badge li")&.text)
    badge&.match(/c[oó]d\.\s*im[oó]vel\s*(\d+)/i)&.captures&.first
  end

  def extract_title
    @scraper.send(:squish, @node.at_css(".product-title a")&.text)
  end

  def extract_location
    @scraper.send(:squish, @node.at_css(".product-img-location li a")&.text)
  end

  def extract_link
    href = @node.at_css(".product-img a")&.[]("href")
    href ? @scraper.send(:absolutize, href) : nil
  end

  def extract_image
    @node.at_css(".product-img img")&.[]("src")
  end

  def extract_price
    price_txt = @scraper.send(:squish, @node.at_css(".product-info-bottom .product-price")&.text)
    @scraper.send(:parse_brl, price_txt)
  end

  def extract_card_details
    details = { dormitorios: nil, suites: nil, vagas: nil, area_m2: nil, condominio: nil, iptu: nil }

    @node.css("ul.ltn__list-item-2--- li").each do |li|
      text = @scraper.send(:squish, li.text)

      case text
      when /\b(\d+)\s*Dormit[oó]rios?/i
        details[:dormitorios] = $1.to_i
      when /\b(\d+)\s*Suites?/i
        details[:suites] = $1.to_i
      when /\b(\d+)\s*Vagas?/i
        details[:vagas] = $1.to_i
      when /([\d\.\,]+)\s*m²/i
        details[:area_m2] = @scraper.send(:parse_decimal, $1)
      when /condom[ií]nio/i
        value_text = li.at_css("span")&.text || text
        details[:condominio] = @scraper.send(:parse_brl, value_text)
      when /\biptu\b/i
        value_text = li.at_css("span")&.text || text
        details[:iptu] = @scraper.send(:parse_brl, value_text)
      end
    end

    details
  end
end

# Classe responsável por extrair detalhes da página individual
class PropertyDetailsExtractor
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
    # Try from meta first
    categoria = doc.css(".ltn__blog-meta .ltn__blog-category a")
                   .map { |a| squish(a.text) }
                   .find { |t| t =~ /venda|loca/i }

    case categoria&.downcase
    when /venda/ then "Venda"
    when /loca/ then "Locação"
    else
      # Fallback: try from widget title
      widget_title = doc.at_css(".widget h4.ltn__widget-title")&.text
      case widget_title&.downcase
      when /venda/ then "Venda"
      when /loca/ then "Locação"
      end
    end
  end

  def extract_code_from_meta(doc)
    # Try from meta first
    code_text = doc.css(".ltn__blog-meta .ltn__blog-category a")
                   .map { |a| squish(a.text) }
                   .find { |t| t =~ /c[oó]d\s*:/i }
    code_text&.match(/(\d+)/)&.captures&.first
  end

  def extract_location_from_detail(doc)
    # Extract from the label under h1
    location_text = squish(doc.at_css("h1 ~ label")&.text)
    return location_text if location_text

    # Fallback: extract just the address part if it includes full address
    if location_text&.include?(" - ")
      parts = location_text.split(" - ")
      # Return neighborhood and city if available
      parts.length > 1 ? "#{parts[-2]} - #{parts[-1]}" : location_text
    else
      location_text
    end
  end

  def extract_price_from_detail(doc)
    # Try multiple approaches to find price

    # First approach: look for "Valor do Aluguel" or similar
    doc.css(".property-detail-feature-list-item").each do |item|
      h6_text = squish(item.at_css("h6")&.text)
      if h6_text =~ /valor\s+(do\s+)?(aluguel|venda|im[óo]vel)/i
        price_text = squish(item.at_css("small")&.text)
        price = parse_brl(price_text)
        return price if price
      end
    end

    # Second approach: look for h4 with price info
    h4 = doc.css("h4").find { |n| n.text =~ /valor do im[óo]vel/i }
    if h4
      text = squish(h4.text)
      return parse_brl(text) || parse_brl(text&.sub(/.*valor do im[óo]vel:\s*/i, ""))
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
    # First try from details hash
    lavabo_count = extract_int(details, "Lavabo", "Lavabos")
    return lavabo_count if lavabo_count

    # Then check amenities for "Lavabo" presence
    amenities_text = extract_all_amenities_text(doc)
    if amenities_text.any? { |text| text =~ /lavabo/i }
      return 1  # Assume 1 if mentioned in amenities
    end

    nil
  end

  def extract_vagas_info(details)
    vagas_text = extract_first_value(details, "Garagens", "Vagas")
    vagas = extract_int(details, "Garagens", "Vagas")
    vagas_min, vagas_max = normalize_vagas_range(vagas_text)

    { vagas: vagas, vagas_min: vagas_min, vagas_max: vagas_max }
  end

  def extract_mobiliacao(details, doc)
    # Check details first
    values_to_check = details.values + [squish(doc.at_css("h1")&.text)]

    # Check description content
    description_text = extract_description(doc)
    values_to_check << description_text if description_text

    raw = values_to_check.compact.find { |v| v =~ /mobiliad/i }
    return raw&.downcase if raw

    # Check amenities for furniture-related items
    amenities_text = extract_all_amenities_text(doc)
    furniture_amenities = amenities_text.select { |text|
      text =~ /(mobiliad|mobili[aá]do|sem\s+mobil|mobil[ií]a)/i
    }

    return furniture_amenities.first&.downcase if furniture_amenities.any?
    nil
  end

  def extract_areas(doc)
    areas = {}

    # ache o h4 certo
    anchor = doc.css("h4.title-2").find { |n| n.text =~ /[ÁáAa]reas do im[óo]vel/i }
    return { area_m2: nil, area_privativa_m2: nil } unless anchor

    # pegue o primeiro irmão que seja elemento e tenha a classe correta
    container = anchor.next_element
    while container && !container["class"].to_s.include?("property-detail-feature-list")
      # se chegou em outro h4, para (acabou a seção)
      break if container.name =~ /^h[1-6]$/
      container = container.next_element
    end
    return { area_m2: nil, area_privativa_m2: nil } unless container && container["class"].to_s.include?("property-detail-feature-list")

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
    anchor = doc.css("h4.title-2").find { |n| n.text =~ /descri[cç][aã]o do im[óo]vel/i }
    return nil unless anchor

    DescriptionExtractor.new.extract_from_anchor(anchor)
  end

  def extract_amenities(doc)
    amenities = []

    # Extract from multiple sections
    ["Características do Imóvel", "Características do Condomínio", "Próximidades"].each do |section_name|
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

      # Look for the amenities container after this h4
      container = h4.xpath("following-sibling::*")
                    .find { |n| n["class"].to_s.include?("property-details-amenities") }
      next unless container

      container.css("label.checkbox-item").each do |label|
        text = squish(label.text)
        # Remove any input-related text
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

# Classe especializada em extrair descrições
class DescriptionExtractor
  def extract_from_anchor(anchor)
    content_parts = []
    sibling = anchor.next

    while sibling
      break if sibling.name =~ /^h[1-6]$/ || sibling["class"].to_s.include?("title-2")

      case sibling.name
      when "p"
        text = squish(sibling.text)
        content_parts << text unless text.empty?
      when "ul"
        list_content = extract_list_content(sibling)
        content_parts << list_content unless list_content.empty?
      end

      sibling = sibling.next
    end

    content_parts.reject(&:empty?).join("\n\n").presence
  end

  private

  def extract_list_content(ul_element)
    list_items = ul_element.css("li").map do |li|
      item_text = squish(li.text)
      next if item_text.empty?

      if li.css("ul").any?
        main_text = squish(li.children.select(&:text?).map(&:text).join(" "))
        sub_items = li.css("ul li").map { |sub_li| "  - #{squish(sub_li.text)}" }.join("\n")
        "• #{main_text}\n#{sub_items}"
      else
        "• #{item_text}"
      end
    end.compact

    list_items.join("\n")
  end

  def squish(str)
    return nil if str.nil?
    str.gsub(/\s+/, " ").strip
  end
end
