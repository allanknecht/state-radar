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

  # Ex.: scrape_category(:locacao, max_pages: 50)
  # Se passar um bloco, faz yield por imóvel; caso contrário, retorna array
  def scrape_category(categoria, max_pages: nil)
    path = PATHS.fetch(categoria) { raise ArgumentError, "categoria inválida: #{categoria}" }

    results = []
    page = 1
    loop do
      break if max_pages && page > max_pages

      url = "#{path}?&pagina=#{page}"
      doc = get_doc(url)
      items = parse_list(doc, categoria)
      break if items.empty?

      if block_given?
        items.each { |item| yield item }
      else
        results.concat(items)
      end

      page += 1
      polite_sleep
    end

    results
  end

  private

  def parse_list(doc, categoria)
    doc.css(".ltn__product-item").map do |item|
      parse_item(item, categoria)
    end.compact
  end

  def parse_item(node, categoria_hint)
    # Link e imagem
    link_el = node.at_css(".product-img a")
    href = link_el&.[]("href")
    link = href ? absolutize(href) : nil

    img_el = node.at_css(".product-img img")
    image = img_el&.[]("src")

    # Título
    title_el = node.at_css(".product-title a")
    title = squish(title_el&.text)

    # Badge com "Locação | Cód. Imóvel 5296"
    badge = squish(node.at_css(".product-badge li")&.text)
    tipo, codigo = parse_badge(badge, categoria_hint)

    # Localização
    location = squish(node.at_css(".product-img-location li a")&.text)

    # Preço
    price_txt = squish(node.at_css(".product-info-bottom .product-price")&.text)
    price = parse_brl(price_txt)

    # Detalhes
    details = parse_details(node)

    return nil if title.nil? && link.nil?

    {
      site: "simaoimoveis",
      categoria: tipo,                # "Locação" | "Venda"
      codigo: codigo,              # "5296" (string) ou nil
      titulo: title,
      localizacao: location,
      link: link,
      imagem: image,
      preco_brl: price,               # Float
      dormitorios: details[:dormitorios],
      suites: details[:suites],
      vagas: details[:vagas],
      area_m2: details[:area_m2],
      condominio: details[:condominio],
      iptu: details[:iptu],
    }
  end

  def parse_badge(text, categoria_hint)
    # Exemplos:
    # "Locação | Cód. Imóvel 5296"
    # "Venda | Cód. Imóvel 1234"
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

  def parse_details(node)
    h = { dormitorios: nil, suites: nil, vagas: nil, area_m2: nil, condominio: nil, iptu: nil }

    node.css("ul.ltn__list-item-2--- li").each do |li|
      t = squish(li.text)

      if (m = t.match(/\b(\d+)\s*Dormit[oó]rios?/i))
        h[:dormitorios] = m[1].to_i
      elsif (m = t.match(/\b(\d+)\s*Suites?/i))
        h[:suites] = m[1].to_i
      elsif (m = t.match(/\b(\d+)\s*Vagas?/i))
        h[:vagas] = m[1].to_i
      elsif (m = t.match(/([\d\.\,]+)\s*m²/i))
        h[:area_m2] = parse_decimal(m[1])
      elsif t.match?(/condom[ií]nio/i)
        vtxt = li.at_css("span")&.text || t
        h[:condominio] = parse_brl(vtxt)
      elsif t.match?(/\biptu\b/i)
        vtxt = li.at_css("span")&.text || t
        h[:iptu] = parse_brl(vtxt)
      end
    end

    h
  end
end
