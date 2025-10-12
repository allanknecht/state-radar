import { defineStore } from 'pinia'
import api from '../lib/api'

export const useAuthStore = defineStore('auth', {
  state: () => ({
    token: '',
    user: null,
    loading: false,
    error: '',
  }),
  actions: {
    loadFromStorage() {
      const t = localStorage.getItem('token')
      const u = localStorage.getItem('user')
      if (t) this.token = t
      if (u) this.user = JSON.parse(u)
    },
    async login(email, password) {
      this.loading = true
      this.error = ''
      try {
        const resp = await api.post('/users/sign_in', { user: { email, password } })

        let token = resp.headers?.authorization || resp.headers?.Authorization
        if (token && token.toLowerCase().startsWith('bearer ')) {
          token = token.slice(7)
        }
        if (!token && resp.data?.token) token = resp.data.token[0]
        if (!token) throw new Error('Token não recebido no login')

        const user = resp.data?.user || { email }
        this.token = token
        this.user = user
        localStorage.setItem('token', token)
        localStorage.setItem('user', JSON.stringify(user))
      } catch (err) {
        this.error = err?.response?.data?.error || err.message || 'Falha no login'
        throw err
      } finally {
        this.loading = false
      }
    },
    logout() {
      this.token = ''
      this.user = null
      localStorage.removeItem('token')
      localStorage.removeItem('user')
    },
  },
})
