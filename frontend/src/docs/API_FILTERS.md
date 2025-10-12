# Filtros da API - Documentação

## Parâmetros Suportados pelo Backend

O controller Rails `ScraperRecordsController` suporta os seguintes parâmetros de filtro:

### 1. Filtro por Categoria
- **Parâmetro**: `category`
- **Tipo**: String
- **Valores**: `Venda`, `Aluguel`
- **Exemplo**: `?category=Venda`

### 2. Filtro por Site
- **Parâmetro**: `site`
- **Tipo**: String
- **Valores**: `mws`, `simao`, `outros`
- **Descrição**: Filtra por fonte dos dados
- **Exemplo**: `?site=mws`

### 3. Filtro por Preço Mínimo
- **Parâmetro**: `min_price`
- **Tipo**: Decimal
- **Descrição**: Preço mínimo em BRL
- **Exemplo**: `?min_price=100000`

### 4. Filtro por Preço Máximo
- **Parâmetro**: `max_price`
- **Tipo**: Decimal
- **Descrição**: Preço máximo em BRL
- **Exemplo**: `?max_price=500000`

### 5. Filtro por Dormitórios Mínimos
- **Parâmetro**: `min_bedrooms`
- **Tipo**: Integer
- **Descrição**: Número mínimo de dormitórios
- **Exemplo**: `?min_bedrooms=2`

### 6. Ordenação
- **Parâmetro**: `sort`
- **Tipo**: String
- **Valores**: 
  - `price_asc` - Menor preço primeiro
  - `price_desc` - Maior preço primeiro
  - (padrão) - Mais recentes primeiro
- **Exemplo**: `?sort=price_asc`

### 7. Paginação
- **Parâmetro**: `page`
- **Tipo**: Integer
- **Descrição**: Número da página (padrão: 1)
- **Exemplo**: `?page=2`

## Exemplos de URLs

### Filtros Múltiplos
```
GET /api/v1/scraper_records?category=Venda&site=mws&min_price=200000&max_price=800000&min_bedrooms=2
```

### Ordenação por Preço
```
GET /api/v1/scraper_records?sort=price_asc
```

### Busca Completa
```
GET /api/v1/scraper_records?category=Aluguel&site=simao&min_price=1000&max_price=3000&min_bedrooms=1&sort=price_asc&page=1
```

## Endpoints Auxiliares

### Buscar Sites Disponíveis
```
GET /api/v1/scraper_records/sites
```

**Resposta:**
```json
{
  "data": ["mws", "simao", "outros"]
}
```

### Buscar Categorias Disponíveis
```
GET /api/v1/scraper_records/categories
```

**Resposta:**
```json
{
  "data": ["Venda", "Aluguel"]
}
```

## Resposta da API

A API retorna um objeto JSON com a seguinte estrutura:

```json
{
  "data": [
    {
      "id": 16,
      "site": "mws",
      "categoria": "Venda",
      "codigo": "328",
      "titulo": "Apartamento 2 quartos no bairro Recreio",
      "localizacao": "Rua Professor Nestor Paulo Hartmann, 1956, Recreio, 95600308, Taquara - RS",
      "link": "https://mws-rs.com.br/detalhes-imovel-venda.php?id_imovel=328",
      "imagem": "https://mount.samisistemas.com.br/vendas/Foto_4618_311558_2807.jpg?202509142154",
      "preco_brl": 630000.0,
      "dormitorios": 2,
      "suites": 1,
      "vagas": null,
      "area_m2": 81.0,
      "condominio": null,
      "iptu": null,
      "banheiros": null,
      "lavabos": null,
      "area_privativa_m2": 81.0,
      "mobiliacao": "...",
      "amenities": [],
      "descricao": "...",
      "created_at": "2025-09-14T21:43:01.645-03:00",
      "updated_at": "2025-09-14T21:43:01.645-03:00"
    }
  ],
  "meta": {
    "page": 1,
    "total_pages": 5,
    "total_count": 100,
    "per": 20
  }
}
```

## Implementação no Frontend

### Componentes Utilizados

1. **SearchFilters.vue** - Filtros básicos (busca, categoria, site)
2. **AdvancedFilters.vue** - Filtros avançados (preço, dormitórios, ordenação)
3. **ListView.vue** - Orquestra todos os filtros e faz a requisição

### Fluxo de Funcionamento

1. Usuário altera filtros nos componentes
2. Componentes emitem eventos para ListView
3. ListView constrói URL com parâmetros
4. Requisição é feita para o backend
5. Backend retorna dados filtrados
6. Frontend exibe resultados

### Exemplo de Implementação

```javascript
// Construção da URL com filtros
const params = new URLSearchParams()

if (selectedCategory.value) {
  params.append('category', selectedCategory.value)
}

if (selectedSite.value) {
  params.append('site', selectedSite.value)
}

if (minPrice.value) {
  params.append('min_price', minPrice.value)
}

if (maxPrice.value) {
  params.append('max_price', maxPrice.value)
}

if (minBedrooms.value) {
  params.append('min_bedrooms', minBedrooms.value)
}

if (sortBy.value) {
  params.append('sort', sortBy.value)
}

params.append('page', '1')

const url = `/scraper_records?${params.toString()}`
const { data } = await api.get(url)
```

## Vantagens da Implementação

1. **Performance**: Filtragem no backend é mais eficiente
2. **Paginação**: Suporte nativo a paginação
3. **Escalabilidade**: Funciona com grandes volumes de dados
4. **Flexibilidade**: Fácil adicionar novos filtros
5. **Consistência**: Mesma lógica de filtros em toda a aplicação
