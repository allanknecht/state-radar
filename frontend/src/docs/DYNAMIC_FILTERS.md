# Filtros Dinâmicos - Implementação

## Visão Geral

O sistema agora carrega dinamicamente os sites e categorias disponíveis da API, tornando os filtros mais flexíveis e mantendo-os sempre atualizados com os dados reais do backend.

## Endpoints da API

### 1. Sites Disponíveis
```
GET /api/v1/scraper_records/sites
```

**Resposta:**
```json
{
  "data": ["mws", "simao", "outros"]
}
```

### 2. Categorias Disponíveis
```
GET /api/v1/scraper_records/categories
```

**Resposta:**
```json
{
  "data": ["Venda", "Aluguel"]
}
```

## Implementação no Frontend

### ListView.vue

```javascript
// Dados dinâmicos
const availableSites = ref([])
const availableCategories = ref([])

// Funções para buscar dados
async function fetchSites() {
  try {
    const { data } = await api.get('/scraper_records/sites')
    availableSites.value = data.data || []
  } catch (e) {
    console.warn('Erro ao buscar sites, usando valores padrão:', e.message)
    availableSites.value = ['mws', 'simao', 'outros']
  }
}

async function fetchCategories() {
  try {
    const { data } = await api.get('/scraper_records/categories')
    availableCategories.value = data.data || []
  } catch (e) {
    console.warn('Erro ao buscar categorias, usando valores padrão:', e.message)
    availableCategories.value = ['Venda', 'Aluguel']
  }
}

// Carregamento inicial
onMounted(async () => {
  await Promise.all([
    fetchSites(),
    fetchCategories()
  ])
  fetchImoveis()
})
```

### AdvancedFilters.vue

```vue
<template>
  <div class="filter-row">
    <!-- Categoria -->
    <select v-model="selectedCategory" @change="updateFilters">
      <option value="">Todas as categorias</option>
      <option v-for="category in availableCategories" :key="category" :value="category">
        {{ category }}
      </option>
    </select>
    
    <!-- Site -->
    <select v-model="selectedSite" @change="updateFilters">
      <option value="">Todos os sites</option>
      <option v-for="site in availableSites" :key="site" :value="site">
        {{ formatSiteName(site) }}
      </option>
    </select>
  </div>
</template>

<script setup>
// Função para formatar nomes dos sites
function formatSiteName(site) {
  const siteNames = {
    'mws': 'MWS',
    'simao': 'Imobiliária Simão',
    'outros': 'Outros',
    'solar': 'Solar Imóveis'
  }
  return siteNames[site] || site
}

const props = defineProps({
  availableSites: {
    type: Array,
    default: () => []
  },
  availableCategories: {
    type: Array,
    default: () => []
  }
})
</script>
```

## Fluxo de Funcionamento

1. **Carregamento Inicial**: ListView faz requisições paralelas para `/sites` e `/categories`
2. **Fallback**: Se a API falhar, usa valores padrão hardcoded
3. **Renderização**: Componentes recebem os dados via props e renderizam as opções
4. **Filtragem**: Usuário seleciona filtros e faz nova requisição com parâmetros

## Vantagens

### ✅ **Flexibilidade**
- Novos sites/categorias aparecem automaticamente
- Não precisa atualizar o frontend manualmente

### ✅ **Manutenibilidade**
- Centralizado no backend
- Menos código duplicado

### ✅ **Robustez**
- Fallback para valores padrão se API falhar
- Carregamento assíncrono não bloqueia a interface

### ✅ **Performance**
- Requisições paralelas no carregamento inicial
- Cache implícito dos dados durante a sessão

## Tratamento de Erros

```javascript
try {
  const { data } = await api.get('/scraper_records/sites')
  availableSites.value = data.data || []
} catch (e) {
  console.warn('Erro ao buscar sites, usando valores padrão:', e.message)
  // Fallback para garantir que a aplicação continue funcionando
  availableSites.value = ['mws', 'simao', 'outros']
}
```

## Considerações Futuras

1. **Cache**: Implementar cache local para evitar requisições desnecessárias
2. **Refresh**: Botão para atualizar lista de sites/categorias
3. **Loading States**: Indicadores de carregamento para os filtros
4. **Validação**: Validar se os dados recebidos estão no formato esperado
