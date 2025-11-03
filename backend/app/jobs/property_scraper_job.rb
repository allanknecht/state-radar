require "digest/sha1"

class PropertyScraperJob < ApplicationJob
  queue_as :default

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
    scraper_class_name = SCRAPER_CLASS_NAMES[scraper_name]
    raise ArgumentError, "Unknown scraper: #{scraper_name}" unless scraper_class_name

    begin
      scraper_class = scraper_class_name.constantize
    rescue NameError => e
      raise "Scraper class #{scraper_class_name} not found. Make sure the file is loaded. Error: #{e.message}"
    end

    scraper = scraper_class.new
    site_string = scraper_name.to_s

    # Rastrear registros encontrados por categoria
    found_records_by_category = {}

    %i[locacao venda].each do |categoria|
      categoria_normalizada = normalize_categoria(categoria)
      found_ids = []

      scraper.scrape_category(categoria, fetch_details: true) do |record|
        db_record = upsert_record!(record, scraper_name)
        found_ids << db_record.id if db_record
      end

      found_records_by_category[categoria_normalizada] = found_ids

      # Deletar registros que não foram encontrados para esta categoria e site
      delete_unfound_records(site_string, categoria_normalizada, found_ids)
    end
  end

  def upsert_record!(record, scraper_name)
    record[:site] ||= scraper_name.to_s

    record[:categoria] = normalize_categoria(record[:categoria])

    fallback_hash = Digest::SHA1.hexdigest(record[:link].to_s)[0, 16]
    code = record[:codigo].presence || fallback_hash

    missing = validate_required_fields(record, code)
    if missing.any?
      warn "[#{scraper_name.upcase}Job] SKIP: missing #{missing.join(", ")} (link=#{record[:link].inspect})"
      return nil
    end

    db_record = ScraperRecord.find_or_initialize_by(
      site: record[:site],
      codigo: code,
      categoria: record[:categoria],
    )

    assign_record_attributes(db_record, record)

    db_record.save!
    warn "[#{scraper_name.upcase}Job] UPSERT OK site=#{record[:site]} cat=#{db_record.categoria} code=#{code}"
    db_record
  rescue ActiveRecord::RecordInvalid => e
    warn "[#{scraper_name.upcase}Job] VALIDATION FAIL site=#{record[:site]} code=#{code} -> #{e.record.errors.full_messages.join("; ")}"
    nil
  rescue => e
    warn "[#{scraper_name.upcase}Job] UPSERT FAIL site=#{record[:site]} code=#{code} -> #{e.class}: #{e.message}"
    nil
  end

  def delete_unfound_records(site, categoria, found_ids)
    # Encontrar todos os registros do site e categoria que não foram encontrados nesta execução
    unfound_records = ScraperRecord.where(site: site, categoria: categoria)
                                   .where.not(id: found_ids)

    if unfound_records.any?
      count = unfound_records.count
      # Deletar registros - os favoritos serão deletados automaticamente devido ao cascade
      unfound_records.delete_all
      warn "[#{site.upcase}Job] DELETED #{count} records not found in scraping (site=#{site}, categoria=#{categoria})"
    end
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
      iptu_parcelas: safe_string(record[:iptu_parcelas]),
      condominio_parcelas: safe_string(record[:condominio_parcelas]),
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
