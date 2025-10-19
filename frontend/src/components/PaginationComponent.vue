<template>
  <div class="pagination-container" v-if="totalPages > 1">
    <div class="pagination-info">
      <span class="pagination-text">
        Página {{ currentPage }} de {{ totalPages }} 
        ({{ totalCount }} {{ totalCount === 1 ? 'imóvel' : 'imóveis' }})
      </span>
    </div>
    
    <div class="pagination-controls">
      <!-- Primeira página -->
      <button 
        class="pagination-btn"
        :disabled="currentPage === 1"
        @click="goToPage(1)"
        title="Primeira página"
      >
        <svg viewBox="0 0 24 24" width="16" height="16">
          <path fill="currentColor" d="M18.41 7.41L17 6l-6 6 6 6 1.41-1.41L13.83 12zM6 6h2v12H6z"/>
        </svg>
      </button>
      
      <!-- Página anterior -->
      <button 
        class="pagination-btn"
        :disabled="currentPage === 1"
        @click="goToPage(currentPage - 1)"
        title="Página anterior"
      >
        <svg viewBox="0 0 24 24" width="16" height="16">
          <path fill="currentColor" d="M15.41 7.41L14 6l-6 6 6 6 1.41-1.41L10.83 12z"/>
        </svg>
      </button>
      
      <!-- Páginas numeradas -->
      <div class="pagination-pages">
        <template v-for="page in visiblePages" :key="page">
          <button 
            v-if="page !== '...'"
            class="pagination-btn page-btn"
            :class="{ 'active': page === currentPage }"
            @click="goToPage(page)"
          >
            {{ page }}
          </button>
          <span v-else class="pagination-ellipsis">...</span>
        </template>
      </div>
      
      <!-- Próxima página -->
      <button 
        class="pagination-btn"
        :disabled="currentPage === totalPages"
        @click="goToPage(currentPage + 1)"
        title="Próxima página"
      >
        <svg viewBox="0 0 24 24" width="16" height="16">
          <path fill="currentColor" d="M8.59 16.59L10 18l6-6-6-6-1.41 1.41L13.17 12z"/>
        </svg>
      </button>
      
      <!-- Última página -->
      <button 
        class="pagination-btn"
        :disabled="currentPage === totalPages"
        @click="goToPage(totalPages)"
        title="Última página"
      >
        <svg viewBox="0 0 24 24" width="16" height="16">
          <path fill="currentColor" d="M5.59 7.41L7 6l6 6-6 6-1.41-1.41L10.17 12zM18 6h2v12h-2z"/>
        </svg>
      </button>
    </div>
  </div>
</template>

<script setup>
import { computed } from 'vue'

const props = defineProps({
  currentPage: {
    type: Number,
    required: true
  },
  totalPages: {
    type: Number,
    required: true
  },
  totalCount: {
    type: Number,
    required: true
  }
})

const emit = defineEmits(['page-change'])

const visiblePages = computed(() => {
  const current = props.currentPage
  const total = props.totalPages
  const pages = []
  
  // Se temos poucas páginas, mostrar todas
  if (total <= 7) {
    for (let i = 1; i <= total; i++) {
      pages.push(i)
    }
    return pages
  }
  
  if (current <= 4) {
    // Mostrar primeiras páginas + ellipsis + última
    for (let i = 1; i <= 5; i++) {
      pages.push(i)
    }
    pages.push('...')
    pages.push(total)
  } else if (current >= total - 3) {
    // Mostrar primeira + ellipsis + últimas páginas
    pages.push(1)
    pages.push('...')
    for (let i = total - 4; i <= total; i++) {
      pages.push(i)
    }
  } else {
    // Mostrar primeira + ellipsis + páginas ao redor da atual + ellipsis + última
    pages.push(1)
    pages.push('...')
    for (let i = current - 1; i <= current + 1; i++) {
      pages.push(i)
    }
    pages.push('...')
    pages.push(total)
  }
  
  return pages
})

function goToPage(page) {
  if (page >= 1 && page <= props.totalPages && page !== props.currentPage) {
    emit('page-change', page)
    // Scroll para o topo da página
    window.scrollTo({ top: 0, behavior: 'smooth' })
  }
}
</script>

<style scoped>
@import url('https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap');
.pagination-container {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin: 2rem 0;
  padding: 1rem 1.5rem;
  background: white;
  border: 1px solid #e5e7eb;
  border-radius: 8px;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
  flex-wrap: wrap;
  gap: 1rem;
}

.pagination-info {
  flex-shrink: 0;
}

.pagination-text {
  font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', 'Helvetica Neue', Arial, sans-serif;
  font-size: 14px;
  color: #6b7280;
  font-weight: 500;
  letter-spacing: 0.01em;
  font-feature-settings: 'cv02', 'cv03', 'cv04', 'cv11';
}

.pagination-controls {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  flex-wrap: wrap;
}

.pagination-pages {
  display: flex;
  align-items: center;
  gap: 0.25rem;
  margin: 0 0.5rem;
}

.pagination-btn {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 36px;
  height: 36px;
  border: 1px solid #d1d5db;
  border-radius: 6px;
  background: white;
  color: #374151;
  font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', 'Helvetica Neue', Arial, sans-serif;
  font-weight: 500;
  letter-spacing: 0.01em;
  cursor: pointer;
  transition: all 0.2s ease;
  font-size: 14px;
  font-feature-settings: 'cv02', 'cv03', 'cv04', 'cv11';
}

.pagination-btn:hover:not(:disabled) {
  border-color: #3b82f6;
  background: #f9fafb;
  color: #1f2937;
}

.pagination-btn:disabled {
  opacity: 0.4;
  cursor: not-allowed;
  background: #f9fafb;
  color: #9ca3af;
}

.pagination-btn.active {
  background: #3b82f6;
  border-color: #3b82f6;
  color: white;
}

.pagination-btn.active:hover {
  background: #2563eb;
  border-color: #2563eb;
}

.pagination-ellipsis {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 36px;
  height: 36px;
  color: #9ca3af;
  font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', 'Helvetica Neue', Arial, sans-serif;
  font-weight: 500;
  letter-spacing: 0.01em;
  font-feature-settings: 'cv02', 'cv03', 'cv04', 'cv11';
}

/* Responsividade */
@media (max-width: 768px) {
  .pagination-container {
    flex-direction: column;
    align-items: stretch;
    text-align: center;
  }
  
  .pagination-info {
    margin-bottom: 0.5rem;
  }
  
  .pagination-controls {
    justify-content: center;
  }
  
  .pagination-pages {
    margin: 0;
  }
  
  .pagination-btn {
    width: 32px;
    height: 32px;
    font-size: 13px;
  }
  
  .pagination-ellipsis {
    width: 32px;
    height: 32px;
  }
}

@media (max-width: 480px) {
  .pagination-controls {
    gap: 0.25rem;
  }
  
  .pagination-pages {
    gap: 0.125rem;
  }
  
  .pagination-btn {
    width: 28px;
    height: 28px;
    font-size: 12px;
  }
  
  .pagination-ellipsis {
    width: 28px;
    height: 28px;
  }
}
</style>
