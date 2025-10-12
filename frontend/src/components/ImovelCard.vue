<template>
  <div class="imovel-card">
    <div class="imovel-image">
      <img 
        :src="imovel.imagem" 
        :alt="imovel.titulo"
        @error="handleImageError"
      >
      <div class="imovel-badge">{{ imovel.categoria }}</div>
    </div>
    
    <div class="imovel-content">
      <h3 class="imovel-title">{{ imovel.titulo }}</h3>
      <p class="imovel-location">{{ imovel.localizacao }}</p>
      
      <div class="imovel-details">
        <div class="detail-item" v-if="imovel.dormitorios">
          <svg class="detail-icon" viewBox="0 0 24 24" width="16" height="16">
            <path fill="currentColor" d="M7 14c-1.66 0-3 1.34-3 3 0 1.31-1.16 2-2 2 .92 1.22 2.49 2 4 2 2.21 0 4-1.79 4-4 0-1.66-1.34-3-3-3zm13.71-9.37l-1.34-1.34c-.39-.39-1.02-.39-1.41 0L9 12.25 11.75 15l8.96-8.96c.39-.39.39-1.02 0-1.41z"/>
          </svg>
          <span>{{ imovel.dormitorios }} {{ imovel.dormitorios === 1 ? 'dormitório' : 'dormitórios' }}</span>
        </div>
        
        <div class="detail-item" v-if="imovel.suites">
          <svg class="detail-icon" viewBox="0 0 24 24" width="16" height="16">
            <path fill="currentColor" d="M7 14c-1.66 0-3 1.34-3 3 0 1.31-1.16 2-2 2 .92 1.22 2.49 2 4 2 2.21 0 4-1.79 4-4 0-1.66-1.34-3-3-3zm13.71-9.37l-1.34-1.34c-.39-.39-1.02-.39-1.41 0L9 12.25 11.75 15l8.96-8.96c.39-.39.39-1.02 0-1.41z"/>
          </svg>
          <span>{{ imovel.suites }} {{ imovel.suites === 1 ? 'suíte' : 'suítes' }}</span>
        </div>
        
        <div class="detail-item" v-if="imovel.area_m2">
          <svg class="detail-icon" viewBox="0 0 24 24" width="16" height="16">
            <path fill="currentColor" d="M3 3v18h18V3H3zm16 16H5V5h14v14z"/>
          </svg>
          <span>{{ imovel.area_m2 }}m²</span>
        </div>
        
        <div class="detail-item" v-if="imovel.vagas">
          <svg class="detail-icon" viewBox="0 0 24 24" width="16" height="16">
            <path fill="currentColor" d="M18.92 6.01C18.72 5.42 18.16 5 17.5 5h-11c-.66 0-1.22.42-1.42 1.01L3 12v8c0 .55.45 1 1 1h1c.55 0 1-.45 1-1v-1h12v1c0 .55.45 1 1 1h1c.55 0 1-.45 1-1v-8l-2.08-5.99zM6.5 16c-.83 0-1.5-.67-1.5-1.5S5.67 13 6.5 13s1.5.67 1.5 1.5S7.33 16 6.5 16zm11 0c-.83 0-1.5-.67-1.5-1.5s.67-1.5 1.5-1.5 1.5.67 1.5 1.5-.67 1.5-1.5 1.5zM5 11l1.5-4.5h11L19 11H5z"/>
          </svg>
          <span>{{ imovel.vagas }} {{ imovel.vagas === 1 ? 'vaga' : 'vagas' }}</span>
        </div>
      </div>
      
      <div class="imovel-price">
        <span class="price-value">R$ {{ formatPrice(imovel.preco_brl) }}</span>
        <span v-if="imovel.condominio" class="condominio">
          Condomínio: R$ {{ formatPrice(imovel.condominio) }}
        </span>
      </div>
      
      <div class="imovel-actions">
        <button @click="$emit('openModal', imovel)" class="btn btn-primary">
          Ver Detalhes
        </button>
      </div>
    </div>
  </div>
</template>

