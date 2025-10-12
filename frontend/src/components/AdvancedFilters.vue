<template>
  <div class="advanced-filters">
    <div class="filters-header">
      <h3>Filtros Avançados</h3>
      <button @click="toggleAdvanced" class="toggle-btn">
        {{ showAdvanced ? 'Ocultar' : 'Mostrar' }} Filtros
      </button>
    </div>
    
    <div v-if="showAdvanced" class="filters-content">
      <div class="filter-row">
        <div class="filter-group">
          <label>Preço Mínimo:</label>
          <input 
            v-model="minPrice" 
            type="number" 
            placeholder="Ex: 100000"
            class="filter-input"
            @input="updateFilters"
          >
        </div>
        
        <div class="filter-group">
          <label>Preço Máximo:</label>
          <input 
            v-model="maxPrice" 
            type="number" 
            placeholder="Ex: 500000"
            class="filter-input"
            @input="updateFilters"
          >
        </div>
      </div>
      
      <div class="filter-row">
        <div class="filter-group">
          <label>Categoria:</label>
          <select v-model="selectedCategory" class="filter-select" @change="updateFilters">
            <option value="">Todas as categorias</option>
            <option 
              v-for="category in availableCategories" 
              :key="category" 
              :value="category"
            >
              {{ category }}
            </option>
          </select>
        </div>
        
        <div class="filter-group">
          <label>Site:</label>
          <select v-model="selectedSite" class="filter-select" @change="updateFilters">
            <option value="">Todos os sites</option>
            <option 
              v-for="site in availableSites" 
              :key="site" 
              :value="site"
            >
              {{ formatSiteName(site) }}
            </option>
          </select>
        </div>
        
        <div class="filter-group">
          <label>Mín. Dormitórios:</label>
          <select v-model="minBedrooms" class="filter-select" @change="updateFilters">
            <option value="">Qualquer</option>
            <option value="1">1+</option>
            <option value="2">2+</option>
            <option value="3">3+</option>
            <option value="4">4+</option>
          </select>
        </div>
        
        <div class="filter-group">
          <label>Ordenar por:</label>
          <select v-model="sortBy" class="filter-select" @change="updateFilters">
            <option value="">Mais recentes</option>
            <option value="price_asc">Menor preço</option>
            <option value="price_desc">Maior preço</option>
          </select>
        </div>
      </div>
      
      <div class="filter-actions">
        <button @click="clearFilters" class="btn btn-secondary">Limpar Filtros</button>
        <button @click="applyFilters" class="btn btn-primary">Aplicar</button>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, watch } from 'vue'

const props = defineProps({
  minPrice: {
    type: [String, Number],
    default: ''
  },
  maxPrice: {
    type: [String, Number],
    default: ''
  },
  minBedrooms: {
    type: [String, Number],
    default: ''
  },
  sortBy: {
    type: String,
    default: ''
  },
  selectedSite: {
    type: String,
    default: ''
  },
  selectedCategory: {
    type: String,
    default: ''
  },
  availableSites: {
    type: Array,
    default: () => []
  },
  availableCategories: {
    type: Array,
    default: () => []
  }
})

const emit = defineEmits(['update:minPrice', 'update:maxPrice', 'update:minBedrooms', 'update:sortBy', 'update:selectedSite', 'update:selectedCategory', 'apply'])

const showAdvanced = ref(false)
const minPrice = ref(props.minPrice)
const maxPrice = ref(props.maxPrice)
const minBedrooms = ref(props.minBedrooms)
const sortBy = ref(props.sortBy)
const selectedSite = ref(props.selectedSite)
const selectedCategory = ref(props.selectedCategory)

// Watchers para sincronizar com props
watch(() => props.minPrice, (newValue) => { minPrice.value = newValue })
watch(() => props.maxPrice, (newValue) => { maxPrice.value = newValue })
watch(() => props.minBedrooms, (newValue) => { minBedrooms.value = newValue })
watch(() => props.sortBy, (newValue) => { sortBy.value = newValue })
watch(() => props.selectedSite, (newValue) => { selectedSite.value = newValue })
watch(() => props.selectedCategory, (newValue) => { selectedCategory.value = newValue })

