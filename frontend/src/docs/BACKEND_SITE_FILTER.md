# Implementação do Filtro de Site no Backend

## Código Necessário no Backend

Para implementar o filtro de site no backend Rails, você precisa adicionar a seguinte linha no controller `ScraperRecordsController`:

### Controller Atualizado

```ruby
module Api
  module V1
    class ScraperRecordsController < BaseController
      before_action :authenticate_api_v1_user!

      def index
        scope = ScraperRecord.all

        # filtros (só aplicam se o param existir)
        scope = scope.where(categoria: params[:category]) if params[:category].present?
        scope = scope.where(site: params[:site]) if params[:site].present?  # ← ADICIONAR ESTA LINHA

        min_price = decimal_param(:min_price)
        max_price = decimal_param(:max_price)
        min_bed = int_param(:min_bedrooms, min: 0)

        scope = scope.where("preco_brl >= ?", min_price) if min_price
        scope = scope.where("preco_brl <= ?", max_price) if max_price
        scope = scope.where("dormitorios >= ?", min_bed) if min_bed


        case params[:sort]
        when "price_asc" then scope = scope.order(preco_brl: :asc, id: :desc)
        when "price_desc" then scope = scope.order(preco_brl: :desc, id: :desc)
        else scope = scope.order(created_at: :desc, id: :desc)
        end

        # paginação: sempre 20 por página
        page = int_param(:page, default: 1, min: 1)
        records = scope.page(page).per(20)

        render json: {
          data: records.map { |r| serialize_record(r) },
          meta: {
            page: records.current_page,
            total_pages: records.total_pages,
            total_count: records.total_count,
            per: records.limit_value,
          },
        }
      end

      # ... resto do código permanece igual
    end
  end
end
```

## Sites Disponíveis

Baseado nos logs do scraper, os sites disponíveis são:

- `mws` - MWS Imóveis
- `simao` - Imobiliária Simão
- `outros` - Outros sites (quando não especificado)

## Exemplos de Uso

### Filtrar apenas imóveis do MWS
```
GET /api/v1/scraper_records?site=mws
```

### Filtrar apenas imóveis da Imobiliária Simão
```
GET /api/v1/scraper_records?site=simao
```

### Combinar filtros
```
GET /api/v1/scraper_records?site=mws&category=Venda&min_price=300000
```

## Validação (Opcional)

Se quiser validar os valores de site permitidos, pode adicionar:

```ruby
def index
  scope = ScraperRecord.all

  # filtros (só aplicam se o param existir)
  scope = scope.where(categoria: params[:category]) if params[:category].present?
  
  # Validação do filtro de site
  if params[:site].present?
    allowed_sites = ['mws', 'simao', 'outros']
    if allowed_sites.include?(params[:site])
      scope = scope.where(site: params[:site])
    end
  end

  # ... resto do código
end
```

## Testando a Implementação

Após implementar, você pode testar:

1. **Frontend**: Use o filtro de site no componente SearchFilters
2. **API direta**: Faça requisições GET com o parâmetro `site`
3. **Logs**: Verifique se os registros retornados correspondem ao site filtrado

## Benefícios

- **Performance**: Filtragem no banco de dados é mais eficiente
- **Paginação**: Funciona corretamente com filtros aplicados
- **Flexibilidade**: Fácil de expandir para novos sites
- **Consistência**: Mesma lógica de filtros em toda a aplicação
