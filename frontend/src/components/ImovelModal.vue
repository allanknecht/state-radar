<template>
  <div v-if="imovel" class="modal-overlay" @click="closeModal">
    <div class="modal-content" @click.stop>
      <div class="modal-header">
        <h2 class="modal-title">{{ imovel.titulo }}</h2>
        <button @click="closeModal" class="modal-close">
          <svg viewBox="0 0 24 24" width="24" height="24">
            <path fill="currentColor" d="M19 6.41L17.59 5 12 10.59 6.41 5 5 6.41 10.59 12 5 17.59 6.41 19 12 13.41 17.59 19 19 17.59 13.41 12z"/>
          </svg>
        </button>
      </div>
      
      <div class="modal-body">
        <!-- Imagem Principal -->
        <div class="modal-image">
          <img 
            :src="imovel.imagem" 
            :alt="imovel.titulo"
            @error="handleImageError"
          >
          <div class="modal-badge">{{ imovel.categoria }}</div>
        </div>

        <!-- Informações Básicas -->
        <div class="modal-section">
          <h3>Informações Básicas</h3>
          <div class="info-grid">
            <div class="info-item" v-if="imovel.localizacao">
              <label>Localização:</label>
              <span>{{ imovel.localizacao }}</span>
            </div>
            
            <div class="info-item" v-if="imovel.dormitorios">
              <label>Dormitórios:</label>
              <span>{{ imovel.dormitorios }} {{ imovel.dormitorios === 1 ? 'dormitório' : 'dormitórios' }}</span>
            </div>
            
            <div class="info-item" v-if="imovel.suites">
              <label>Suítes:</label>
              <span>{{ imovel.suites }} {{ imovel.suites === 1 ? 'suíte' : 'suítes' }}</span>
            </div>
            
            <div class="info-item" v-if="imovel.banheiros">
              <label>Banheiros:</label>
              <span>{{ imovel.banheiros }} {{ imovel.banheiros === 1 ? 'banheiro' : 'banheiros' }}</span>
            </div>
            
            <div class="info-item" v-if="imovel.vagas">
              <label>Vagas de Garagem:</label>
              <span>{{ imovel.vagas }} {{ imovel.vagas === 1 ? 'vaga' : 'vagas' }}</span>
            </div>
            
            <div class="info-item" v-if="imovel.area_m2">
              <label>Área Total:</label>
              <span>{{ imovel.area_m2 }}m²</span>
            </div>
            
            <div class="info-item" v-if="imovel.area_privativa_m2">
              <label>Área Privativa:</label>
              <span>{{ imovel.area_privativa_m2 }}m²</span>
            </div>
          </div>
        </div>

        <!-- Preços -->
        <div class="modal-section">
          <h3>Valores</h3>
          <div class="price-info">
            <div class="main-price">
              <span class="price-label">Preço:</span>
              <span class="price-value">R$ {{ formatPrice(imovel.preco_brl) }}</span>
            </div>
            
            <div class="additional-costs" v-if="imovel.condominio || imovel.iptu">
              <div v-if="imovel.condominio" class="cost-item">
                <span class="cost-label">Condomínio:</span>
                <span class="cost-value">R$ {{ formatPrice(imovel.condominio) }}</span>
              </div>
              
              <div v-if="imovel.iptu" class="cost-item">
                <span class="cost-label">IPTU:</span>
                <span class="cost-value">R$ {{ formatPrice(imovel.iptu) }}</span>
              </div>
            </div>
          </div>
        </div>

        <!-- Amenidades -->
        <div class="modal-section" v-if="imovel.amenities && imovel.amenities.length">
          <h3>Amenidades</h3>
          <div class="amenities-list">
            <span v-for="amenity in imovel.amenities" :key="amenity" class="amenity-tag">
              {{ amenity }}
            </span>
          </div>
        </div>

        <!-- Descrição -->
        <div class="modal-section" v-if="imovel.descricao">
          <h3>Descrição</h3>
          <p class="description">{{ imovel.descricao }}</p>
        </div>

        <!-- Mobiliação -->
        <div class="modal-section" v-if="imovel.mobiliacao">
          <h3>Mobiliação</h3>
          <p class="mobiliacao">{{ imovel.mobiliacao }}</p>
        </div>

        <!-- Informações Técnicas -->
        <div class="modal-section">
          <h3>Informações Técnicas</h3>
          <div class="tech-info">
            <div class="tech-item">
              <label>Código:</label>
              <span>{{ imovel.codigo }}</span>
            </div>
            <div class="tech-item">
              <label>Site:</label>
              <span>{{ imovel.site.toUpperCase() }}</span>
            </div>
            <div class="tech-item" v-if="imovel.created_at">
              <label>Data de Cadastro:</label>
              <span>{{ formatDate(imovel.created_at) }}</span>
            </div>
          </div>
        </div>
      </div>
      
      <div class="modal-footer">
        <button @click="closeModal" class="btn btn-secondary">Fechar</button>
        <a :href="imovel.link" target="_blank" class="btn btn-primary">
          Ir ao site da imobiliária
        </a>
      </div>
    </div>
  </div>
