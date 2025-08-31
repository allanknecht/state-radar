class BaseCardParser
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

  protected

  def extract_category
    badge = squish(@node.at_css(".product-badge li")&.text)

    if badge&.match?(/loca[cç][ãa]o/i)
      "Locação"
    elsif badge&.match?(/vendas?/i)
      "Venda"
    else
      @categoria_hint == :locacao ? "Locação" : (@categoria_hint == :venda ? "Venda" : nil)
    end
  end

  def extract_code
    badge = squish(@node.at_css(".product-badge li")&.text)
    code = badge&.match(/c[oó]d\.\s*im[oó]vel\s*(\d+)/i)&.captures&.first

    return code if code

    # Fallback for special code span
    code_span = @node.at_css(".product-badge .code_style, .product-badge span")
    code_text = squish(code_span&.text)
    code_text&.match(/(\d+)/)&.captures&.first
  end

  def extract_title
    selectors = [".imov-title a", ".product-title a"]
    selectors.each do |selector|
      title = squish(@node.at_css(selector)&.text)
      return title if title
    end
    nil
  end

  def extract_location
    selectors = [".product-img-location li a", ".imov-title a"]
    selectors.each do |selector|
      location = squish(@node.at_css(selector)&.text)
      return location if location
    end
    nil
  end

  def extract_link
    selectors = [".imov-title a", ".product-img a", ".product-title a"]
    selectors.each do |selector|
      href = @node.at_css(selector)&.[]("href")
      return absolutize(href) if href
    end
    nil
  end

  def extract_image
    img = @node.at_css(".product-img img")
    img&.[]("src") || img&.[]("data-src")
  end

  def extract_price
    price_selectors = [
      ".product-price .venda",
      ".product-price .locacao",
      ".product-info-bottom .product-price",
      ".product-price",
    ]

    price_selectors.each do |selector|
      price_div = @node.at_css(selector)
      next unless price_div

      price_txt = squish(price_div.text)
      price = parse_brl(price_txt)
      return price if price
    end
    nil
  end

  def extract_card_details
    details = {
      dormitorios: nil,
      suites: nil,
      vagas: nil,
      area_m2: nil,
      banheiros: nil,
      condominio: nil,
      iptu: nil,
    }

    # Try different list selectors
    list_selectors = [
      ".ltn__plot-brief li",
      "ul.ltn__list-item-2--- li",
      ".property-details li",
      ".ltn__list-item-2--- li",
    ]

    list_selectors.each do |selector|
      @node.css(selector).each do |li|
        text = squish(li.text)
        span_text = squish(li.at_css("span")&.text)
        icon = li.at_css("i")
        icon_class = icon&.[]("class") || ""

        extract_detail_from_text(details, text, span_text)
        extract_detail_from_icon(details, icon_class, text)
      end
    end

    details
  end

  private

  def extract_detail_from_text(details, text, span_text)
    case text.downcase
    when /quartos|dormit[oó]rios?/i
      details[:dormitorios] = extract_number(span_text || text)
    when /suites?/i
      details[:suites] = extract_number(span_text || text)
    when /vagas/i
      details[:vagas] = extract_number(span_text || text)
    when /banheiros/i
      details[:banheiros] = extract_number(span_text || text)
    when /área\s+(privativa|total)/i
      area_match = (span_text || text).match(/([\d\.\,]+)m²?/i)
      details[:area_m2] = parse_decimal(area_match[1]) if area_match
    when /condom[ií]nio/i
      value_text = span_text || text
      details[:condominio] = parse_brl(value_text)
    when /\biptu\b/i
      value_text = span_text || text
      details[:iptu] = parse_brl(value_text)
    when /([\d\.\,]+)\s*m²/i
      details[:area_m2] ||= parse_decimal($1)
    end
  end

  def extract_detail_from_icon(details, icon_class, text)
    case icon_class
    when /flaticon-bed/
      details[:dormitorios] ||= extract_number(text)
    when /flaticon-clean/
      details[:banheiros] ||= extract_number(text)
    when /flaticon-car/
      details[:vagas] ||= extract_number(text)
    end
  end

  def extract_number(text)
    text.to_s.match(/(\d+)/)&.[](1)&.to_i
  end

  # Delegate to scraper
  def squish(str); @scraper.send(:squish, str); end
  def parse_brl(str); @scraper.send(:parse_brl, str); end
  def parse_decimal(str); @scraper.send(:parse_decimal, str); end
  def absolutize(href); @scraper.send(:absolutize, href); end
end
