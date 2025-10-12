require "digest/sha1"

class PropertyScraperJob < ApplicationJob
  queue_as :default

  # Use strings instead of class constants to avoid loading issues
  SCRAPER_CLASS_NAMES = {
    mws: "MwsScraperService",
    simao: "SimaoScraperService",
    solar: "SolarScraperService",
  }.freeze

  def perform(scraper_name = :all)
    if scraper_name == :all
      SCRAPER_CLASS_NAMES.each_key { |name| scrape_site(name) }
    else
      scrape_site(scraper_name.to_sym)
    end
  end

  private

  def scrape_site(scraper_name)
    # Lazy load the scraper class when needed
    scraper_class_name = SCRAPER_CLASS_NAMES[scraper_name]
    raise ArgumentError, "Unknown scraper: #{scraper_name}" unless scraper_class_name

    begin
      scraper_class = scraper_class_name.constantize
    rescue NameError => e
      raise "Scraper class #{scraper_class_name} not found. Make sure the file is loaded. Error: #{e.message}"
    end

    scraper = scraper_class.new
    %i[locacao venda].each do |categoria|
      scraper.scrape_category(categoria, fetch_details: true) do |record|
        upsert_record!(record, scraper_name)
      end
    end
  end

  def upsert_record!(record, scraper_name)
    # Ensure site is set
    record[:site] ||= scraper_name.to_s

    # Normalize category
    record[:categoria] = normalize_categoria(record[:categoria])

    # Generate/normalize code
    fallback_hash = Digest::SHA1.hexdigest(record[:link].to_s)[0, 16]
    code = record[:codigo].presence || fallback_hash

    # Validate required fields
    missing = validate_required_fields(record, code)
    if missing.any?
      warn "[#{scraper_name.upcase}Job] SKIP: missing #{missing.join(", ")} (link=#{record[:link].inspect})"
      return
    end

    # Find or create record
    db_record = ScraperRecord.find_or_initialize_by(
      site: record[:site],
      codigo: code,
      categoria: record[:categoria],
    )

    # Assign attributes with proper type conversion
    assign_record_attributes(db_record, record)

    db_record.save!
    warn "[#{scraper_name.upcase}Job] UPSERT OK site=#{record[:site]} cat=#{db_record.categoria} code=#{code}"
    db_record
  rescue ActiveRecord::RecordInvalid => e
    warn "[#{scraper_name.upcase}Job] VALIDATION FAIL site=#{record[:site]} code=#{code} -> #{e.record.errors.full_messages.join("; ")}"
  rescue => e
    warn "[#{scraper_name.upcase}Job] UPSERT FAIL site=#{record[:site]} code=#{code} -> #{e.class}: #{e.message}"
  end

  def assign_record_attributes(db_record, record)
    db_record.assign_attributes(
      categoria: record[:categoria],
      titulo: safe_string(record[:titulo]),
      localizacao: safe_string(record[:localizacao]),
      link: record[:link].to_s.strip,
      imagem: safe_string(record[:imagem]),
      preco_brl: ensure_float(record[:preco_brl]),
      dormitorios: safe_integer(record[:dormitorios]),
      suites: safe_integer(record[:suites]),
      vagas: safe_integer(record[:vagas]),
      area_m2: ensure_float(record[:area_m2]),
      condominio: ensure_float(record[:condominio]),
      iptu: ensure_float(record[:iptu]),
      banheiros: safe_integer(record[:banheiros]),
      lavabos: safe_integer(record[:lavabos]),
      area_privativa_m2: ensure_float(record[:area_privativa_m2]),
      mobiliacao: safe_string(record[:mobiliacao]),
      vagas_min: safe_integer(record[:vagas_min]),
      vagas_max: safe_integer(record[:vagas_max]),
      descricao: safe_string(record[:descricao]),
      amenities: merge_amenities(db_record.amenities, record[:amenities]),
    )
  end

  def normalize_categoria(value)
    case value.to_s.downcase
    when "locação", "locacao", ":locacao", "aluguel", "rent", "rental"
      "Locação"
    when "venda", ":venda", "sale"
      "Venda"
    else
      ["Locação", "Venda"].include?(value) ? value : nil
    end
  end

  def ensure_float(value)
    return nil if value.nil?
    return value if value.is_a?(Numeric)

    clean_value = value.to_s.strip.gsub(/[^\d\.,-]/, "")

    if clean_value.include?(",") && clean_value.include?(".")
      clean_value = clean_value.delete(".").sub(",", ".")
    elsif clean_value.include?(",")
      clean_value = clean_value.sub(",", ".")
    end

    Float(clean_value)
  rescue
    nil
  end

  def safe_integer(value)
    value.presence&.to_i
  end

  def safe_string(value)
    value.to_s.strip.presence
  end

  def merge_amenities(current, incoming)
    return current if incoming.nil? || !incoming.is_a?(Array) || incoming.empty?
    (Array(current) | incoming).compact.uniq
  end

  def validate_required_fields(record, code)
    missing = []
    missing << "site" if record[:site].to_s.strip.empty?
    missing << "link" if record[:link].to_s.strip.empty?
    missing << "codigo" if code.to_s.strip.empty?
    missing
  end
end
