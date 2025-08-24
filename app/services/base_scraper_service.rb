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

  private

  # ----------------------
  # Utilitários compartilhados
  # ----------------------

  def get_doc(relative_or_absolute_url)
    # aceita URL relativa ("/path") OU absoluta ("https://...")
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
    clean = text.gsub(/[^\d\.,]/, "").strip
    parse_decimal(clean)
  end

  def parse_decimal(num_str)
    return nil if num_str.nil?
    s = num_str.to_s.strip
    s = s.gsub(/[^\d\.,]/, "")  # mantém só dígitos, ponto e vírgula

    if s.include?(",") && s.include?(".")
      # Ex.: "1.234,56" -> "1234.56"
      s = s.delete(".").sub(",", ".")
    elsif s.include?(",")
      # Ex.: "161,55" -> "161.55"
      s = s.sub(",", ".")
    else
      # Ex.: "161.55" (já ok)
    end

    Float(s)
  rescue
    nil
  end

  def polite_sleep
    sleep(@pause + rand * 0.4)
  end
end
