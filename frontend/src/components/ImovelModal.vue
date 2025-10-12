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
          <div class="modal-badge font-heading">{{ imovel.categoria }}</div>
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
              <span class="price-value">{{ imovel.preco_formatado || 'Preço indisponível' }}</span>
            </div>
            
            <div class="additional-costs" v-if="imovel.condominio_formatado || imovel.iptu_formatado">
              <div v-if="imovel.condominio_formatado" class="cost-item">
                <span class="cost-label">Condomínio:</span>
                <span class="cost-value">{{ imovel.condominio_formatado }}</span>
              </div>
              
              <div v-if="imovel.iptu_formatado" class="cost-item">
                <span class="cost-label">IPTU:</span>
                <span class="cost-value">{{ imovel.iptu_formatado }}</span>
              </div>
            </div>
          </div>
        </div>

        <!-- Comodidades -->
        <div class="modal-section" v-if="imovel.amenities && imovel.amenities.length">
          <h3>Comodidades</h3>
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

        <!-- Informações do Sistema -->
        <div class="modal-section system-info">
          <h3>Informações do Sistema</h3>
          <div class="system-grid">
            <div class="system-item">
              <div class="system-icon">
                <svg viewBox="0 0 24 24" width="20" height="20">
                  <path fill="currentColor" d="M14,2H6A2,2 0 0,0 4,4V20A2,2 0 0,0 6,22H18A2,2 0 0,0 20,20V8L14,2M18,20H6V4H13V9H18V20Z"/>
                </svg>
              </div>
              <div class="system-content">
                <label>Código do Imóvel</label>
                <span>{{ imovel.codigo }}</span>
              </div>
            </div>
            
            <div class="system-item">
              <div class="system-icon">
                <svg viewBox="0 0 24 24" width="20" height="20">
                  <path fill="currentColor" d="M12,2A10,10 0 0,0 2,12A10,10 0 0,0 12,22A10,10 0 0,0 22,12A10,10 0 0,0 12,2M16.2,16.2L11,13V7H12.5V12.2L17,14.9L16.2,16.2Z"/>
                </svg>
              </div>
              <div class="system-content">
                <label>Fonte dos Dados</label>
                <span>{{ formatSiteName(imovel.site) }}</span>
              </div>
            </div>
            
            <div class="system-item" v-if="imovel.created_at">
              <div class="system-icon">
                <svg viewBox="0 0 24 24" width="20" height="20">
                  <path fill="currentColor" d="M19,3H5C3.89,3 3,3.89 3,5V19A2,2 0 0,0 5,21H19A2,2 0 0,0 21,19V5C21,3.89 20.1,3 19,3M19,5V19H5V5H19Z"/>
                </svg>
              </div>
              <div class="system-content">
                <label>Data de Cadastro</label>
                <span>{{ formatDate(imovel.created_at) }}</span>
              </div>
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

function formatSiteName(site) {
  const siteNames = {
    'mws': 'MWS',
    'simao': 'Imobiliária Simão',
    'solar': 'Solar Imóveis'
  }
  return siteNames[site] || site.toUpperCase()
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
@import url('https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap');
@import url('https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700;800&display=swap');
/* Modal Styles */
.modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.5);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
  padding: 20px;
}

.modal-content {
  background: white;
  border-radius: 8px;
  max-width: 800px;
  width: 100%;
  max-height: 90vh;
  display: flex;
  flex-direction: column;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
  border: 1px solid #e5e7eb;
  animation: slideUp 0.15s ease;
}

.modal-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 1.5rem 2rem;
  border-bottom: 1px solid #e5e7eb;
  background: white;
  color: #111827;
  border-radius: 8px 8px 0 0;
  flex-shrink: 0;
}

.modal-title {
  font-family: 'Poppins', 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', 'Helvetica Neue', Arial, sans-serif;
  font-size: 1.5rem;
  font-weight: 600;
  margin: 0;
  flex: 1;
  padding-right: 1rem;
  letter-spacing: -0.03em;
  font-feature-settings: 'cv02', 'cv03', 'cv04', 'cv11';
  color: #111827;
}

.modal-close {
  background: #f3f4f6;
  border: none;
  border-radius: 50%;
  width: 40px;
  height: 40px;
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  color: #6b7280;
  transition: all 0.15s ease;
}

.modal-close:hover {
  background: #e5e7eb;
}

