class ScrapperJob < ApplicationJob
  queue_as :default

  def perform
    scrapper = RealstateScrapperService.new
    %i[locacao venda].each do |cat|
      scrapper.scrape_category(cat) { |registry| upsert_record!(registry) }
    end
  end

  private

  def upsert_record!(r)
    code = r[:codigo].presence || Digest::SHA1.hexdigest(r[:link].to_s)[0, 16]

    rec = ScrapperRecord.find_or_initialize_by(site: r[:site], codigo: code)
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
    )
    rec.save!
  end
end
