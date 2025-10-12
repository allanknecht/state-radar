<template>
  <div class="profile-container">
    <!-- Header -->
    <AppHeader 
      @logout="sair"
    />

    <div class="profile-content">
      <div class="profile-card">
        <div class="profile-header">
          <h2>Meu Perfil</h2>
          <p>Gerencie suas informações e configurações de conta</p>
        </div>

        <!-- Informações do Usuário -->
        <div class="profile-section">
          <h3>Informações da Conta</h3>
          <div class="user-info">
            <div class="info-item">
              <label>Email:</label>
              <span>{{ user?.email || 'Carregando...' }}</span>
            </div>
            <div class="info-item">
              <label>Membro desde:</label>
              <span>{{ formatDate(user?.created_at) }}</span>
            </div>
          </div>
        </div>

        <!-- Trocar Senha -->
        <div class="profile-section">
          <h3>Alterar Senha</h3>
          <form @submit.prevent="changePassword" class="password-form">
            <div class="form-group">
              <label for="current-password">Senha Atual:</label>
              <input 
                v-model="passwordForm.currentPassword"
                type="password" 
                id="current-password"
                required
                :disabled="passwordLoading"
              >
            </div>
            
            <div class="form-group">
              <label for="new-password">Nova Senha:</label>
              <input 
                v-model="passwordForm.newPassword"
                type="password" 
                id="new-password"
                required
                minlength="6"
                :disabled="passwordLoading"
              >
            </div>
            
            <div class="form-group">
              <label for="confirm-password">Confirmar Nova Senha:</label>
              <input 
                v-model="passwordForm.confirmPassword"
                type="password" 
                id="confirm-password"
                required
                minlength="6"
                :disabled="passwordLoading"
              >
            </div>

            <div v-if="passwordError" class="error-message">
              {{ passwordError }}
            </div>

            <div v-if="passwordSuccess" class="success-message">
              {{ passwordSuccess }}
            </div>

            <button 
              type="submit" 
              class="btn btn-primary"
              :disabled="passwordLoading || !isPasswordFormValid"
            >
              <span v-if="passwordLoading">Alterando...</span>
              <span v-else>Alterar Senha</span>
            </button>
          </form>
        </div>

        <!-- Deletar Conta -->
        <div class="profile-section danger-section">
          <h3>Zona de Perigo</h3>
          <div class="danger-content">
            <div class="warning-text">
              <strong>Atenção:</strong> Deletar sua conta é uma ação irreversível. 
              Todos os seus dados serão permanentemente removidos.
            </div>
            
            <button 
              @click="showDeleteModal = true"
              class="btn btn-danger"
              :disabled="deleteLoading"
            >
              Deletar Conta
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Modal de Confirmação de Delete -->
    <div v-if="showDeleteModal" class="modal-overlay" @click="showDeleteModal = false">
      <div class="modal" @click.stop>
        <div class="modal-header">
          <h3>Confirmar Exclusão</h3>
        </div>
        
        <div class="modal-body">
          <p>Tem certeza que deseja deletar sua conta?</p>
          <p><strong>Esta ação não pode ser desfeita.</strong></p>
          
          <div class="form-group">
            <label for="delete-confirm">Digite "DELETAR" para confirmar:</label>
            <input 
              v-model="deleteConfirm"
              type="text" 
              id="delete-confirm"
              placeholder="DELETAR"
              :disabled="deleteLoading"
            >
          </div>
          
          <div v-if="deleteError" class="error-message">
            {{ deleteError }}
          </div>
        </div>
        
        <div class="modal-footer">
          <button 
            @click="showDeleteModal = false"
            class="btn btn-secondary"
            :disabled="deleteLoading"
          >
            Cancelar
          </button>
          <button 
            @click="deleteAccount"
            class="btn btn-danger"
            :disabled="deleteLoading || deleteConfirm !== 'DELETAR'"
          >
            <span v-if="deleteLoading">Deletando...</span>
            <span v-else>Deletar Conta</span>
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import api from '../lib/api'
import { useAuthStore } from '../stores/auth'
import AppHeader from '../components/AppHeader.vue'

const router = useRouter()
const auth = useAuthStore()

// Estados
const passwordLoading = ref(false)
const deleteLoading = ref(false)
const passwordError = ref('')
const passwordSuccess = ref('')
const deleteError = ref('')
const showDeleteModal = ref(false)
const deleteConfirm = ref('')

// Formulário de senha
const passwordForm = ref({
  currentPassword: '',
  newPassword: '',
  confirmPassword: ''
})

// Computed
const user = computed(() => auth.user)
const isPasswordFormValid = computed(() => {
  return passwordForm.value.currentPassword && 
         passwordForm.value.newPassword && 
         passwordForm.value.confirmPassword &&
         passwordForm.value.newPassword === passwordForm.value.confirmPassword
})

// Funções
function formatDate(dateString) {
  if (!dateString) return 'N/A'
  return new Date(dateString).toLocaleDateString('pt-BR')
}

