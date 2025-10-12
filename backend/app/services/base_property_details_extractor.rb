class BasePropertyDetailsExtractor
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

  protected

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
    categoria_selectors = [
      ".ltn__blog-category a",
      ".ltn__blog-meta .ltn__blog-category a",
      ".ltn__blog-meta a",
    ]

    categoria_selectors.each do |selector|
      categoria = doc.css(selector)
        .map { |a| squish(a.text) }
        .find { |t| t =~ /venda|loca/i }

      case categoria&.downcase
      when /venda/ then return "Venda"
      when /loca/ then return "Locação"
      end
    end

    # Fallback: try from widget title
    widget_title = doc.at_css(".widget h4.ltn__widget-title, .ltn__widget-title")&.text
    case widget_title&.downcase
    when /venda/ then "Venda"
    when /loca/ then "Locação"
    end
  end

  def extract_code_from_meta(doc)
    code_selectors = [
      ".ltn__blog-category a",
      ".ltn__blog-meta .ltn__blog-category a",
      ".ltn__blog-meta a",
    ]

    code_selectors.each do |selector|
      code_text = doc.css(selector)
        .map { |a| squish(a.text) }
        .find { |t| t =~ /c[oó]d/i }

      code = code_text&.match(/(\d+)/)&.captures&.first
      return code if code
    end
    nil
  end

  def extract_location_from_detail(doc)
    location_text = squish(doc.at_css("h1 ~ label")&.text)

    if location_text && location_text.include?("Rua")
      location_text.gsub(/.*?Rua/, "Rua").strip
    elsif location_text&.include?(" - ")
      parts = location_text.split(" - ")
      parts.length > 1 ? "#{parts[-2]} - #{parts[-1]}" : location_text
    else
      location_text
    end
  end

  def extract_price_from_detail(doc)
    # Strategy 1: Property detail feature list
    doc.css(".property-detail-feature-list-item").each do |item|
      h6_text = squish(item.at_css("h6")&.text)
      if h6_text =~ /valor\s+(do\s+)?(aluguel|venda|im[oó]vel)/i
        price_text = squish(item.at_css("small")&.text)
        price = parse_brl(price_text)
        return price if price
      end
    end

    # Strategy 2: H4 with price info
    h4 = doc.css("h4").find { |n| n.text =~ /valor do im[oó]vel/i }
    if h4
      text = squish(h4.text)
      price = parse_brl(text)
      return price if price
    end

    # Strategy 3: Any element containing R$
    price_elements = doc.css("*").select { |el| el.text.include?("R$") }
    price_elements.each do |el|
      price = parse_brl(el.text)
      return price if price && price > 1000
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
      tipo_imovel: extract_property_type(details),
    }.compact
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
    value.to_s.match(/\d+/)&.[](0)&.to_i if value
  end

  def extract_lavabo_count(details, doc)
    lavabo_count = extract_int(details, "Lavabo", "Lavabos")
    return lavabo_count if lavabo_count

    amenities_text = extract_all_amenities_text(doc)
    amenities_text.any? { |text| text =~ /lavabo/i } ? 1 : nil
  end

  def extract_vagas_info(details)
    vagas_text = extract_first_value(details, "Garagens", "Vagas")
    vagas = extract_int(details, "Garagens", "Vagas")
    vagas_min, vagas_max = normalize_vagas_range(vagas_text)

    { vagas: vagas, vagas_min: vagas_min, vagas_max: vagas_max }.compact
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

  def extract_property_type(details)
    details["Tipo do imóvel"] || details["Tipo de imóvel"]
  end

  def extract_mobiliacao(details, doc)
    values_to_check = details.values + [squish(doc.at_css("h1")&.text)]

    # Add description
    description_text = extract_description(doc)
    values_to_check << description_text if description_text

    raw = values_to_check.compact.find { |v| v =~ /mobiliad/i }
    return raw&.downcase if raw

    # Check amenities
    amenities_text = extract_all_amenities_text(doc)
    furniture_amenities = amenities_text.select { |text|
      text =~ /(mobiliad|mobili[aá]do|sem\s+mobil|mobil[ií]a)/i
    }

    furniture_amenities.first&.downcase if furniture_amenities.any?
  end

  def extract_areas(doc)
    areas = {}

    anchor = doc.css("h4.title-2").find { |n| n.text =~ /[ÁÃáa]reas do im[oó]vel/i }
    return { area_m2: nil, area_privativa_m2: nil } unless anchor

    container = find_areas_container(anchor)
    return { area_m2: nil, area_privativa_m2: nil } unless container

    extract_areas_from_container(container, areas)

    {
      area_m2: areas[:area_privativa_m2] || areas[:area_construida_m2] || areas[:area_total_m2],
      area_privativa_m2: areas[:area_privativa_m2],
      area_total_m2: areas[:area_total_m2],
      area_terreno_m2: areas[:area_terreno_m2],
      area_privativa_comum_m2: areas[:area_comum_m2],
    }.compact
  end

  def find_areas_container(anchor)
    container = anchor.next_element
    while container && !container["class"].to_s.include?("property-detail-feature-list")
      break if container.name =~ /^h[1-6]$/
      container = container.next_element
    end
    container
  end

  def extract_areas_from_container(container, areas)
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
      when label.include?("comum")
        areas[:area_comum_m2] = (areas[:area_comum_m2] || 0) + num
      end
    end
  end

  def extract_description(doc)
    desc_section = doc.css("h4.title-2").find { |h4| h4.text =~ /descri[cç][ãa]o do im[oó]vel/i }
    return nil unless desc_section

    content_parts = []
    sibling = desc_section.next_element

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

      sibling = sibling.next_element
    end

    content_parts.reject(&:empty?).join("\n\n").presence
  end

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

  def extract_amenities(doc)
    amenities = []
    section_names = [
      "Características do Imóvel",
      "Características do Condomínio",
      "Infraestrutura do Condomínio",
      "Próximidades",
      "Proximidades",
    ]

    section_names.each do |section_name|
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

      container = find_amenities_container(h4)
      next unless container

      extract_amenities_from_container(container, amenities)
    end

    amenities
  end

  def find_amenities_container(h4)
    # Try multiple container patterns
    [
      h4.xpath("following-sibling::*").find { |n| n["class"].to_s.include?("property-details-amenities") },
      h4.next_element&.css(".ltn__menu-widget ul li")&.any? ? h4.next_element : nil,
    ].compact.first
  end

  def extract_amenities_from_container(container, amenities)
    # Try different amenity selectors
    selectors = [
      "label.checkbox-item",
      ".ltn__menu-widget ul li",
    ]

    selectors.each do |selector|
      container.css(selector).each do |element|
        text = squish(element.text)
        clean_text = clean_amenity_text(text)
        amenities << clean_text unless clean_text.empty?
      end
    end
  end

  def clean_amenity_text(text)
    text.gsub(/^\s*\u2713\s*/, "")
        .gsub(/\s*<br>\s*$/, "")
        .gsub(/input.*$/i, "")
        .strip
  end

  def extract_all_amenities_text(doc)
    amenities_text = []
    selectors = [
      ".property-details-amenities label.checkbox-item",
      ".ltn__menu-widget ul li",
    ]

    selectors.each do |selector|
      doc.css(selector).each do |element|
        text = squish(element.text)
        clean_text = clean_amenity_text(text)
        amenities_text << clean_text unless clean_text.empty?
      end
    end

    amenities_text
  end

  private

  # Delegate to scraper
  def squish(str); @scraper.send(:squish, str); end
  def parse_brl(str); @scraper.send(:parse_brl, str); end
  def parse_decimal(str); @scraper.send(:parse_decimal, str); end
  def extract_first_value(hash, *keys); keys.map { |k| hash[k] }.compact.first; end
  def normalize_vagas_range(texto); @scraper.send(:normalize_vagas_range, texto); end
end