</template>

<script setup>
import { watch } from 'vue'

const props = defineProps({
  imovel: {
    type: Object,
    default: null
  }
})

const emit = defineEmits(['close'])

function closeModal() {
  emit('close')
}

function formatPrice(price) {
  if (!price) return '0,00'
  return new Intl.NumberFormat('pt-BR', {
    minimumFractionDigits: 2,
    maximumFractionDigits: 2
  }).format(price)
}

function formatDate(dateString) {
  if (!dateString) return ''
  const date = new Date(dateString)
  return date.toLocaleDateString('pt-BR', {
    day: '2-digit',
    month: '2-digit',
    year: 'numeric',
    hour: '2-digit',
    minute: '2-digit'
  })
}

function handleImageError(event) {
  event.target.src = 'data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMzAwIiBoZWlnaHQ9IjIwMCIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj48cmVjdCB3aWR0aD0iMTAwJSIgaGVpZ2h0PSIxMDAlIiBmaWxsPSIjZGRkIi8+PHRleHQgeD0iNTAlIiB5PSI1MCUiIGZvbnQtZmFtaWx5PSJBcmlhbCIgZm9udC1zaXplPSIxNCIgZmlsbD0iIzk5OSIgdGV4dC1hbmNob3I9Im1pZGRsZSIgZHk9Ii4zZW0iPkltYWdlbSBuw6NvIGVuY29udHJhZGE8L3RleHQ+PC9zdmc+'
}

// Controla o scroll do body quando o modal abre/fecha
watch(() => props.imovel, (newImovel) => {
  if (newImovel) {
    document.body.style.overflow = 'hidden'
  } else {
    document.body.style.overflow = 'auto'
  }
})
</script>

<style scoped>
/* Modal Styles */
.modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.7);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
  padding: 20px;
  animation: fadeIn 0.3s ease;
}

.modal-content {
  background: white;
  border-radius: 16px;
  max-width: 800px;
  width: 100%;
  max-height: 90vh;
  overflow-y: auto;
  box-shadow: 0 20px 40px rgba(0, 0, 0, 0.3);
  animation: slideUp 0.3s ease;
}

.modal-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 1.5rem 2rem;
  border-bottom: 1px solid #e1e5e9;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  border-radius: 16px 16px 0 0;
}

.modal-title {
  font-family: 'Inter', 'Segoe UI', 'Roboto', 'Helvetica Neue', Arial, sans-serif;
  font-size: 1.5rem;
  font-weight: 800;
  margin: 0;
  flex: 1;
  padding-right: 1rem;
  letter-spacing: -0.02em;
}

.modal-close {
  background: rgba(255, 255, 255, 0.2);
  border: none;
  border-radius: 50%;
  width: 40px;
  height: 40px;
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  color: white;
  transition: all 0.3s ease;
}

.modal-close:hover {
  background: rgba(255, 255, 255, 0.3);
  transform: scale(1.1);
}

.modal-body {
  padding: 2rem;
}

.modal-image {
  position: relative;
  height: 300px;
  border-radius: 12px;
  overflow: hidden;
  margin-bottom: 2rem;
}

