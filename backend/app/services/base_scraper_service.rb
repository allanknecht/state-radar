require "faraday"
require "nokogiri"
require "uri"

class BaseScraperService
  DEFAULT_HEADERS = {
    "User-Agent" => "Mozilla/5.0 (Windows NT 10.0; Win64; x64) " \
                    "AppleWebKit/537.36 (KHTML, like Gecko) " \
                    "Chrome/115.0 Safari/537.36",
    "Accept" => "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
  }.freeze

  def initialize(base_url:, max_retries: 3, pause: 0.5)
    @base_url = base_url
    @max_retries = max_retries
    @pause = pause

    @conn = Faraday.new(url: @base_url) do |f|
      f.request :retry, max: @max_retries, interval: @pause, backoff_factor: 2
      f.response :raise_error
      f.adapter Faraday.default_adapter
    end
  end

  def scrape_category(categoria, max_pages: nil, fetch_details: true)
    path = self.class::PATHS.fetch(categoria) { raise ArgumentError, "categoria inválida: #{categoria}" }

    results = []
    page = 1

    loop do
      break if max_pages && page > max_pages

      url = build_page_url(path, page)
      doc = get_doc(url)
      items = parse_list(doc, categoria)
      break if items.empty?

      items.each do |base|
        if fetch_details && base[:link].present?
          begin
            details = property_details_extractor.extract(base[:link])
            base.merge!(details)
            base[:site] = site_identifier
            polite_sleep
          rescue => e
            warn "[#{site_name}] detalhes falharam em #{base[:link]}: #{e.class} - #{e.message}"
          end
        end

        block_given? ? yield(base) : results << base
      end

      page += 1
      polite_sleep
    end

    results
  end

  def get_document(url)
    get_doc(url)
  end

  protected

  def site_name
    self.class.name.gsub(/ScraperService$/, "")
  end

  def build_page_url(path, page)
    "#{path}?pagina=#{page}"
  end

  def card_parser_class
    "#{self.class.name}CardParser".constantize
  end

  def property_details_extractor
    "#{self.class.name}PropertyDetailsExtractor".constantize.new(self)
  end

  private

  def parse_list(doc, categoria)
    doc.css(".ltn__product-item").map { |item| parse_item(item, categoria) }.compact
  end

  def parse_item(node, categoria_hint)
    basic_info = card_parser_class.new(node, categoria_hint, self).parse
    return nil if basic_info[:titulo].nil? && basic_info[:link].nil?

    basic_info.merge(site: site_identifier)
  end

  def site_identifier
    self.class.name.underscore.gsub(/_scraper_service$/, "")
  end

  def get_doc(relative_or_absolute_url)
    url = relative_or_absolute_url.to_s
    if url.start_with?("http://", "https://")
      res = @conn.get(url, nil, DEFAULT_HEADERS)
    else
      res = @conn.get(relative_or_absolute_url, nil, DEFAULT_HEADERS)
    end
    Nokogiri::HTML(res.body)
  rescue Faraday::Error => e
    warn "[Scraper] erro ao buscar #{relative_or_absolute_url}: #{e.class} - #{e.message}"
    Nokogiri::HTML("")
  end

  def absolutize(href)
    URI.join(@base_url, href).to_s
  rescue
    href
  end

  def squish(str)
    return nil if str.nil?
    str.gsub(/\s+/, " ").strip
  end

  def parse_brl(text)
    return nil if text.nil? || text.empty?

    if text.match?(/consulte/i)
      return nil
    end

    if text.match?(/(\d+)x\s+de\s+R?\$?\s*([\d\.,]+)/i)
      match = text.match(/(\d+)x\s+de\s+R?\$?\s*([\d\.,]+)/i)
      installments = match[1]
      price_part = match[2]
      price_value = parse_decimal(price_part)
      return { value: price_value, installments: installments }
    end

    clean = text.gsub(/[^\d\.,]/, "").strip
    price_value = parse_decimal(clean)
    price_value
  end

  def parse_decimal(num_str)
    return nil if num_str.nil?
    s = num_str.to_s.strip
    s = s.gsub(/[^\d\.,]/, "")

    if s.include?(",") && s.include?(".")
      s = s.delete(".").sub(",", ".")
    elsif s.include?(",")
      s = s.sub(",", ".")
    end

    Float(s)
  rescue
    nil
  end

  def polite_sleep
    sleep(@pause + rand * 0.4)
  end

  def normalize_vagas_range(texto)
    return [nil, nil] if texto.nil? || texto.empty?

    case texto.to_s
    when /(\d+)\s*[-a]\s*(\d+)/
      [$1.to_i, $2.to_i]
    when /(\d+)\s+ou\s+(\d+)/
      [$1.to_i, $2.to_i]
    when /(\d+)/
      num = $1.to_i
      [num, num]
    else
      [nil, nil]
    end
  end
end
