import axios from 'axios'
import { useAuthStore } from '../stores/auth'

const api = axios.create({
  baseURL: import.meta.env.API_URL || 'http://localhost:3000/api/v1',
  timeout: 15000,
})
api.interceptors.request.use((config) => {
  const auth = useAuthStore()
  if (auth.token) {
    config.headers = config.headers || {}
    config.headers.Authorization = `Bearer ${auth.token}`
  }
  return config
})

api.interceptors.response.use(
  (resp) => resp,
  (error) => {
    const status = error?.response?.status
    if (status === 401) {
      const auth = useAuthStore()
      auth.logout()
      if (location.pathname !== '/login') {
        window.location.href = '/login'
      }
    }
    return Promise.reject(error)
  }
)

export default api
