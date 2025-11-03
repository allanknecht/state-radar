<template>
  <div class="imoveis-container">
    <!-- Header -->
    <AppHeader 
      @logout="sair"
    />

    <!-- Barra de Filtros e Busca -->
    <div class="filters-container">
      <!-- Busca por Texto -->
      <div class="search-section">
        <div class="search-box">
          <svg class="search-icon" viewBox="0 0 24 24" width="20" height="20">
            <path fill="currentColor" d="M9.5,3A6.5,6.5 0 0,1 16,9.5C16,11.11 15.41,12.59 14.44,13.73L14.71,14H15.5L20.5,19L19,20.5L14,15.5V14.71L13.73,14.44C12.59,15.41 11.11,16 9.5,16A6.5,6.5 0 0,1 3,9.5A6.5,6.5 0 0,1 9.5,3M9.5,5C7,5 5,7 5,9.5C5,12 7,14 9.5,14C12,14 14,12 14,9.5C14,7 12,5 9.5,5Z"/>
          </svg>
          <input
            v-model="searchText"
            @input="handleSearchText"
            type="text"
            placeholder="Buscar por código, nome, localização..."
            class="search-input"
          />
          <button v-if="searchText" @click="clearSearch" class="clear-search">
            <svg viewBox="0 0 24 24" width="16" height="16">
              <path fill="currentColor" d="M19,6.41L17.59,5L12,10.59L6.41,5L5,6.41L10.59,12L5,17.59L6.41,19L12,13.41L17.59,19L19,17.59L13.41,12L19,6.41Z"/>
            </svg>
          </button>
        </div>
        <div v-if="searchText" class="search-results-info">
          <span v-if="searching" class="searching-indicator">
            <svg class="searching-spinner" viewBox="0 0 24 24" width="16" height="16">
              <path fill="currentColor" d="M12,4V2A10,10 0 0,0 2,12H4A8,8 0 0,1 12,4Z">
                <animateTransform attributeName="transform" type="rotate" dur="1s" repeatCount="indefinite" values="0 12 12;360 12 12"/>
              </path>
            </svg>
            Buscando...
          </span>
          <span v-else>
            {{ searchResultsCount }} resultado(s) para "{{ searchText }}"
          </span>
        </div>
      </div>

      <!-- Filtros Avançados -->
      <div class="advanced-filters-section">
        <AdvancedFilters
          v-model:minPrice="minPrice"
          v-model:maxPrice="maxPrice"
          v-model:minBedrooms="minBedrooms"
          v-model:sortBy="sortBy"
          v-model:selectedSite="selectedSite"
          v-model:selectedCategory="selectedCategory"
          :available-sites="availableSites"
          :available-categories="availableCategories"
          @apply="handleSearch"
        />
      </div>
    </div>

    <!-- Loading e Error States -->
    <div v-if="loading" class="loading-state">
      <div class="spinner"></div>
      <p>Carregando imóveis...</p>
    </div>
    
    <div v-if="error" class="error-state">
      <p>{{ error }}</p>
    </div>

    <!-- Grid de Imóveis -->
    <div v-if="!loading && !error && filteredImoveis.length > 0" class="imoveis-grid" :class="{ 'searching': isSearching }">
      <ImovelCard 
        v-for="imovel in filteredImoveis" 
        :key="imovel.id" 
        :imovel="imovel"
        @openModal="openModal"
        @favorite-changed="handleFavoriteChanged"
      />
      <!-- Overlay de busca -->
      <div v-if="isSearching" class="search-overlay">
        <div class="search-overlay-content">
          <svg class="search-overlay-spinner" viewBox="0 0 24 24" width="24" height="24">
            <path fill="currentColor" d="M12,4V2A10,10 0 0,0 2,12H4A8,8 0 0,1 12,4Z">
              <animateTransform attributeName="transform" type="rotate" dur="1s" repeatCount="indefinite" values="0 12 12;360 12 12"/>
            </path>
          </svg>
          <span>Atualizando resultados...</span>
        </div>
      </div>
    </div>

    <!-- Paginação -->
    <PaginationComponent
      v-if="!loading && !error && filteredImoveis.length > 0 && totalPages > 1"
      :current-page="currentPage"
      :total-pages="totalPages"
      :total-count="totalCount"
      @page-change="handlePageChange"
    />

    <!-- Empty State -->
    <div v-else-if="!loading && !error && filteredImoveis.length === 0 && totalCount === 0" class="empty-state">
      <svg class="empty-icon" viewBox="0 0 24 24" width="64" height="64">
        <path fill="currentColor" d="M10 20v-6h4v6h5v-8h3L12 3 2 12h3v8z"/>
      </svg>
      <h3>Nenhum imóvel encontrado</h3>
      <p>Tente ajustar os filtros ou buscar por outros termos.</p>
    </div>

    <!-- Modal de Detalhes -->
    <ImovelModal 
      :imovel="selectedImovel" 
      @close="closeModal" 
    />
  </div>
</template>

