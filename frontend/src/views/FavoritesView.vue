<template>
  <div class="favorites-container">
    <!-- Header -->
    <AppHeader 
      @logout="sair"
    />

    <!-- Título da Página -->
    <div class="page-header">
      <h1>Meus Favoritos</h1>
      <p v-if="!loading && !error">{{ totalCount }} imóvel(is) favoritado(s)</p>
    </div>

    <!-- Loading e Error States -->
    <div v-if="loading" class="loading-state">
      <div class="spinner"></div>
      <p>Carregando favoritos...</p>
    </div>
    
    <div v-if="error" class="error-state">
      <p>{{ error }}</p>
      <button @click="fetchFavorites" class="btn btn-primary">Tentar novamente</button>
    </div>

    <!-- Grid de Imóveis -->
    <div v-if="!loading && !error && favorites.length > 0" class="imoveis-grid">
      <ImovelCard 
        v-for="favorite in favorites" 
        :key="favorite.scraper_record.id" 
        :imovel="favorite.scraper_record"
        @openModal="openModal"
        @favorite-changed="handleFavoriteChanged"
      />
    </div>

    <!-- Empty State -->
    <div v-else-if="!loading && !error && favorites.length === 0" class="empty-state">
      <svg class="empty-icon" viewBox="0 0 24 24" width="64" height="64">
        <path fill="currentColor" d="M16.5 3c-1.74 0-3.41.81-4.5 2.09C10.91 3.81 9.24 3 7.5 3 4.42 3 2 5.42 2 8.5c0 3.78 3.4 6.86 8.55 11.54L12 21.35l1.45-1.32C18.6 15.36 22 12.28 22 8.5 22 5.42 19.58 3 16.5 3zm-4.4 12.95l-.1.1-.1-.1C7.14 14.24 4 11.39 4 8.5 4 6.5 5.5 5 7.5 5c1.54 0 3.04.99 3.57 2.36h1.87C13.46 5.99 14.96 5 16.5 5c2 0 3.5 1.5 3.5 3.5 0 2.89-3.14 5.74-7.9 9.45z"/>
      </svg>
      <h3>Nenhum favorito ainda</h3>
      <p>Adicione imóveis aos seus favoritos clicando no ícone de coração nos cards.</p>
      <router-link to="/lista" class="btn btn-primary">Ver Imóveis</router-link>
    </div>

    <!-- Modal de Detalhes -->
    <ImovelModal 
      :imovel="selectedImovel" 
      @close="closeModal" 
    />
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import api from '../lib/api'
import { useAuthStore } from '../stores/auth'
import { useRouter } from 'vue-router'
import AppHeader from '../components/AppHeader.vue'
import ImovelCard from '../components/ImovelCard.vue'
import ImovelModal from '../components/ImovelModal.vue'

const router = useRouter()
const auth = useAuthStore()
const favorites = ref([])
const loading = ref(false)
const error = ref('')
const selectedImovel = ref(null)
const totalCount = ref(0)

async function fetchFavorites() {
  loading.value = true
  error.value = ''
  try {
    const { data } = await api.get('/favorites')
    
    // O backend retorna { data: [...] }
    // Cada item tem { id, scraper_record_id, created_at, scraper_record: {...} }
    favorites.value = data.data || []
    totalCount.value = favorites.value.length
    
    // Garantir que todos os imóveis tenham is_favorited = true
    favorites.value.forEach(fav => {
      if (fav.scraper_record) {
        fav.scraper_record.is_favorited = true
      }
    })
    
  } catch (e) {
    console.error('Erro ao buscar favoritos:', e)
    error.value = 'Erro ao carregar favoritos. Tente novamente.'
    favorites.value = []
    totalCount.value = 0
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

function handleFavoriteChanged({ id, is_favorited }) {
  // Se foi desfavoritado, remover da lista imediatamente
  if (!is_favorited) {
    favorites.value = favorites.value.filter(fav => fav.scraper_record?.id !== id)
    totalCount.value = favorites.value.length
  } else {
    // Se foi favoritado, atualizar o estado
    const favorite = favorites.value.find(fav => fav.scraper_record?.id === id)
    if (favorite && favorite.scraper_record) {
      favorite.scraper_record.is_favorited = true
    }
  }
}

onMounted(async () => {
  await fetchFavorites()
})
</script>

<style scoped>
@import url('https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap');
@import url('https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700;800&display=swap');

.favorites-container {
  max-width: 1200px;
  margin: 0 auto;
  padding: 0 20px;
  box-sizing: border-box;
}

.page-header {
  margin: 2rem 0;
  text-align: center;
}

.page-header h1 {
  font-family: 'Poppins', 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', 'Helvetica Neue', Arial, sans-serif;
  font-size: 2rem;
  font-weight: 700;
  color: #111827;
  margin: 0 0 0.5rem 0;
  letter-spacing: -0.025em;
}

.page-header p {
  font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', 'Helvetica Neue', Arial, sans-serif;
  font-size: 1rem;
  color: #6b7280;
  margin: 0;
}

/* Loading State */
.loading-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 4rem 2rem;
  text-align: center;
}

.spinner {
  width: 48px;
  height: 48px;
  border: 4px solid #e5e7eb;
  border-top-color: #3b82f6;
  border-radius: 50%;
  animation: spin 1s linear infinite;
  margin-bottom: 1rem;
}

@keyframes spin {
  to { transform: rotate(360deg); }
}

.loading-state p {
  font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', 'Helvetica Neue', Arial, sans-serif;
  color: #6b7280;
  font-size: 1rem;
}

/* Error State */
.error-state {
  text-align: center;
  padding: 3rem 2rem;
  background: #fef2f2;
  border: 1px solid #fecaca;
  border-radius: 8px;
  margin: 2rem 0;
}

.error-state p {
  font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', 'Helvetica Neue', Arial, sans-serif;
  color: #dc2626;
  margin-bottom: 1rem;
}

/* Grid de Imóveis */
.imoveis-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
  gap: 1.5rem;
  margin: 2rem 0;
}

/* Empty State */
.empty-state {
  text-align: center;
  padding: 4rem 2rem;
}

.empty-icon {
  color: #d1d5db;
  margin-bottom: 1.5rem;
}

.empty-state h3 {
  font-family: 'Poppins', 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', 'Helvetica Neue', Arial, sans-serif;
  font-size: 1.5rem;
  font-weight: 600;
  color: #111827;
  margin: 0 0 0.5rem 0;
}

.empty-state p {
  font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', 'Helvetica Neue', Arial, sans-serif;
  font-size: 1rem;
  color: #6b7280;
  margin: 0 0 2rem 0;
}

/* Botões */
.btn {
  padding: 12px 24px;
  border: none;
  border-radius: 8px;
  font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', 'Helvetica Neue', Arial, sans-serif;
  font-size: 16px;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.2s ease;
  text-decoration: none;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
}

.btn-primary {
  background: #3b82f6;
  color: white;
}

.btn-primary:hover {
  background: #2563eb;
}

/* Responsividade */
@media (max-width: 768px) {
  .imoveis-grid {
    grid-template-columns: repeat(auto-fill, minmax(250px, 1fr));
    gap: 1rem;
  }
  
  .page-header h1 {
    font-size: 1.75rem;
  }
}

@media (max-width: 480px) {
  .imoveis-grid {
    grid-template-columns: 1fr;
  }
  
  .page-header h1 {
    font-size: 1.5rem;
  }
}
</style>

