<template>
  <div class="imoveis-container">
    <!-- Header -->
    <AppHeader 
      @logout="sair"
    />

    <!-- Filtros Avançados -->
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

    <!-- Loading e Error States -->
    <div v-if="loading" class="loading-state">
      <div class="spinner"></div>
      <p>Carregando imóveis...</p>
    </div>
    
    <div v-if="error" class="error-state">
      <p>{{ error }}</p>
    </div>

    <!-- Grid de Imóveis -->
    <div v-if="filteredImoveis.length" class="imoveis-grid">
      <ImovelCard 
        v-for="imovel in filteredImoveis" 
        :key="imovel.id" 
        :imovel="imovel"
        @openModal="openModal"
      />
    </div>

    <!-- Paginação -->
    <PaginationComponent
      v-if="filteredImoveis.length && totalPages > 1"
      :current-page="currentPage"
      :total-pages="totalPages"
      :total-count="totalCount"
      @page-change="handlePageChange"
    />

    <!-- Empty State -->
    <div v-else-if="!loading && !error" class="empty-state">
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

// Filtros básicos
const selectedCategory = ref('')
const selectedSite = ref('')

// Filtros avançados
const minPrice = ref('')
const maxPrice = ref('')
const minBedrooms = ref('')
const sortBy = ref('')

// Agora a filtragem é feita no backend, então usamos imoveis diretamente
const filteredImoveis = computed(() => imoveis.value)

function handleSearch() {
  // Função chamada quando os filtros são alterados
  // Reset para a primeira página quando filtros mudam
  currentPage.value = 1
  fetchImoveis()
}

function handlePageChange(page) {
  currentPage.value = page
  fetchImoveis()
}

async function fetchSites() {
  try {
    const { data } = await api.get('/scraper_records/sites')
    availableSites.value = data.data || []
  } catch (e) {
    console.warn('Erro ao buscar sites, usando valores padrão:', e.message)
    // Fallback para valores padrão
    availableSites.value = ['mws', 'simao', 'outros']
  }
}

async function fetchCategories() {
  try {
    const { data } = await api.get('/scraper_records/categories')
    availableCategories.value = data.data || []
  } catch (e) {
    console.warn('Erro ao buscar categorias, usando valores padrão:', e.message)
    // Fallback para valores padrão
    availableCategories.value = ['Venda', 'Aluguel']
  }
}

async function fetchImoveis() {
  loading.value = true
  error.value = ''
  try {
    // Construir parâmetros de query baseados nos filtros ativos
    const params = new URLSearchParams()
    
    // Filtro de categoria
    if (selectedCategory.value) {
      params.append('category', selectedCategory.value)
    }
    
    // Filtro de site
    if (selectedSite.value) {
      params.append('site', selectedSite.value)
    }
    
    // Filtros de preço
    if (minPrice.value) {
      params.append('min_price', minPrice.value)
    }
    if (maxPrice.value) {
      params.append('max_price', maxPrice.value)
    }
    
    // Filtro de dormitórios mínimos
    if (minBedrooms.value) {
      params.append('min_bedrooms', minBedrooms.value)
    }
    
    // Ordenação
    if (sortBy.value) {
      params.append('sort', sortBy.value)
    }
    
    // Paginação
    params.append('page', currentPage.value.toString())
    
    const queryString = params.toString()
    const url = queryString ? `/scraper_records?${queryString}` : '/scraper_records'
    
    console.log('Fazendo requisição para:', url) // Debug
    
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
    
    // Log para debug (pode ser removido em produção)
    console.log('Dados recebidos:', {
      imoveis: imoveis.value.length,
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
        sort: sortBy.value
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

onMounted(async () => {
  // Carregar dados dinâmicos primeiro
  await Promise.all([
    fetchSites(),
    fetchCategories()
  ])
  // Depois carregar os imóveis
  fetchImoveis()
})
</script>

<style scoped>
.imoveis-container {
  max-width: 1400px;
  margin: 0 auto;
  padding: 0 20px;
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
  grid-template-columns: repeat(auto-fill, minmax(400px, 1fr));
  gap: 2rem;
  margin-bottom: 2rem;
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
    gap: 1.5rem;
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

</style>