<script setup>
import { ref, onMounted, computed } from 'vue'
import api from '../lib/api'
import { useAuthStore } from '../stores/auth'
import { useRouter } from 'vue-router'
import AppHeader from '../components/AppHeader.vue'
import ImovelCard from '../components/ImovelCard.vue'
import ImovelModal from '../components/ImovelModal.vue'
import AdvancedFilters from '../components/AdvancedFilters.vue'
import PaginationComponent from '../components/PaginationComponent.vue'

const router = useRouter()
const auth = useAuthStore()
const imoveis = ref([])
const loading = ref(false)
const searching = ref(false)
const error = ref('')
const selectedImovel = ref(null)

// Estado de paginação
const currentPage = ref(1)
const totalPages = ref(1)
const totalCount = ref(0)
const perPage = ref(20)

// Dados dinâmicos
const availableSites = ref([])
const availableCategories = ref([])

const selectedCategory = ref('')
const selectedSite = ref('')

const minPrice = ref('')
const maxPrice = ref('')
const minBedrooms = ref('')
const sortBy = ref('')

// Busca por texto
const searchText = ref('')
const searchTimeout = ref(null)
const isSearching = ref(false)

// Agora a filtragem é feita no backend, então usamos imoveis diretamente
const filteredImoveis = computed(() => imoveis.value)

function handleSearch() {
  currentPage.value = 1
  fetchImoveis()
}

function handlePageChange(page) {
  currentPage.value = page
  fetchImoveis()
  // Scroll para o topo da página
  window.scrollTo({ top: 0, behavior: 'smooth' })
}

// Funções de busca por texto
function handleSearchText() {
  // Limpar timeout anterior se existir
  if (searchTimeout.value) {
    clearTimeout(searchTimeout.value)
  }
  
  // Mostrar indicador de busca
  searching.value = true
  isSearching.value = true
  
  // Aguardar 500ms após o usuário parar de digitar
  searchTimeout.value = setTimeout(() => {
    currentPage.value = 1
    fetchImoveis()
  }, 500)
}

function clearSearch() {
  // Limpar timeout se existir
  if (searchTimeout.value) {
    clearTimeout(searchTimeout.value)
  }
  
  searching.value = false
  isSearching.value = false
  searchText.value = ''
  currentPage.value = 1
  fetchImoveis()
}

const searchResultsCount = computed(() => {
  if (!searchText.value) return totalCount.value
  return filteredImoveis.value.length
})

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

async function fetchImoveis() {
  loading.value = true
  error.value = ''
  try {
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
    
    // Busca por texto
    if (searchText.value) {
      params.append('search', searchText.value)
    }
    
    // Ordenação
    if (sortBy.value) {
      params.append('sort', sortBy.value)
    }
    
    // Paginação
    params.append('page', currentPage.value.toString())
    
    const queryString = params.toString()
    const url = queryString ? `/scraper_records?${queryString}` : '/scraper_records'
    
    console.log('Fazendo requisição para:', url)
    
    const { data } = await api.get(url)
    
    // O backend retorna { data: [...], meta: {...} }
    imoveis.value = data.data || []
    
    // Atualizar informações de paginação
    if (data.meta) {
      currentPage.value = data.meta.page || 1
      totalPages.value = data.meta.total_pages || 1
      totalCount.value = data.meta.total_count || 0
      perPage.value = data.meta.per || 20
    }
    
    console.log('Dados recebidos:', {
      imoveis: imoveis.value.length,
      filteredImoveis: filteredImoveis.value.length,
      meta: data.meta,
      pagination: {
        currentPage: currentPage.value,
        totalPages: totalPages.value,
        totalCount: totalCount.value,
        perPage: perPage.value
      },
      filtros: {
        category: selectedCategory.value,
        site: selectedSite.value,
        minPrice: minPrice.value,
        maxPrice: maxPrice.value,
        minBedrooms: minBedrooms.value,
        sort: sortBy.value,
        search: searchText.value
      }
    })
    
  } catch (e) {
    console.error('Erro ao buscar dados da API:', e.message)
    error.value = 'Erro ao carregar imóveis. Tente novamente.'
    imoveis.value = []
    
    // Reset paginação
    currentPage.value = 1
    totalPages.value = 1
    totalCount.value = 0
    perPage.value = 20
  } finally {
    loading.value = false
    searching.value = false
    isSearching.value = false
  }
}



function sair() {
  auth.logout()
  router.push({ name: 'login' })
}

function openModal(imovel) {
  selectedImovel.value = imovel
}

function closeModal() {
  selectedImovel.value = null
}

function handleFavoriteChanged({ id, is_favorited }) {
  // Atualizar o estado do favorito no imóvel correspondente
  const imovel = imoveis.value.find(i => i.id === id)
  if (imovel) {
    imovel.is_favorited = is_favorited
  }
}

onMounted(async () => {
  // Carregar dados dinâmicos primeiro
  await Promise.all([
    fetchSites(),
    fetchCategories()
  ])
  // Depois carregar os imóveis
  await fetchImoveis()
})
</script>

