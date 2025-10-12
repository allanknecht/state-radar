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

// Computed para determinar quais páginas mostrar
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
  
  // Lógica para mostrar páginas com ellipsis
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
  }
}
</script>

<style scoped>
.pagination-container {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin: 2rem 0;
  padding: 1.5rem;
  background: white;
  border-radius: 12px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
  flex-wrap: wrap;
  gap: 1rem;
}

.pagination-info {
  flex-shrink: 0;
}

.pagination-text {
  font-size: 14px;
  color: #6b7280;
  font-weight: 500;
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
  width: 40px;
  height: 40px;
  border: 2px solid #e1e5e9;
  border-radius: 8px;
  background: white;
  color: #374151;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.2s ease;
  font-size: 14px;
}

.pagination-btn:hover:not(:disabled) {
  border-color: #667eea;
  background: #f8fafc;
  transform: translateY(-1px);
}

.pagination-btn:disabled {
  opacity: 0.4;
  cursor: not-allowed;
  transform: none;
}

.pagination-btn.active {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  border-color: #667eea;
  color: white;
  transform: translateY(-1px);
  box-shadow: 0 4px 12px rgba(102, 126, 234, 0.3);
}

.pagination-btn.active:hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 16px rgba(102, 126, 234, 0.4);
}

.pagination-ellipsis {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 40px;
  height: 40px;
  color: #9ca3af;
  font-weight: 600;
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
    width: 36px;
    height: 36px;
    font-size: 13px;
  }
  
  .pagination-ellipsis {
    width: 36px;
    height: 36px;
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
    width: 32px;
    height: 32px;
    font-size: 12px;
  }
  
  .pagination-ellipsis {
    width: 32px;
    height: 32px;
  }
}
</style>