.modal-image img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.modal-badge {
  position: absolute;
  top: 16px;
  right: 16px;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  padding: 8px 16px;
  border-radius: 20px;
  font-size: 14px;
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

.modal-section {
  margin-bottom: 2rem;
}

.modal-section h3 {
  font-family: 'Inter', 'Segoe UI', 'Roboto', 'Helvetica Neue', Arial, sans-serif;
  font-size: 1.25rem;
  font-weight: 700;
  color: #1f2937;
  margin: 0 0 1rem 0;
  padding-bottom: 0.5rem;
  border-bottom: 2px solid #e1e5e9;
  letter-spacing: -0.01em;
}

.info-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: 1rem;
}

.info-item {
  display: flex;
  flex-direction: column;
  gap: 0.25rem;
}

.info-item label {
  font-family: 'Inter', 'Segoe UI', 'Roboto', 'Helvetica Neue', Arial, sans-serif;
  font-weight: 600;
  color: #6b7280;
  font-size: 14px;
}

.info-item span {
  font-family: 'Inter', 'Segoe UI', 'Roboto', 'Helvetica Neue', Arial, sans-serif;
  color: #1f2937;
  font-size: 16px;
  font-weight: 500;
}

.price-info {
  background: #f8fafc;
  padding: 1.5rem;
  border-radius: 12px;
  border: 1px solid #e1e5e9;
}

.main-price {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 1rem;
  padding-bottom: 1rem;
  border-bottom: 1px solid #e1e5e9;
}

.price-label {
  font-family: 'Inter', 'Segoe UI', 'Roboto', 'Helvetica Neue', Arial, sans-serif;
  font-size: 1.25rem;
  font-weight: 600;
  color: #1f2937;
}

.price-value {
  font-family: 'Inter', 'Segoe UI', 'Roboto', 'Helvetica Neue', Arial, sans-serif;
  font-size: 2rem;
  font-weight: 800;
  color: #059669;
  letter-spacing: -0.02em;
}

.additional-costs {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
}

.cost-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.cost-label {
  color: #6b7280;
  font-size: 14px;
}

.cost-value {
  color: #1f2937;
  font-weight: 600;
}

.amenities-list {
  display: flex;
  flex-wrap: wrap;
  gap: 0.5rem;
}

.amenity-tag {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  padding: 6px 12px;
  border-radius: 20px;
  font-size: 14px;
  font-weight: 500;
}

.description, .mobiliacao {
  line-height: 1.6;
  color: #4b5563;
  margin: 0;
}

.tech-info {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 1rem;
}

.tech-item {
  display: flex;
  flex-direction: column;
  gap: 0.25rem;
}

.tech-item label {
  font-weight: 600;
  color: #6b7280;
  font-size: 14px;
}

.tech-item span {
  color: #1f2937;
  font-size: 16px;
}

.modal-footer {
  display: flex;
  justify-content: flex-end;
  gap: 1rem;
  padding: 1.5rem 2rem;
  border-top: 1px solid #e1e5e9;
  background: #f8fafc;
  border-radius: 0 0 16px 16px;
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

.btn-secondary {
  background: #f8fafc;
  color: #374151;
  border: 2px solid #e1e5e9;
}

.btn-secondary:hover {
  background: #e1e5e9;
}

/* Animações */
@keyframes fadeIn {
  from { opacity: 0; }
  to { opacity: 1; }
}

@keyframes slideUp {
  from {
    opacity: 0;
    transform: translateY(30px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

/* Responsividade do Modal */
@media (max-width: 768px) {
  .modal-overlay {
    padding: 10px;
  }
  
  .modal-content {
    max-height: 95vh;
  }
  
  .modal-header {
    padding: 1rem;
  }
  
  .modal-title {
    font-size: 1.25rem;
  }
  
  .modal-body {
    padding: 1rem;
  }
  
  .modal-image {
    height: 200px;
  }
  
  .info-grid {
    grid-template-columns: 1fr;
  }
  
  .main-price {
    flex-direction: column;
    align-items: flex-start;
    gap: 0.5rem;
  }
  
  .price-value {
    font-size: 1.5rem;
  }
  
  .modal-footer {
    flex-direction: column;
    padding: 1rem;
  }
  
  .modal-footer .btn {
    width: 100%;
    justify-content: center;
  }
}

@media (max-width: 480px) {
  .modal-title {
    font-size: 1.1rem;
  }
  
  .modal-image {
    height: 150px;
  }
  
  .price-value {
    font-size: 1.25rem;
  }
}
</style>
