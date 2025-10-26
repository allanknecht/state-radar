<template>
  <div class="login-container">
    <div class="login-card">
      <div class="login-header">
        <div class="logo-section">
          <img src="/logo-new.svg" alt="BuscaImóveis" class="logo">
        </div>
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
  background: #f8fafc;
}

.login-card {
  background: white;
  border-radius: 8px;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
  padding: 2rem;
  width: 100%;
  max-width: 400px;
  border: 1px solid #e5e7eb;
}

.login-header {
  text-align: center;
  margin-bottom: 2rem;
}

.logo-section {
  display: flex;
  justify-content: center;
  margin-bottom: 1rem;
  margin-left: 68px;

}

.logo {
  height: 80px;
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

.login-title {
  font-family: var(--font-heading);
  font-size: 1.875rem;
  font-weight: 600;
  color: #111827;
  margin: 0 0 0.5rem 0;
  letter-spacing: -0.02em;
  font-feature-settings: 'cv02', 'cv03', 'cv04', 'cv11';
}

.success-message {
  font-family: var(--font-primary);
  color: #059669;
  font-size: 14px;
  font-weight: 500;
  background: #f0fdf4;
  border: 1px solid #bbf7d0;
  padding: 8px 12px;
  border-radius: 6px;
  margin: 0;
  letter-spacing: 0.01em;
  font-feature-settings: 'cv02', 'cv03', 'cv04', 'cv11';
}

.login-form {
  display: flex;
  flex-direction: column;
  gap: 1rem;
}

.form-group {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
}

.form-label {
  font-family: var(--font-primary);
  font-size: 14px;
  font-weight: 500;
  color: #374151;
  letter-spacing: 0.01em;
  font-feature-settings: 'cv02', 'cv03', 'cv04', 'cv11';
}

.form-input {
  padding: 8px 12px;
  border: 1px solid #d1d5db;
  border-radius: 6px;
  font-family: var(--font-primary);
  font-size: 14px;
  font-weight: 400;
  transition: all 0.2s ease;
  background: white;
  letter-spacing: 0.01em;
  font-feature-settings: 'cv02', 'cv03', 'cv04', 'cv11';
}

.form-input:focus {
  outline: none;
  border-color: #3b82f6;
  box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.1);
}

.login-btn {
  background: #3b82f6;
  color: white;
  border: none;
  border-radius: 6px;
  padding: 10px 16px;
  font-family: var(--font-primary);
  font-size: 14px;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.2s ease;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 6px;
  margin-top: 0.5rem;
  letter-spacing: 0.01em;
  font-feature-settings: 'cv02', 'cv03', 'cv04', 'cv11';
}

.login-btn:hover:not(:disabled) {
  background: #2563eb;
}

.login-btn:disabled {
  opacity: 0.6;
  cursor: not-allowed;
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
  padding: 8px 12px;
  border-radius: 6px;
  font-family: var(--font-primary);
  font-size: 14px;
  font-weight: 500;
  text-align: center;
  letter-spacing: 0.01em;
  font-feature-settings: 'cv02', 'cv03', 'cv04', 'cv11';
}

.login-footer {
  text-align: center;
  margin-top: 1.5rem;
  padding-top: 1.5rem;
  border-top: 1px solid #e5e7eb;
}

.login-footer p {
  font-family: var(--font-primary);
  color: #6b7280;
  font-size: 14px;
  font-weight: 400;
  margin: 0 0 0.5rem 0;
  letter-spacing: 0.01em;
  font-feature-settings: 'cv02', 'cv03', 'cv04', 'cv11';
}

.register-link {
  font-family: var(--font-primary);
  color: #3b82f6;
  text-decoration: none;
  font-weight: 500;
  font-size: 14px;
  transition: color 0.2s ease;
  letter-spacing: 0.01em;
  font-feature-settings: 'cv02', 'cv03', 'cv04', 'cv11';
}

.register-link:hover {
  color: #1d4ed8;
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