<style scoped>
.imoveis-container {
  max-width: 1200px;
  margin: 0 auto;
  padding: 0 20px;
  box-sizing: border-box;
}



/* Botões */
.btn {
  padding: 12px 24px;
  border: none;
  border-radius: 8px;
  font-size: 16px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s ease;
  text-decoration: none;
  display: inline-flex;
  align-items: center;
  gap: 8px;
}

.btn:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

.btn-primary {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
}

.btn-primary:hover:not(:disabled) {
  transform: translateY(-2px);
  box-shadow: 0 8px 25px rgba(102, 126, 234, 0.3);
}

.btn-secondary {
  background: #f8fafc;
  color: #374151;
  border: 2px solid #e1e5e9;
}

.btn-secondary:hover:not(:disabled) {
  background: #e1e5e9;
}

.btn-outline {
  background: transparent;
  color: white;
  border: 2px solid rgba(255,255,255,0.3);
}

.btn-outline:hover {
  background: rgba(255,255,255,0.1);
}

/* Grid de Imóveis */
.imoveis-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
  gap: 1.5rem;
  margin-bottom: 2rem;
  transition: opacity 0.3s ease;
}

.imoveis-grid.searching {
  opacity: 0.7;
  pointer-events: none;
  position: relative;
}

.search-overlay {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(255, 255, 255, 0.9);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 10;
  backdrop-filter: blur(2px);
}

.search-overlay-content {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 0.75rem;
  color: #3b82f6;
  font-weight: 500;
  font-size: 14px;
}

.search-overlay-spinner {
  animation: spin 1s linear infinite;
}

/* Estados de Loading e Error */
.loading-state, .error-state, .empty-state {
  text-align: center;
  padding: 4rem 2rem;
}

.spinner {
  width: 40px;
  height: 40px;
  border: 4px solid #e1e5e9;
  border-top: 4px solid #667eea;
  border-radius: 50%;
  animation: spin 1s linear infinite;
  margin: 0 auto 1rem;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}

.error-state {
  color: #dc2626;
  background: #fef2f2;
  border: 1px solid #fecaca;
  border-radius: 8px;
}

.empty-state {
  color: #6b7280;
}

.empty-icon {
  color: #d1d5db;
  margin-bottom: 1rem;
}

/* Responsividade */
@media (max-width: 768px) {
  .imoveis-container {
    padding: 0 16px;
  }
  
  
  
  .imoveis-grid {
    grid-template-columns: 1fr;
    gap: 1rem;
  }
  
  .imovel-details {
    flex-direction: column;
    gap: 0.5rem;
  }
}

@media (max-width: 480px) {
  .imovel-content {
    padding: 1rem;
  }
  
  .imovel-title {
    font-size: 1.1rem;
  }
  
  .price-value {
    font-size: 1.25rem;
  }
}

/* Container de Filtros e Busca */
.filters-container {
  display: flex;
  align-items: flex-start;
  gap: 2rem;
  margin: 1.5rem 0;
  padding: 0 1rem;
  flex-wrap: wrap;
}

.search-section {
  flex: 1;
  min-width: 300px;
}

.advanced-filters-section {
  flex-shrink: 0;
}

.search-box {
  position: relative;
  max-width: 500px;
}

.search-input {
  width: 100%;
  padding: 12px 48px 12px 48px;
  border: 2px solid #e5e7eb;
  border-radius: 8px;
  font-size: 16px;
  font-family: var(--font-primary);
  background: white;
  transition: border-color 0.2s ease;
}

.search-input:focus {
  outline: none;
  border-color: #3b82f6;
  box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.1);
}

.search-icon {
  position: absolute;
  left: 16px;
  top: 50%;
  transform: translateY(-50%);
  color: #6b7280;
  pointer-events: none;
}

.clear-search {
  position: absolute;
  right: -80px;
  top: 56%;
  transform: translateY(-50%);
  background: none;
  border: none;
  color: #6b7280;
  cursor: pointer;
  padding: 4px;
  border-radius: 4px;
  transition: color 0.2s ease;
  height: 24px;
}

.clear-search:hover {
  color: #374151;
  background: #f3f4f6;
}

.search-results-info {
  text-align: center;
  margin-top: 0.5rem;
  color: #6b7280;
  font-size: 14px;
  font-family: var(--font-primary);
}

.searching-indicator {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 0.5rem;
  color: #3b82f6;
  font-weight: 500;
}

.searching-spinner {
  animation: spin 1s linear infinite;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}

@media (max-width: 768px) {
  .filters-container {
    flex-direction: column;
    gap: 1rem;
    margin: 1rem 0;
    padding: 0 0.5rem;
  }
  
  .search-section {
    min-width: auto;
    width: 100%;
  }
  
  .search-box {
    max-width: none;
  }
  
  .search-input {
    padding: 10px 44px 10px 44px;
    font-size: 14px;
  }
  
  .search-icon {
    left: 14px;
    width: 16px;
    height: 16px;
  }
  
  .clear-search {
    right: 10px;
  }
}

</style>
