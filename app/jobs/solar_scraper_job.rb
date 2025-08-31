require "digest/sha1"

class SolarScraperJob < ApplicationJob
  queue_as :default

  def perform
    solar = SolarScraperService.new
    %i[locacao venda].each do |cat|
      solar.scrape_category(cat, fetch_details: true) do |r|
        upsert_record!(r)
      end
    end
  end

  private

  #
  # Normalizações e utilitários
  #
  def normalize_categoria(value)
    v = value.to_s.downcase
    case v
    when "locação", "locacao", ":locacao", "aluguel", "rent", "rental" then "Locação"
    when "venda", ":venda", "sale" then "Venda"
    else
      # mantém se já veio correto ou nil
      ["Locação", "Venda"].include?(value) ? value : nil
    end
  end

  def ensure_float(v)
    return nil if v.nil?
    return v if v.is_a?(Numeric)
    s = v.to_s.strip
    s = s.gsub(/[^\d\.,-]/, "")
    if s.include?(",") && s.include?(".")
      s = s.delete(".").sub(",", ".")
    elsif s.include?(",")
      s = s.sub(",", ".")
    end
    Float(s) rescue nil
  end

  def amenities_union(current, incoming)
    return current if incoming.nil? || !incoming.is_a?(Array) || incoming.empty?
    (Array(current) | incoming).compact.uniq
  end

  def required_present?(r, code)
    missing = []
    missing << "site" if r[:site].to_s.strip.empty?
    missing << "link" if r[:link].to_s.strip.empty?
    missing << "codigo" if code.to_s.strip.empty?
    missing
  end

  def upsert_record!(r)
    # Preenche site se não vier
    r[:site] ||= "solarimoveis"

    # Normaliza categoria
    r[:categoria] = normalize_categoria(r[:categoria])

    # Gera/normaliza código
    fallback_hash = Digest::SHA1.hexdigest(r[:link].to_s)[0, 16]
    code = r[:codigo].presence || fallback_hash

    # Regras mínimas
    missing = required_present?(r, code)
    if missing.any?
      warn "[SolarJob] SKIP: faltando #{missing.join(", ")} (link=#{r[:link].inspect})"
      return
    end

    rec = ScraperRecord.find_or_initialize_by(site: r[:site], codigo: code, categoria: r[:categoria])

    # Garantir tipos numéricos
    preco_brl = ensure_float(r[:preco_brl])
    condominio = ensure_float(r[:condominio])
    iptu = ensure_float(r[:iptu])
    area_m2 = ensure_float(r[:area_m2])
    area_priv = ensure_float(r[:area_privativa_m2])

    rec.assign_attributes(
      categoria: r[:categoria],
      titulo: r[:titulo].to_s.strip.presence,
      localizacao: r[:localizacao].to_s.strip.presence,
      link: r[:link].to_s.strip,
      imagem: r[:imagem].to_s.strip.presence,
      preco_brl: preco_brl,
      dormitorios: (r[:dormitorios].presence && r[:dormitorios].to_i),
      suites: (r[:suites].presence && r[:suites].to_i),
      vagas: (r[:vagas].presence && r[:vagas].to_i),
      area_m2: area_m2,
      condominio: condominio,
      iptu: iptu,
      banheiros: (r[:banheiros].presence && r[:banheiros].to_i),
      lavabos: (r[:lavabos].presence && r[:lavabos].to_i),
      area_privativa_m2: area_priv,
      mobiliacao: r[:mobiliacao].presence && r[:mobiliacao].to_s.strip,
      vagas_min: (r[:vagas_min].presence && r[:vagas_min].to_i),
      vagas_max: (r[:vagas_max].presence && r[:vagas_max].to_i),
      descricao: r[:descricao].presence && r[:descricao].to_s.strip,
    )

    # amenities (jsonb array)
    rec.amenities = amenities_union(rec.amenities, r[:amenities])

    rec.save!
    warn "[SolarJob] UPSERT OK site=#{r[:site]} cat=#{rec.categoria} code=#{code}"
    rec
  rescue ActiveRecord::RecordInvalid => e
    warn "[SolarJob] VALIDATION FAIL site=#{r[:site]} code=#{code} -> #{e.record.errors.full_messages.join("; ")}"
  rescue => e
    warn "[SolarJob] UPSERT FAIL site=#{r[:site]} code=#{code} -> #{e.class}: #{e.message}"
  end
end
