class RealstateScrapperService
  def test
    # 1) Baixar o HTML da página
    url = "https://erechimimoveis.com.br/"
    response = Faraday.get(url)

    # 2) Transformar o HTML em um objeto Nokogiri
    doc = Nokogiri::HTML(response.body)

    # 3) Selecionar as tags que você quer (ajuste o seletor CSS)
    doc.css(".bloco.miniatura-lancamento").each do |bloco|
      titulo = bloco.at_css(".miniatura-titulo p")&.text&.strip
      rua = bloco.at_css(".miniatura_rua")&.text&.strip
      preco = bloco.at_css(".miniatura-preco span")&.text&.strip

      puts "Imóvel: #{titulo}"
      puts "Endereço: #{rua}"
      puts "Preço: #{preco}"
      puts "-" * 40
    end
  end
end
