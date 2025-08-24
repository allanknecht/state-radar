# app/jobs/scraper_job.rb
require "digest/sha1"

class ScraperJob < ApplicationJob
  queue_as :default

  def perform
    simao = SimaoScraperService.new
    %i[locacao venda].each do |cat|
      simao.scrape_category(cat, fetch_details: true) do |r|
        upsert_record!(r)
      end
    end
  end

  private

  def upsert_record!(r)
    code = r[:codigo].presence || Digest::SHA1.hexdigest(r[:link].to_s)[0, 16]

    rec = ScraperRecord.find_or_initialize_by(site: r[:site], codigo: code)
    rec.assign_attributes(
      categoria: r[:categoria],
      titulo: r[:titulo],
      localizacao: r[:localizacao],
      link: r[:link],
      imagem: r[:imagem],
      preco_brl: r[:preco_brl],
      dormitorios: r[:dormitorios],
      suites: r[:suites],
      vagas: r[:vagas],
      area_m2: r[:area_m2],
      condominio: r[:condominio],
      iptu: r[:iptu],
      banheiros: r[:banheiros],
      lavabos: r[:lavabos],
      area_privativa_m2: r[:area_privativa_m2],
      mobiliacao: r[:mobiliacao],
      vagas_min: r[:vagas_min],
      vagas_max: r[:vagas_max],
      descricao: r[:descricao],
    )

    # amenities é array (jsonb). Se vier de algum site, usa; senão mantém o atual.
    if r[:amenities].is_a?(Array) && r[:amenities].any?
      rec.amenities = (rec.amenities || []) | r[:amenities] # união sem duplicar
    end

    rec.save!
    rec
  rescue => e
    warn "[ScraperJob] upsert falhou (site=#{r[:site]} code=#{code}): #{e.class} - #{e.message}"
  end
end
