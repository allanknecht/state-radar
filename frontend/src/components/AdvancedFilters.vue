<template>
  <div class="advanced-filters">
    <div class="filters-header">
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
            <option value="">Padrão</option>
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

watch(() => props.minPrice, (newValue) => { minPrice.value = newValue })
watch(() => props.maxPrice, (newValue) => { maxPrice.value = newValue })
watch(() => props.minBedrooms, (newValue) => { minBedrooms.value = newValue })
watch(() => props.sortBy, (newValue) => { sortBy.value = newValue })
watch(() => props.selectedSite, (newValue) => { selectedSite.value = newValue })
watch(() => props.selectedCategory, (newValue) => { selectedCategory.value = newValue })

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
  toggleAdvanced()
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
@import url('https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap');
@import url('https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700;800&display=swap');
.advanced-filters {
  position: relative;
  z-index: 10;
}

.filters-header {
  display: flex;
  justify-content: center;
  align-items: center;

  background: #f9fafb;

}

.toggle-btn {
  background: #3b82f6;
  color: white;
  border: none;
  border-radius: 6px;
  padding: 6px 12px;
  font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', 'Helvetica Neue', Arial, sans-serif;
  font-size: 14px;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.2s ease;
  letter-spacing: 0.01em;
  font-feature-settings: 'cv02', 'cv03', 'cv04', 'cv11';
}

.toggle-btn:hover {
  background: #2563eb;
}

.filters-content {
  position: absolute;
  top: 100%;
  right: 0;
  width: 400px;
  background: white;
  border: 1px solid #e5e7eb;
  border-radius: 8px;
  box-shadow: 0 10px 25px rgba(0, 0, 0, 0.15);
  padding: 1rem;
  z-index: 20;
  margin-top: 8px;
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
  font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', 'Helvetica Neue', Arial, sans-serif;
  font-size: 14px;
  font-weight: 500;
  color: #374151;
  letter-spacing: 0.01em;
  font-feature-settings: 'cv02', 'cv03', 'cv04', 'cv11';
}

.filter-input, .filter-select {
  padding: 8px 12px;
  border: 1px solid #d1d5db;
  border-radius: 6px;
  font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', 'Helvetica Neue', Arial, sans-serif;
  font-size: 14px;
  font-weight: 400;
  transition: all 0.2s ease;
  background: white;
  color: #1f2937;
  letter-spacing: 0.01em;
  font-feature-settings: 'cv02', 'cv03', 'cv04', 'cv11';
}

.filter-input:focus, .filter-select:focus {
  outline: none;
  border-color: #3b82f6;
  box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.1);
}

.filter-actions {
  display: flex;
  gap: 0.75rem;
  justify-content: flex-end;
  margin-top: 1rem;
  padding-top: 1rem;
  border-top: 1px solid #e5e7eb;
}

.btn {
  padding: 8px 16px;
  border: none;
  border-radius: 6px;
  font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', 'Helvetica Neue', Arial, sans-serif;
  font-size: 14px;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.2s ease;
  display: inline-flex;
  align-items: center;
  gap: 6px;
  letter-spacing: 0.01em;
  font-feature-settings: 'cv02', 'cv03', 'cv04', 'cv11';
}

.btn-primary {
  background: #3b82f6;
  color: white;
}

.btn-primary:hover {
  background: #2563eb;
}

.btn-secondary {
  background: #f9fafb;
  color: #374151;
  border: 1px solid #d1d5db;
}

.btn-secondary:hover {
  background: #f3f4f6;
}

/* Responsividade */
@media (max-width: 768px) {
  .filters-content {
    width: calc(100vw - 2rem);
    right: 1rem;
    left: 1rem;
  }
  
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
