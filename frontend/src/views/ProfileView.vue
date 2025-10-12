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
        <div class="profile-section">
          <div class="delete-account-section">
            <button 
              @click="showDeleteModal = true"
              class="btn-delete-account"
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
          <p>Esta ação não pode ser desfeita e todos os seus dados serão permanentemente removidos.</p>
          
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
            :disabled="deleteLoading"
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

// Formulário de senha
const passwordForm = ref({
  currentPassword: '',
  newPassword: '',
  confirmPassword: ''
})

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
@import url('https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap');
@import url('https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700;800&display=swap');
.profile-container {
  max-width: 1200px;
  margin: 0 auto;
  padding: 0 20px;
  box-sizing: border-box;
}

.profile-content {
  padding: 2rem 0;
}


.profile-card {
  background: white;
  border-radius: 8px;
  box-shadow: 0 1px 3px rgba(0,0,0,0.1);
  overflow: hidden;
  border: 1px solid #e5e7eb;
}

.profile-header {
  background: #3b82f6;
  color: white;
  padding: 1.5rem;
  text-align: center;
}

.profile-header h2 {
  margin: 0 0 0.5rem 0;
  font-family: 'Poppins', 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', 'Helvetica Neue', Arial, sans-serif;
  font-size: 1.5rem;
  font-weight: 600;
  letter-spacing: -0.01em;
  font-feature-settings: 'cv02', 'cv03', 'cv04', 'cv11';
}

.profile-header p {
  margin: 0;
  opacity: 0.9;
  font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', 'Helvetica Neue', Arial, sans-serif;
  font-weight: 400;
  letter-spacing: 0.01em;
  font-feature-settings: 'cv02', 'cv03', 'cv04', 'cv11';
}

.profile-section {
  padding: 1.5rem;
  border-bottom: 1px solid #e5e7eb;
}

.profile-section:last-child {
  border-bottom: none;
}

.profile-section h3 {
  margin: 0 0 1rem 0;
  font-family: 'Poppins', 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', 'Helvetica Neue', Arial, sans-serif;
  font-size: 1.125rem;
  font-weight: 600;
  color: #111827;
  letter-spacing: -0.01em;
  font-feature-settings: 'cv02', 'cv03', 'cv04', 'cv11';
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
  font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', 'Helvetica Neue', Arial, sans-serif;
  font-weight: 500;
  color: #374151;
  font-size: 14px;
  letter-spacing: 0.01em;
  font-feature-settings: 'cv02', 'cv03', 'cv04', 'cv11';
}

.info-item span {
  font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', 'Helvetica Neue', Arial, sans-serif;
  color: #6b7280;
  font-size: 14px;
  letter-spacing: 0.01em;
  font-feature-settings: 'cv02', 'cv03', 'cv04', 'cv11';
}

.password-form {
  display: grid;
  gap: 1rem;
}

.form-group {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
}

.form-group label {
  font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', 'Helvetica Neue', Arial, sans-serif;
  font-weight: 500;
  color: #374151;
  font-size: 14px;
  letter-spacing: 0.01em;
  font-feature-settings: 'cv02', 'cv03', 'cv04', 'cv11';
}

.form-group input {
  padding: 8px 12px;
  border: 1px solid #d1d5db;
  border-radius: 6px;
  font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', 'Helvetica Neue', Arial, sans-serif;
  font-size: 14px;
  transition: all 0.2s ease;
  letter-spacing: 0.01em;
  font-feature-settings: 'cv02', 'cv03', 'cv04', 'cv11';
}

.form-group input:focus {
  outline: none;
  border-color: #3b82f6;
  box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.1);
}

.form-group input:disabled {
  background: #f9fafb;
  color: #9ca3af;
}

.delete-account-section {
  display: flex;
  justify-content: center;
  padding: 1rem 0;
}

.btn-delete-account {
  background: transparent;
  color: #dc2626;
  border: 1px solid #fecaca;
  padding: 8px 16px;
  border-radius: 6px;
  font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', 'Helvetica Neue', Arial, sans-serif;
  font-size: 14px;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.2s ease;
  text-decoration: none;
  letter-spacing: 0.01em;
  font-feature-settings: 'cv02', 'cv03', 'cv04', 'cv11';
}

.btn-delete-account:hover:not(:disabled) {
  background: #fef2f2;
  border-color: #fca5a5;
  color: #b91c1c;
}

.btn-delete-account:disabled {
  opacity: 0.5;
  cursor: not-allowed;
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
  justify-content: center;
  text-decoration: none;
  letter-spacing: 0.01em;
  font-feature-settings: 'cv02', 'cv03', 'cv04', 'cv11';
}

.btn:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

.btn-primary {
  background: #3b82f6;
  color: white;
}

.btn-primary:hover:not(:disabled) {
  background: #2563eb;
}

.btn-secondary {
  background: #f9fafb;
  color: #374151;
  border: 1px solid #d1d5db;
}

.btn-secondary:hover:not(:disabled) {
  background: #f3f4f6;
}

.btn-danger {
  background: #dc2626;
  color: white;
}

.btn-danger:hover:not(:disabled) {
  background: #b91c1c;
}

.error-message {
  background: #fef2f2;
  color: #dc2626;
  padding: 8px 12px;
  border-radius: 6px;
  border: 1px solid #fecaca;
  font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', 'Helvetica Neue', Arial, sans-serif;
  font-size: 14px;
  letter-spacing: 0.01em;
  font-feature-settings: 'cv02', 'cv03', 'cv04', 'cv11';
}

.success-message {
  background: #f0fdf4;
  color: #16a34a;
  padding: 8px 12px;
  border-radius: 6px;
  border: 1px solid #bbf7d0;
  font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', 'Helvetica Neue', Arial, sans-serif;
  font-size: 14px;
  letter-spacing: 0.01em;
  font-feature-settings: 'cv02', 'cv03', 'cv04', 'cv11';
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
  border-radius: 8px;
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
  max-width: 500px;
  width: 90%;
  max-height: 90vh;
  overflow-y: auto;
}

.modal-header {
  padding: 1rem 1rem 0;
}

.modal-header h3 {
  margin: 0;
  color: #111827;
  font-family: 'Poppins', 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', 'Helvetica Neue', Arial, sans-serif;
  font-size: 1.125rem;
  font-weight: 600;
  letter-spacing: -0.01em;
  font-feature-settings: 'cv02', 'cv03', 'cv04', 'cv11';
}

.modal-body {
  padding: 1rem;
}

.modal-body p {
  margin: 0 0 1rem 0;
  color: #374151;
  line-height: 1.5;
  font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', 'Helvetica Neue', Arial, sans-serif;
  letter-spacing: 0.01em;
  font-feature-settings: 'cv02', 'cv03', 'cv04', 'cv11';
}

.modal-footer {
  padding: 0 1rem 1rem;
  display: flex;
  gap: 0.75rem;
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
