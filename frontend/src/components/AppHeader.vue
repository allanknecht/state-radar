<template>
  <header class="header">
    <div class="header-content">
      <h1 class="title">{{ title }}</h1>
      <div class="header-actions">
        <router-link to="/perfil" class="btn btn-secondary">
          Perfil
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
/* Header */
.header {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  padding: 2.5rem 0 3rem 0;
  margin-bottom: 2rem;
  border-radius: 0 0 24px 24px;
  box-shadow: 0 8px 32px rgba(102, 126, 234, 0.15);
}

.header-content {
  display: flex;
  justify-content: space-between;
  align-items: center;
  flex-wrap: wrap;
  gap: 1.5rem;
  max-width: 1400px;
  margin: 0 auto;
  padding: 0 20px;
}

.title {
  font-family: 'Inter', 'Segoe UI', 'Roboto', 'Helvetica Neue', Arial, sans-serif;
  font-size: 2.75rem;
  font-weight: 800;
  margin: 0;
  text-shadow: 0 4px 8px rgba(0,0,0,0.15);
  letter-spacing: -0.02em;
  line-height: 1.1;
}

.header-actions {
  display: flex;
  gap: 1.25rem;
  flex-wrap: wrap;
}

/* Botões */
.btn {
  padding: 14px 28px;
  border: none;
  border-radius: 12px;
  font-family: 'Inter', 'Segoe UI', 'Roboto', 'Helvetica Neue', Arial, sans-serif;
  font-size: 15px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  text-decoration: none;
  display: inline-flex;
  align-items: center;
  gap: 10px;
  letter-spacing: 0.01em;
}

.btn:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

.btn-secondary {
  background: rgba(255, 255, 255, 0.95);
  color: #1f2937;
  border: 2px solid rgba(255, 255, 255, 0.2);
  backdrop-filter: blur(10px);
  box-shadow: 0 4px 16px rgba(0, 0, 0, 0.1);
}

.btn-secondary:hover:not(:disabled) {
  background: rgba(255, 255, 255, 1);
  transform: translateY(-2px);
  box-shadow: 0 8px 24px rgba(0, 0, 0, 0.15);
}

.btn-outline {
  background: rgba(255, 255, 255, 0.1);
  color: white;
  border: 2px solid rgba(255, 255, 255, 0.3);
  backdrop-filter: blur(10px);
}

.btn-outline:hover {
  background: rgba(255, 255, 255, 0.2);
  border-color: rgba(255, 255, 255, 0.5);
  transform: translateY(-2px);
  box-shadow: 0 8px 24px rgba(0, 0, 0, 0.15);
}

/* Responsividade */
@media (max-width: 768px) {
  .header {
    padding: 2rem 0 2.5rem 0;
  }
  
  .header-content {
    flex-direction: column;
    align-items: stretch;
    gap: 1.5rem;
    padding: 0 16px;
  }
  
  .title {
    font-size: 2.25rem;
    text-align: center;
  }
  
  .header-actions {
    justify-content: center;
    gap: 1rem;
  }
  
  .btn {
    padding: 12px 20px;
    font-size: 14px;
  }
}

@media (max-width: 480px) {
  .header {
    padding: 1.5rem 0 2rem 0;
  }
  
  .title {
    font-size: 1.875rem;
  }
  
  .header-actions {
    flex-direction: column;
    gap: 0.75rem;
  }
  
  .btn {
    width: 100%;
    justify-content: center;
    padding: 14px 20px;
  }
}
</style>