// Função para formatar o nome do site
function formatSiteName(site) {
  const siteNames = {
    'mws': 'MWS',
    'simao': 'Imobiliária Simão',
    'outros': 'Outros',
    'solar': 'Solar Imóveis'
  }
  return siteNames[site] || site
}

function toggleAdvanced() {
  showAdvanced.value = !showAdvanced.value
}

function updateFilters() {
  emit('update:minPrice', minPrice.value)
  emit('update:maxPrice', maxPrice.value)
  emit('update:minBedrooms', minBedrooms.value)
  emit('update:sortBy', sortBy.value)
  emit('update:selectedSite', selectedSite.value)
  emit('update:selectedCategory', selectedCategory.value)
}

function applyFilters() {
  updateFilters()
  emit('apply')
}

function clearFilters() {
  minPrice.value = ''
  maxPrice.value = ''
  minBedrooms.value = ''
  sortBy.value = ''
  selectedSite.value = ''
  selectedCategory.value = ''
  updateFilters()
  emit('apply')
}
</script>

<style scoped>
.advanced-filters {
  background: white;
  border-radius: 12px;
  box-shadow: 0 4px 6px rgba(0,0,0,0.1);
  margin-bottom: 2rem;
  overflow: hidden;
}

.filters-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 1.5rem;
  background: #f8fafc;
  border-bottom: 1px solid #e1e5e9;
}

.filters-header h3 {
  font-family: 'Inter', 'Segoe UI', 'Roboto', 'Helvetica Neue', Arial, sans-serif;
  font-size: 1.125rem;
  font-weight: 600;
  color: #1f2937;
  margin: 0;
}

.toggle-btn {
  background: #667eea;
  color: white;
  border: none;
  border-radius: 8px;
  padding: 8px 16px;
  font-size: 14px;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.3s ease;
}

.toggle-btn:hover {
  background: #5a67d8;
  transform: translateY(-1px);
}

.filters-content {
  padding: 1.5rem;
}

.filter-row {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 1rem;
  margin-bottom: 1rem;
}

.filter-group {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
}

.filter-group label {
  font-family: 'Inter', 'Segoe UI', 'Roboto', 'Helvetica Neue', Arial, sans-serif;
  font-size: 14px;
  font-weight: 600;
  color: #374151;
}

.filter-input, .filter-select {
  padding: 12px 16px;
  border: 2px solid #e1e5e9;
  border-radius: 8px;
  font-family: 'Inter', 'Segoe UI', 'Roboto', 'Helvetica Neue', Arial, sans-serif;
  font-size: 16px;
  font-weight: 500;
  transition: all 0.3s ease;
  background: white;
}

.filter-input:focus, .filter-select:focus {
  outline: none;
  border-color: #667eea;
  box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
}

.filter-actions {
  display: flex;
  gap: 1rem;
  justify-content: flex-end;
  margin-top: 1rem;
  padding-top: 1rem;
  border-top: 1px solid #e1e5e9;
}

.btn {
  padding: 12px 24px;
  border: none;
  border-radius: 8px;
  font-family: 'Inter', 'Segoe UI', 'Roboto', 'Helvetica Neue', Arial, sans-serif;
  font-size: 15px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s ease;
  display: inline-flex;
  align-items: center;
  gap: 8px;
}

.btn-primary {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
}

.btn-primary:hover {
  transform: translateY(-2px);
  box-shadow: 0 8px 25px rgba(102, 126, 234, 0.3);
}

.btn-secondary {
  background: #f8fafc;
  color: #374151;
  border: 2px solid #e1e5e9;
}

.btn-secondary:hover {
  background: #e1e5e9;
}

/* Responsividade */
@media (max-width: 768px) {
  .filter-row {
    grid-template-columns: 1fr;
  }
  
  .filter-actions {
    flex-direction: column;
  }
  
  .btn {
    width: 100%;
    justify-content: center;
  }
}
</style>
