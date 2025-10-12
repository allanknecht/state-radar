<template>
  <div class="register-container">
    <div class="register-card">
      <div class="register-header">
        <h1 class="register-title">Criar Conta</h1>
        <p class="register-subtitle">Preencha os dados para criar sua conta</p>
      </div>

      <form @submit.prevent="handleRegister" class="register-form">
        <div class="form-group">
          <label for="email" class="form-label">Email</label>
          <input
            id="email"
            v-model="form.email"
            type="email"
            class="form-input"
            :class="{ 'error': errors.email }"
            placeholder="seu@email.com"
            required
            @blur="validateEmail"
          >
          <span v-if="errors.email" class="error-message">{{ errors.email }}</span>
        </div>

        <div class="form-group">
          <label for="password" class="form-label">Senha</label>
          <input
            id="password"
            v-model="form.password"
            type="password"
            class="form-input"
            :class="{ 'error': errors.password }"
            placeholder="Mínimo 6 caracteres"
            required
            @blur="validatePassword"
          >
          <span v-if="errors.password" class="error-message">{{ errors.password }}</span>
        </div>

        <div class="form-group">
          <label for="passwordConfirmation" class="form-label">Confirmar Senha</label>
          <input
            id="passwordConfirmation"
            v-model="form.passwordConfirmation"
            type="password"
            class="form-input"
            :class="{ 'error': errors.passwordConfirmation }"
            placeholder="Digite a senha novamente"
            required
            @blur="validatePasswordConfirmation"
          >
          <span v-if="errors.passwordConfirmation" class="error-message">{{ errors.passwordConfirmation }}</span>
        </div>

        <button 
          type="submit" 
          class="register-btn"
          :disabled="loading || !isFormValid"
          :class="{ 'loading': loading }"
        >
          <span v-if="loading" class="spinner"></span>
          <span v-if="loading">Criando conta...</span>
          <span v-else>Criar Conta</span>
        </button>

        <div v-if="error" class="error-banner">
          {{ error }}
        </div>
      </form>

      <div class="register-footer">
        <p>Já tem uma conta?</p>
        <router-link to="/login" class="login-link">Fazer login</router-link>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import { useRouter } from 'vue-router'
import api from '../lib/api'

const router = useRouter()

const form = ref({
  email: '',
  password: '',
  passwordConfirmation: ''
})

const errors = ref({
  email: '',
  password: '',
  passwordConfirmation: ''
})

const loading = ref(false)
const error = ref('')

const isFormValid = computed(() => {
  return form.value.email && 
         form.value.password && 
         form.value.passwordConfirmation &&
         !errors.value.email &&
         !errors.value.password &&
         !errors.value.passwordConfirmation
})

function validateEmail() {
  const email = form.value.email
  if (!email) {
    errors.value.email = 'Email é obrigatório'
    return
  }
  
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/
  if (!emailRegex.test(email)) {
    errors.value.email = 'Email inválido'
    return
  }
  
  errors.value.email = ''
}

function validatePassword() {
  const password = form.value.password
  if (!password) {
    errors.value.password = 'Senha é obrigatória'
    return
  }
  
  if (password.length < 6) {
    errors.value.password = 'Senha deve ter pelo menos 6 caracteres'
    return
  }
  
  errors.value.password = ''
}

function validatePasswordConfirmation() {
  const password = form.value.password
  const passwordConfirmation = form.value.passwordConfirmation
  
  if (!passwordConfirmation) {
    errors.value.passwordConfirmation = 'Confirmação de senha é obrigatória'
    return
  }
  
  if (password !== passwordConfirmation) {
    errors.value.passwordConfirmation = 'Senhas não coincidem'
    return
  }
  
  errors.value.passwordConfirmation = ''
}

