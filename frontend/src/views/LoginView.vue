<template>
  <div class="login-container">
    <div class="login-card">
      <div class="login-header">
        <h1 class="login-title">Entrar</h1>
        <p v-if="successMessage" class="success-message">{{ successMessage }}</p>
      </div>

      <form @submit.prevent="submit" class="login-form">
        <div class="form-group">
          <label for="email" class="form-label">Email</label>
          <input
            id="email"
            v-model="email"
            type="email"
            class="form-input"
            placeholder="seu@email.com"
            required
          >
        </div>

        <div class="form-group">
          <label for="password" class="form-label">Senha</label>
          <input
            id="password"
            v-model="password"
            type="password"
            class="form-input"
            placeholder="Digite sua senha"
            required
          >
        </div>

        <button 
          type="submit" 
          class="login-btn"
          :disabled="auth.loading"
          :class="{ 'loading': auth.loading }"
        >
          <span v-if="auth.loading" class="spinner"></span>
          <span v-if="auth.loading">Entrando...</span>
          <span v-else>Entrar</span>
        </button>

        <div v-if="auth.error" class="error-banner">
          {{ auth.error }}
        </div>
      </form>

      <div class="login-footer">
        <p>Não tem uma conta?</p>
        <router-link to="/register" class="register-link">Criar conta</router-link>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useAuthStore } from '../stores/auth'

const auth = useAuthStore()
const router = useRouter()
const route = useRoute()

const email = ref('')
const password = ref('')

const successMessage = computed(() => {
  return route.query.message || ''
})

const submit = async () => {
  try {
    await auth.login(email.value, password.value)
    const redirect = route.query.redirect || '/lista'
    router.push(redirect)
  } catch (e) {}
}
</script>

<style scoped>
.login-container {
  min-height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 2rem;
  background: linear-gradient(135deg, #f8fafc 0%, #e2e8f0 100%);
}

.login-card {
  background: white;
  border-radius: 20px;
  box-shadow: 0 20px 40px rgba(0, 0, 0, 0.1);
  padding: 3rem;
  width: 100%;
  max-width: 420px;
  border: 1px solid #e1e5e9;
}

.login-header {
  text-align: center;
  margin-bottom: 2rem;
}

.login-title {
  font-family: 'Inter', 'Segoe UI', 'Roboto', 'Helvetica Neue', Arial, sans-serif;
  font-size: 2rem;
  font-weight: 800;
  color: #1f2937;
  margin: 0 0 0.5rem 0;
  letter-spacing: -0.02em;
}

.success-message {
  font-family: 'Inter', 'Segoe UI', 'Roboto', 'Helvetica Neue', Arial, sans-serif;
  color: #059669;
  font-size: 14px;
  font-weight: 500;
  background: #f0fdf4;
  border: 1px solid #bbf7d0;
  padding: 12px 16px;
  border-radius: 8px;
  margin: 0;
}

.login-form {
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
  font-family: 'Inter', 'Segoe UI', 'Roboto', 'Helvetica Neue', Arial, sans-serif;
  font-size: 14px;
  font-weight: 600;
  color: #374151;
}

.form-input {
  padding: 14px 16px;
  border: 2px solid #e1e5e9;
  border-radius: 12px;
  font-family: 'Inter', 'Segoe UI', 'Roboto', 'Helvetica Neue', Arial, sans-serif;
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

.login-btn {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  border: none;
  border-radius: 12px;
  padding: 16px 24px;
  font-family: 'Inter', 'Segoe UI', 'Roboto', 'Helvetica Neue', Arial, sans-serif;
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

.login-btn:hover:not(:disabled) {
  transform: translateY(-2px);
  box-shadow: 0 8px 25px rgba(102, 126, 234, 0.3);
}

.login-btn:disabled {
  opacity: 0.6;
  cursor: not-allowed;
  transform: none;
}

.login-btn.loading {
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
  font-family: 'Inter', 'Segoe UI', 'Roboto', 'Helvetica Neue', Arial, sans-serif;
  font-size: 14px;
  font-weight: 500;
  text-align: center;
}

.login-footer {
  text-align: center;
  margin-top: 2rem;
  padding-top: 2rem;
  border-top: 1px solid #e1e5e9;
}

.login-footer p {
  font-family: 'Inter', 'Segoe UI', 'Roboto', 'Helvetica Neue', Arial, sans-serif;
  color: #6b7280;
  font-size: 14px;
  font-weight: 500;
  margin: 0 0 0.5rem 0;
}

.register-link {
  font-family: 'Inter', 'Segoe UI', 'Roboto', 'Helvetica Neue', Arial, sans-serif;
  color: #667eea;
  text-decoration: none;
  font-weight: 600;
  font-size: 14px;
  transition: color 0.3s ease;
}

.register-link:hover {
  color: #5a67d8;
}

/* Responsividade */
@media (max-width: 768px) {
  .login-container {
    padding: 1rem;
  }
  
  .login-card {
    padding: 2rem;
  }
  
  .login-title {
    font-size: 1.75rem;
  }
}

@media (max-width: 480px) {
  .login-card {
    padding: 1.5rem;
  }
  
  .login-title {
    font-size: 1.5rem;
  }
}
</style>