<script setup>
defineProps({
  imovel: {
    type: Object,
    required: true
  }
})

defineEmits(['openModal'])

function formatPrice(price) {
  if (!price) return '0,00'
  return new Intl.NumberFormat('pt-BR', {
    minimumFractionDigits: 2,
    maximumFractionDigits: 2
  }).format(price)
}

function handleImageError(event) {
  event.target.src = 'data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMzAwIiBoZWlnaHQ9IjIwMCIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj48cmVjdCB3aWR0aD0iMTAwJSIgaGVpZ2h0PSIxMDAlIiBmaWxsPSIjZGRkIi8+PHRleHQgeD0iNTAlIiB5PSI1MCUiIGZvbnQtZmFtaWx5PSJBcmlhbCIgZm9udC1zaXplPSIxNCIgZmlsbD0iIzk5OSIgdGV4dC1hbmNob3I9Im1pZGRsZSIgZHk9Ii4zZW0iPkltYWdlbSBuw6NvIGVuY29udHJhZGE8L3RleHQ+PC9zdmc+'
}
</script>

<style scoped>
.imovel-card {
  background: white;
  border-radius: 16px;
  overflow: hidden;
  box-shadow: 0 4px 6px rgba(0,0,0,0.1);
  transition: all 0.3s ease;
  border: 1px solid #e1e5e9;
}

.imovel-card:hover {
  transform: translateY(-4px);
  box-shadow: 0 12px 24px rgba(0,0,0,0.15);
}

.imovel-image {
  position: relative;
  height: 250px;
  overflow: hidden;
}

.imovel-image img {
  width: 100%;
  height: 100%;
  object-fit: cover;
  transition: transform 0.3s ease;
}

.imovel-card:hover .imovel-image img {
  transform: scale(1.05);
}

.imovel-badge {
  position: absolute;
  top: 12px;
  right: 12px;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  padding: 6px 12px;
  border-radius: 20px;
  font-size: 12px;
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

.imovel-content {
  padding: 1.5rem;
}

.imovel-title {
  font-family: 'Inter', 'Segoe UI', 'Roboto', 'Helvetica Neue', Arial, sans-serif;
  font-size: 1.25rem;
  font-weight: 700;
  color: #1f2937;
  margin: 0 0 0.5rem 0;
  line-height: 1.4;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
  letter-spacing: -0.01em;
}

.imovel-location {
  font-family: 'Inter', 'Segoe UI', 'Roboto', 'Helvetica Neue', Arial, sans-serif;
  color: #6b7280;
  font-size: 14px;
  font-weight: 500;
  margin: 0 0 1rem 0;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}

.imovel-details {
  display: flex;
  flex-wrap: wrap;
  gap: 1rem;
  margin-bottom: 1rem;
}

.detail-item {
  display: flex;
  align-items: center;
  gap: 6px;
  color: #6b7280;
  font-family: 'Inter', 'Segoe UI', 'Roboto', 'Helvetica Neue', Arial, sans-serif;
  font-size: 14px;
  font-weight: 500;
}

.detail-icon {
  color: #667eea;
}

.imovel-price {
  margin-bottom: 1.5rem;
}

.price-value {
  font-family: 'Inter', 'Segoe UI', 'Roboto', 'Helvetica Neue', Arial, sans-serif;
  font-size: 1.5rem;
  font-weight: 800;
  color: #059669;
  letter-spacing: -0.02em;
}

.condominio {
  display: block;
  font-family: 'Inter', 'Segoe UI', 'Roboto', 'Helvetica Neue', Arial, sans-serif;
  font-size: 14px;
  font-weight: 500;
  color: #6b7280;
  margin-top: 4px;
}

.imovel-actions {
  display: flex;
  gap: 1rem;
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

.btn-primary {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
}

.btn-primary:hover {
  transform: translateY(-2px);
  box-shadow: 0 8px 25px rgba(102, 126, 234, 0.3);
}

/* Responsividade */
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
  
  .imovel-details {
    flex-direction: column;
    gap: 0.5rem;
  }
}
</style>
