<template>
  <header class="header">
    <div class="header-content">
      <a href="/" class="logo-link" data-v-48a13218="">
        <div data-v-48a13218="" class="logo-section">
          <img data-v-48a13218="" src="/logo-new.svg" alt="BuscaImóveis" class="logo">
        </div>
      </a>
      <div class="header-actions">
        <router-link 
          v-if="$route.name !== 'perfil'" 
          to="/perfil" 
          class="btn btn-secondary"
        >
          Perfil
        </router-link>
        <router-link 
          v-else 
          to="/lista" 
          class="btn btn-secondary"
        >
          <svg width="16" height="16" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
            <path d="M3 9L12 2L21 9V20C21 20.5304 20.7893 21.0391 20.4142 21.4142C20.0391 21.7893 19.5304 22 19 22H5C4.46957 22 3.96086 21.7893 3.58579 21.4142C3.21071 21.0391 3 20.5304 3 20V9Z" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
            <path d="M9 22V12H15V22" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
          </svg>
          Voltar ao Home
        </router-link>
        <button @click="$emit('logout')" class="btn btn-outline">Sair</button>
      </div>
    </div>
  </header>
</template>

<script setup>
defineProps({
  title: {
    type: String,
    default: 'Imóveis Disponíveis'
  },
  loading: {
    type: Boolean,
    default: false
  }
})

defineEmits(['logout'])
</script>

<style scoped>
@import url('https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap');
@import url('https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700;800&display=swap');
/* Header */
.header {
  background: white;
  color: #1f2937;
  padding: 1rem 0;
  margin-bottom: 0;
  border-bottom: 1px solid #e5e7eb;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
}

.header-content {
  display: flex;
  justify-content: space-between;
  align-items: center;
  flex-wrap: wrap;
  gap: 1rem;
  max-width: 1200px;
  margin: 0 auto;
  padding: 0 10px;
  min-height: 60px;
}

.logo-section {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  margin-left: -10px;
}

.logo {
  height: 150px;
  width: auto;
  transition: all 0.3s ease;
  filter: drop-shadow(0 2px 4px rgba(0, 0, 0, 0.1));
  opacity: 0.9;
}

.logo:hover {
  transform: scale(1.05);
  filter: drop-shadow(0 4px 8px rgba(0, 0, 0, 0.15));
  opacity: 1;
}

.header-actions {
  display: flex;
  gap: 0.75rem;
  flex-wrap: wrap;
}

/* Botões */
.btn {
  padding: 8px 16px;
  border: none;
  border-radius: 6px;
  font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', 'Helvetica Neue', Arial, sans-serif;
  font-size: 14px;
  font-weight: 500;
  letter-spacing: 0.01em;
  font-feature-settings: 'cv02', 'cv03', 'cv04', 'cv11';
  cursor: pointer;
  transition: all 0.2s ease;
  text-decoration: none;
  display: inline-flex;
  align-items: center;
  gap: 6px;
  letter-spacing: 0.01em;
  font-feature-settings: 'cv02', 'cv03', 'cv04', 'cv11';
}

.btn:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

.btn-secondary {
  background: #3b82f6;
  color: white;
  border: 1px solid #3b82f6;
}

.btn-secondary:hover:not(:disabled) {
  background: #2563eb;
  border-color: #2563eb;
}

.btn-outline {
  background: transparent;
  color: #6b7280;
  border: 1px solid #d1d5db;
}

.btn-outline:hover {
  background: #f9fafb;
  color: #374151;
  border-color: #9ca3af;
}

/* Responsividade */
@media (max-width: 768px) {
  .header-content {
    flex-direction: column;
    align-items: center;
    gap: 1rem;
    padding: 0 16px;
  }
  
  .logo-section {
    flex-direction: column;
    align-items: center;
    gap: 0.5rem;
  }
  
  .logo {
    height: 120px;
    width: auto;
  }
  
  .header-actions {
    justify-content: center;
    gap: 0.75rem;
  }
}

@media (max-width: 480px) {
  .header-actions {
    flex-direction: column;
    gap: 0.5rem;
    width: 100%;
  }
  
  .btn {
    width: 100%;
    justify-content: center;
    padding: 10px 16px;
  }
}
</style>