async function handleRegister() {
  // Validar todos os campos
  validateEmail()
  validatePassword()
  validatePasswordConfirmation()
  
  if (!isFormValid.value) {
    return
  }
  
  loading.value = true
  error.value = ''
  
  try {
    const response = await api.post('/users', {
      user: {
        email: form.value.email,
        password: form.value.password,
        password_confirmation: form.value.passwordConfirmation
      }
    })
    
    // Sucesso no cadastro
    console.log('Usuário criado com sucesso:', response.data)
    
    router.push({
      name: 'login',
      query: { 
        message: 'Conta criada com sucesso! Faça login para continuar.' 
      }
    })
    
  } catch (err) {
    console.error('Erro no cadastro:', err)
    
    if (err.response?.data?.errors) {
      // Erros de validação do backend
      const backendErrors = err.response.data.errors
      if (Array.isArray(backendErrors)) {
        error.value = backendErrors.join(', ')
      } else {
        error.value = 'Erro na validação dos dados'
      }
    } else {
      error.value = err.response?.data?.error || 'Erro ao criar conta. Tente novamente.'
    }
  } finally {
    loading.value = false
  }
}
</script>

<style scoped>
.register-container {
  min-height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 2rem;
  background: linear-gradient(135deg, #f8fafc 0%, #e2e8f0 100%);
}

.register-card {
  background: white;
  border-radius: 20px;
  box-shadow: 0 20px 40px rgba(0, 0, 0, 0.1);
  padding: 3rem;
  width: 100%;
  max-width: 480px;
  border: 1px solid #e1e5e9;
}

.register-header {
  text-align: center;
  margin-bottom: 2rem;
}

.register-title {
  font-family: var(--font-primary);
  font-size: 2rem;
  font-weight: 800;
  color: #1f2937;
  margin: 0 0 0.5rem 0;
  letter-spacing: -0.02em;
}

.register-subtitle {
  font-family: var(--font-primary);
  color: #6b7280;
  font-size: 1rem;
  font-weight: 500;
  margin: 0;
}

.register-form {
  display: flex;
  flex-direction: column;
  gap: 1.5rem;
}

.form-group {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
}

.form-label {
  font-family: var(--font-primary);
  font-size: 14px;
  font-weight: 600;
  color: #374151;
}

.form-input {
  padding: 14px 16px;
  border: 2px solid #e1e5e9;
  border-radius: 12px;
  font-family: var(--font-primary);
  font-size: 16px;
  font-weight: 500;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  background: white;
}

.form-input:focus {
  outline: none;
  border-color: #667eea;
  box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
}

.form-input.error {
  border-color: #dc2626;
  box-shadow: 0 0 0 3px rgba(220, 38, 38, 0.1);
}

.error-message {
  font-family: var(--font-primary);
  font-size: 14px;
  color: #dc2626;
  font-weight: 500;
}

.register-btn {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  border: none;
  border-radius: 12px;
  padding: 16px 24px;
  font-family: var(--font-primary);
  font-size: 16px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
  margin-top: 1rem;
}

.register-btn:hover:not(:disabled) {
  transform: translateY(-2px);
  box-shadow: 0 8px 25px rgba(102, 126, 234, 0.3);
}

.register-btn:disabled {
  opacity: 0.6;
  cursor: not-allowed;
  transform: none;
}

.register-btn.loading {
  background: #9ca3af;
}

.spinner {
  width: 20px;
  height: 20px;
  border: 2px solid rgba(255, 255, 255, 0.3);
  border-top: 2px solid white;
  border-radius: 50%;
  animation: spin 1s linear infinite;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}

.error-banner {
  background: #fef2f2;
  border: 1px solid #fecaca;
  color: #dc2626;
  padding: 12px 16px;
  border-radius: 8px;
  font-family: var(--font-primary);
  font-size: 14px;
  font-weight: 500;
  text-align: center;
}

.register-footer {
  text-align: center;
  margin-top: 2rem;
  padding-top: 2rem;
  border-top: 1px solid #e1e5e9;
}

.register-footer p {
  font-family: var(--font-primary);
  color: #6b7280;
  font-size: 14px;
  font-weight: 500;
  margin: 0 0 0.5rem 0;
}

.login-link {
  font-family: var(--font-primary);
  color: #667eea;
  text-decoration: none;
  font-weight: 600;
  font-size: 14px;
  transition: color 0.3s ease;
}

.login-link:hover {
  color: #5a67d8;
}

/* Responsividade */
@media (max-width: 768px) {
  .register-container {
    padding: 1rem;
  }
  
  .register-card {
    padding: 2rem;
  }
  
  .register-title {
    font-size: 1.75rem;
  }
}

@media (max-width: 480px) {
  .register-card {
    padding: 1.5rem;
  }
  
  .register-title {
    font-size: 1.5rem;
  }
}
</style>