.modal-body {
  padding: 2rem;
  overflow-y: auto;
  flex: 1;
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

.modal-badge,
.modal-badge.font-heading,
div.modal-badge {
  position: absolute;
  top: 16px;
  right: 16px;
  background: #3b82f6;
  color: white;
  padding: 10px 18px;
  border-radius: 20px;
  font-family: 'Poppins', 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', 'Helvetica Neue', Arial, sans-serif !important;
  font-size: 14px !important;
  font-weight: 700 !important;
  text-transform: uppercase;
  letter-spacing: 0.8px;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
}

.modal-section {
  margin-bottom: 2rem;
}

.modal-section h3 {
  font-family: 'Poppins', 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', 'Helvetica Neue', Arial, sans-serif;
  font-size: 1.25rem;
  font-weight: 600;
  color: #1f2937;
  margin: 0 0 1rem 0;
  padding-bottom: 0.5rem;
  border-bottom: 2px solid #e5e7eb;
  letter-spacing: -0.02em;
  font-feature-settings: 'cv02', 'cv03', 'cv04', 'cv11';
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
  font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', 'Helvetica Neue', Arial, sans-serif;
  font-weight: 600;
  color: #6b7280;
  font-size: 14px;
  letter-spacing: 0.01em;
  font-feature-settings: 'cv02', 'cv03', 'cv04', 'cv11';
}

.info-item span {
  font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', 'Helvetica Neue', Arial, sans-serif;
  color: #1f2937;
  font-size: 16px;
  font-weight: 500;
  letter-spacing: 0.01em;
  font-feature-settings: 'cv02', 'cv03', 'cv04', 'cv11';
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
  font-family: 'Poppins', 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', 'Helvetica Neue', Arial, sans-serif;
  font-size: 1.25rem;
  font-weight: 600;
  color: #1f2937;
  letter-spacing: -0.01em;
  font-feature-settings: 'cv02', 'cv03', 'cv04', 'cv11';
}

.price-value {
  font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', 'Helvetica Neue', Arial, sans-serif;
  font-size: 2rem;
  font-weight: 700;
  color: #059669;
  letter-spacing: -0.03em;
  font-feature-settings: 'cv02', 'cv03', 'cv04', 'cv11';
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
  font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', 'Helvetica Neue', Arial, sans-serif;
  color: #6b7280;
  font-size: 14px;
  font-weight: 500;
  letter-spacing: 0.01em;
  font-feature-settings: 'cv02', 'cv03', 'cv04', 'cv11';
}

.cost-value {
  font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', 'Helvetica Neue', Arial, sans-serif;
  color: #1f2937;
  font-weight: 600;
  letter-spacing: 0.01em;
  font-feature-settings: 'cv02', 'cv03', 'cv04', 'cv11';
}

.amenities-list {
  display: flex;
  flex-wrap: wrap;
  gap: 0.5rem;
}

.amenity-tag {
  font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', 'Helvetica Neue', Arial, sans-serif;
  background: #3b82f6;
  color: white;
  padding: 6px 12px;
  border-radius: 20px;
  font-size: 14px;
  font-weight: 500;
  letter-spacing: 0.01em;
  font-feature-settings: 'cv02', 'cv03', 'cv04', 'cv11';
}

.description, .mobiliacao {
  font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', 'Helvetica Neue', Arial, sans-serif;
  font-size: 16px;
  font-weight: 400;
  line-height: 1.6;
  color: #4b5563;
  margin: 0;
  letter-spacing: 0.01em;
  font-feature-settings: 'cv02', 'cv03', 'cv04', 'cv11';
}

/* System Info Styles */
.system-info {
  background: #f8fafc;
  border: 1px solid #e1e5e9;
  border-radius: 12px;
  padding: 1.5rem;
}

.system-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: 1.5rem;
}

.system-item {
  display: flex;
  align-items: center;
  gap: 1rem;
  padding: 1rem;
  background: white;
  border-radius: 8px;
  border: 1px solid #e1e5e9;
  transition: all 0.15s ease;
}

.system-item:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
}

.system-icon {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 40px;
  height: 40px;
  background: #3b82f6;
  border-radius: 8px;
  color: white;
  flex-shrink: 0;
}

.system-content {
  display: flex;
  flex-direction: column;
  gap: 0.25rem;
  flex: 1;
}

.system-content label {
  font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', 'Helvetica Neue', Arial, sans-serif;
  font-weight: 600;
  color: #6b7280;
  font-size: 12px;
  text-transform: uppercase;
  letter-spacing: 0.5px;
  font-feature-settings: 'cv02', 'cv03', 'cv04', 'cv11';
}

.system-content span {
  font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', 'Helvetica Neue', Arial, sans-serif;
  color: #1f2937;
  font-size: 16px;
  font-weight: 600;
  letter-spacing: -0.01em;
  font-feature-settings: 'cv02', 'cv03', 'cv04', 'cv11';
}


.modal-footer {
  display: flex;
  justify-content: flex-end;
  gap: 1rem;
  padding: 1.5rem 2rem;
  border-top: 1px solid #e5e7eb;
  background: white;
  border-radius: 0 0 8px 8px;
  flex-shrink: 0;
}

/* Botões */
.btn {
  padding: 8px 16px;
  border: none;
  border-radius: 6px;
  font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', 'Helvetica Neue', Arial, sans-serif;
  font-size: 14px;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.1s ease;
  text-decoration: none;
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
  background: white;
  color: #374151;
  border: 1px solid #d1d5db;
}

.btn-secondary:hover {
  background: #f9fafb;
  border-color: #9ca3af;
}

/* Animações otimizadas */
@keyframes fadeIn {
  from { opacity: 0; }
  to { opacity: 1; }
}

@keyframes slideUp {
  from { 
    opacity: 0; 
    transform: translateY(10px); 
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
  
  .system-grid {
    grid-template-columns: 1fr;
  }
  
  .system-item {
    flex-direction: column;
    text-align: center;
    gap: 0.75rem;
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
