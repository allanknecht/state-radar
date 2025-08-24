# app/services/simao_scraper_service.rb
require "nokogiri"

class SimaoScraperService < BaseScraperService
  BASE_URL = "https://www.simaoimoveis.com.br/".freeze

  # categorias aceitas: :venda, :locacao
  PATHS = {
    venda: "imoveis-para-venda.php",
    locacao: "imoveis-para-locacao.php",
  }.freeze

  def initialize(max_retries: 3, pause: 0.5)
    super(base_url: BASE_URL, max_retries: max_retries, pause: pause)
  end

  # ----------------------------------------------------------------
  # Lista imóveis de uma categoria e (opcionalmente) já completa com detalhes
  # ----------------------------------------------------------------
  # Uso:
  #   scrape_category(:venda, max_pages: 5) { |record| ... }  # stream (yield)
  #   arr = scrape_category(:locacao, max_pages: 2)           # retorna array
  #
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
            more = fetch_details(base[:link])
            base.merge!(more) # detalhe > card
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

  # ----------------------------------------------------------------
  # PÁGINA DE DETALHES (completa os campos do schema, quando existirem)
  # ----------------------------------------------------------------
  def fetch_details(url)
    doc = get_doc(url)

    # título
    titulo = squish(doc.at_css("h1")&.text)

    # categoria
    categoria = doc.css(".ltn__blog-meta .ltn__blog-category a")
                   .map { |a| squish(a.text) }
                   .find { |t| t =~ /venda|loca/i }
    categoria = case categoria&.downcase
      when /venda/ then "Venda"
      when /loca/ then "Locação"
      end

    # código "Cód: 1231"
    cod_txt = doc.css(".ltn__blog-meta .ltn__blog-category a")
                 .map { |a| squish(a.text) }
                 .find { |t| t =~ /c[oó]d\s*:/i }
    codigo = cod_txt&.match(/(\d+)/)&.captures&.first

    # endereço (label após h1)
    endereco = squish(doc.at_css("h1 ~ label")&.text)

    # preço "Valor do imóvel: R$ ..."
    preco_brl = begin
        h4 = doc.css("h4").find { |n| n.text =~ /valor do im[óo]vel/i }
        txt = squish(h4&.text)
        parse_brl(txt) || parse_brl(txt&.sub(/.*valor do im[óo]vel:\s*/i, ""))
      end

    # pares "Detalhes do imóvel" (H6 -> SMALL)
    detalhes = {}
    doc.css(".property-detail-feature-list .property-detail-feature-list-item").each do |blk|
      label = squish(blk.at_css("h6")&.text)
      value = squish(blk.at_css("small")&.text)
      next if label.to_s.empty? || value.to_s.empty?
      detalhes[label] = value
    end

    # helpers
    int_from = ->(txt) { m = txt.to_s.match(/\d+/); m && m[0].to_i }
    first_of = ->(*keys) { keys.map { |k| detalhes[k] }.compact.first }

    dormitorios = int_from.call(first_of.call("Dormitórios", "Dormitorios", "Quartos"))
    suites = int_from.call(detalhes["Suítes"] || detalhes["Suites"])
    vagas_txt = first_of.call("Garagens", "Vagas")
    vagas = int_from.call(vagas_txt)

    # novos campos
    banheiros = int_from.call(detalhes["Banheiros"])
    lavabos = int_from.call(detalhes["Lavabo"] || detalhes["Lavabos"])

    # Áreas (seção "Áreas do imóvel")
    area_total_m2 = nil
    area_construida_m2 = nil
    doc.css("h4.title-2").each do |h|
      next unless h.text =~ /[áa]reas do im[óo]vel/i
      container = h.xpath("following-sibling::*").find { |n| n["class"].to_s.include?("property-detail-feature-list") }
      container&.css(".property-detail-feature-list-item")&.each do |blk|
        k = squish(blk.at_css("h6")&.text)
        v = squish(blk.at_css("small")&.text)
        next if k.nil? || v.nil?
        if k =~ /[áa]rea total/i
          area_total_m2 = parse_decimal(v[/[\d\.,]+/])
        elsif k =~ /[áa]rea constru/i
          area_construida_m2 = parse_decimal(v[/[\d\.,]+/])
        end
      end
    end
    area_m2 = area_construida_m2 || area_total_m2

    # "Área Privativa" (outros sites podem usar esse termo)
    area_privativa_m2 = nil
    if (txt = first_of.call("Área Privativa", "Área privativa"))
      area_privativa_m2 = parse_decimal(txt[/[\d\.,]+/])
    end

    # "mobiliado / semi-mobiliado" (outros sites)
    mobiliacao = begin
        raw = (detalhes.values + [titulo]).compact.find { |v| v =~ /mobiliad/i }
        raw&.downcase # ex.: "semi-mobiliado"
      end

    # vagas_min / vagas_max quando vier "1 ou 2 Vagas" (outros sites)
    vagas_min, vagas_max = normalize_vagas_range(vagas_txt)

    # descrição longa (seção "Descrição do Imóvel") - VERSÃO CORRIGIDA
    descricao = begin
        anchor = doc.css("h4.title-2").find { |n| n.text =~ /descri[cç][aã]o do im[óo]vel/i }
        if anchor
          content_parts = []
          sib = anchor.next

          while sib
            # Para quando encontrar outro H4/título
            break if sib.name =~ /^h[1-6]$/ || sib["class"].to_s.include?("title-2")

            case sib.name
            when "p"
              text = squish(sib.text)
              content_parts << text unless text.empty?
            when "ul"
              # Processar listas
              list_items = sib.css("li").map do |li|
                item_text = squish(li.text)
                next if item_text.empty?

                # Se tem sub-lista, processar recursivamente
                if li.css("ul").any?
                  main_text = squish(li.children.select(&:text?).map(&:text).join(" "))
                  sub_items = li.css("ul li").map { |sub_li| "  - #{squish(sub_li.text)}" }.join("\n")
                  "• #{main_text}\n#{sub_items}"
                else
                  "• #{item_text}"
                end
              end.compact

              content_parts << list_items.join("\n") unless list_items.empty?
            end

            sib = sib.next
          end

          content_parts.reject(&:empty?).join("\n\n").presence
        end
      end

    # NOVA FUNCIONALIDADE: extração de amenities/características
    amenities = extract_amenities(doc)

    {
      titulo: titulo,
      categoria: categoria,
      codigo: codigo,
      localizacao: endereco,
      preco_brl: preco_brl,
      dormitorios: dormitorios,
      suites: suites,
      vagas: vagas,
      banheiros: banheiros,
      lavabos: lavabos,
      area_m2: area_m2,
      area_privativa_m2: area_privativa_m2,
      mobiliacao: mobiliacao,
      vagas_min: vagas_min,
      vagas_max: vagas_max,
      descricao: descricao,
      amenities: amenities,  # NOVO CAMPO
    }.compact
  end

  # ----------------------------------------------------------------
  # PRIVADO: helpers da listagem (cards)
  # ----------------------------------------------------------------
  private

  def parse_list(doc, categoria)
    doc.css(".ltn__product-item").map { |item| parse_item(item, categoria) }.compact
  end

  def parse_item(node, categoria_hint)
    href = node.at_css(".product-img a")&.[]("href")
    link = href ? absolutize(href) : nil
    image = node.at_css(".product-img img")&.[]("src")
    title = squish(node.at_css(".product-title a")&.text)

    # "Locação | Cód. Imóvel 5296"
    badge = squish(node.at_css(".product-badge li")&.text)
    tipo, codigo = parse_badge(badge, categoria_hint)

    location = squish(node.at_css(".product-img-location li a")&.text)

    price_txt = squish(node.at_css(".product-info-bottom .product-price")&.text)
    price = parse_brl(price_txt)

    details = parse_details(node)

    return nil if title.nil? && link.nil?

    {
      site: "simaoimoveis",
      categoria: tipo,           # "Locação" | "Venda"
      codigo: codigo,         # "5296" (string) ou nil
      titulo: title,
      localizacao: location,
      link: link,
      imagem: image,
      preco_brl: price,
      dormitorios: details[:dormitorios],
      suites: details[:suites],
      vagas: details[:vagas],
      area_m2: details[:area_m2],
      condominio: details[:condominio],
      iptu: details[:iptu],
    # os demais campos serão preenchidos no fetch_details
    }
  end

  def parse_badge(text, categoria_hint)
    tipo = if text&.match?(/loca[cç][aã]o/i)
        "Locação"
      elsif text&.match?(/venda/i)
        "Venda"
      else
        categoria_hint == :locacao ? "Locação" : (categoria_hint == :venda ? "Venda" : nil)
      end
    codigo = text&.match(/c[oó]d\.\s*im[oó]vel\s*(\d+)/i)&.captures&.first
    [tipo, codigo]
  end

  # detalhes do CARD (ícones/itens resumidos)
  def parse_details(node)
    h = { dormitorios: nil, suites: nil, vagas: nil, area_m2: nil, condominio: nil, iptu: nil }

    node.css("ul.ltn__list-item-2--- li").each do |li|
      t = squish(li.text)

      if (m = t.match(/\b(\d+)\s*Dormit[oó]rios?/i)) then h[:dormitorios] = m[1].to_i elsif (m = t.match(/\b(\d+)\s*Suites?/i)) then h[:suites] = m[1].to_i elsif (m = t.match(/\b(\d+)\s*Vagas?/i)) then h[:vagas] = m[1].to_i elsif (m = t.match(/([\d\.\,]+)\s*m²/i)) then h[:area_m2] = parse_decimal(m[1]) elsif t.match?(/condom[ií]nio/i)
        vtxt = li.at_css("span")&.text || t
        h[:condominio] = parse_brl(vtxt)
      elsif t.match?(/\biptu\b/i)
        vtxt = li.at_css("span")&.text || t
        h[:iptu] = parse_brl(vtxt)
      end
    end

    h
  end

  # "1 ou 2 Vagas" -> [1,2]; "2 ou +" -> [2,nil]; "1" -> [1,1]
  def normalize_vagas_range(texto)
    return [nil, nil] if texto.to_s.strip.empty?
    nums = texto.scan(/\d+/).map(&:to_i)
    if nums.empty?
      [nil, nil]
    elsif texto =~ /\+\s*$/
      [nums.min, nil] # "2 ou +" => min conhecido, max aberto
    elsif nums.length == 1
      [nums[0], nums[0]]
    else
      [nums.min, nums.max]
    end
  end

  # Método para extrair todas as características/amenities
  def extract_amenities(doc)
    amenities = []

    # Buscar todas as seções de características
    doc.css("h4.title-2").each do |h4|
      title = squish(h4.text)

      # Identificar seções de características
      next unless title =~ /caracter[íi]sticas/i

      # Encontrar o container seguinte com as características
      container = h4.xpath("following-sibling::*")
        .find { |n| n["class"].to_s.include?("property-details-amenities") }

      next unless container

      # Extrair cada característica individual
      container.css("label.checkbox-item").each do |label|
        text = squish(label.text)
        # Remove "input type checkbox" artifacts do texto
        clean_text = text.gsub(/input.*$/i, "").strip

        amenities << clean_text unless clean_text.empty?
      end
    end

    # Remover duplicatas e retornar array único
    amenities.uniq.sort
  end
end