async function changePassword() {
  passwordLoading.value = true
  passwordError.value = ''
  passwordSuccess.value = ''

  try {
    if (passwordForm.value.newPassword !== passwordForm.value.confirmPassword) {
      throw new Error('As senhas não coincidem')
    }

    if (passwordForm.value.newPassword.length < 6) {
      throw new Error('A nova senha deve ter pelo menos 6 caracteres')
    }

    await api.put('/users/password', {
      user: {
        current_password: passwordForm.value.currentPassword,
        password: passwordForm.value.newPassword,
        password_confirmation: passwordForm.value.confirmPassword
      }
    })

    passwordSuccess.value = 'Senha alterada com sucesso!'
    passwordForm.value = {
      currentPassword: '',
      newPassword: '',
      confirmPassword: ''
    }
  } catch (error) {
    console.error('Erro ao alterar senha:', error)
    passwordError.value = error?.response?.data?.error || 'Erro ao alterar senha'
  } finally {
    passwordLoading.value = false
  }
}

async function deleteAccount() {
  deleteLoading.value = true
  deleteError.value = ''

  try {
    await api.delete('/users')
    
    // Logout após deletar conta
    auth.logout()
    router.push({ name: 'login' })
  } catch (error) {
    console.error('Erro ao deletar conta:', error)
    deleteError.value = error?.response?.data?.error || 'Erro ao deletar conta'
  } finally {
    deleteLoading.value = false
  }
}

function sair() {
  auth.logout()
  router.push({ name: 'login' })
}

onMounted(() => {
  if (!auth.token) {
    router.push({ name: 'login' })
  }
})
</script>

<style scoped>
.profile-container {
  max-width: 800px;
  margin: 0 auto;
  padding: 0 20px;
}

.profile-content {
  padding: 2rem 0;
}

.profile-card {
  background: white;
  border-radius: 12px;
  box-shadow: 0 4px 6px rgba(0,0,0,0.1);
  overflow: hidden;
}

.profile-header {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  padding: 2rem;
  text-align: center;
}

.profile-header h2 {
  margin: 0 0 0.5rem 0;
  font-size: 1.75rem;
  font-weight: 600;
}

.profile-header p {
  margin: 0;
  opacity: 0.9;
}

.profile-section {
  padding: 2rem;
  border-bottom: 1px solid #e1e5e9;
}

.profile-section:last-child {
  border-bottom: none;
}

.profile-section h3 {
  margin: 0 0 1.5rem 0;
  font-size: 1.25rem;
  font-weight: 600;
  color: #1f2937;
}

.user-info {
  display: grid;
  gap: 1rem;
}

.info-item {
  display: flex;
  flex-direction: column;
  gap: 0.25rem;
}

.info-item label {
  font-weight: 600;
  color: #374151;
  font-size: 0.875rem;
}

.info-item span {
  color: #6b7280;
  font-size: 1rem;
}

.password-form {
  display: grid;
  gap: 1.5rem;
}

.form-group {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
}

.form-group label {
  font-weight: 600;
  color: #374151;
  font-size: 0.875rem;
}

.form-group input {
  padding: 12px 16px;
  border: 2px solid #e1e5e9;
  border-radius: 8px;
  font-size: 1rem;
  transition: all 0.3s ease;
}

.form-group input:focus {
  outline: none;
  border-color: #667eea;
  box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
}

.form-group input:disabled {
  background: #f9fafb;
  color: #9ca3af;
}

.danger-section {
  background: #fef2f2;
  border-left: 4px solid #dc2626;
}

.danger-content {
  display: flex;
  flex-direction: column;
  gap: 1rem;
}

.warning-text {
  color: #991b1b;
  font-size: 0.875rem;
  line-height: 1.5;
}

.btn {
  padding: 12px 24px;
  border: none;
  border-radius: 8px;
  font-size: 1rem;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s ease;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  text-decoration: none;
}

.btn:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

.btn-primary {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
}

.btn-primary:hover:not(:disabled) {
  transform: translateY(-2px);
  box-shadow: 0 8px 25px rgba(102, 126, 234, 0.3);
}

.btn-secondary {
  background: #f8fafc;
  color: #374151;
  border: 2px solid #e1e5e9;
}

.btn-secondary:hover:not(:disabled) {
  background: #e1e5e9;
}

.btn-danger {
  background: #dc2626;
  color: white;
}

.btn-danger:hover:not(:disabled) {
  background: #b91c1c;
  transform: translateY(-1px);
}

.error-message {
  background: #fef2f2;
  color: #dc2626;
  padding: 12px 16px;
  border-radius: 8px;
  border: 1px solid #fecaca;
  font-size: 0.875rem;
}

.success-message {
  background: #f0fdf4;
  color: #16a34a;
  padding: 12px 16px;
  border-radius: 8px;
  border: 1px solid #bbf7d0;
  font-size: 0.875rem;
}

/* Modal */
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
}

.modal {
  background: white;
  border-radius: 12px;
  box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.1);
  max-width: 500px;
  width: 90%;
  max-height: 90vh;
  overflow-y: auto;
}

.modal-header {
  padding: 1.5rem 1.5rem 0;
}

.modal-header h3 {
  margin: 0;
  color: #dc2626;
  font-size: 1.25rem;
  font-weight: 600;
}

.modal-body {
  padding: 1.5rem;
}

.modal-body p {
  margin: 0 0 1rem 0;
  color: #374151;
  line-height: 1.5;
}

.modal-footer {
  padding: 0 1.5rem 1.5rem;
  display: flex;
  gap: 1rem;
  justify-content: flex-end;
}

/* Responsividade */
@media (max-width: 768px) {
  .profile-container {
    padding: 0 16px;
  }
  
  .profile-section {
    padding: 1.5rem;
  }
  
  .modal-footer {
    flex-direction: column;
  }
  
  .modal-footer .btn {
    width: 100%;
  }
}
</style>
