import { createRouter, createWebHistory } from 'vue-router'
import { useAuthStore } from '../stores/auth'

const LoginView = () => import('../views/LoginView.vue')
const ListView  = () => import('../views/ListView.vue')
const ProfileView = () => import('../views/ProfileView.vue')
const FavoritesView = () => import('../views/FavoritesView.vue')

const router = createRouter({
  history: createWebHistory(),
  routes: [
    { path: '/login', name: 'login', component: LoginView },
    { path: '/register', name: 'register', component: () => import('../views/RegisterView.vue') },
    { path: '/', redirect: '/lista' },
    { path: '/lista', name: 'lista', component: ListView, meta: { requiresAuth: true } },
    { path: '/favoritos', name: 'favoritos', component: FavoritesView, meta: { requiresAuth: true } },
    { path: '/perfil', name: 'perfil', component: ProfileView, meta: { requiresAuth: true } },
  ],
})

router.beforeEach((to) => {
  const auth = useAuthStore()
  if (to.meta.requiresAuth && !auth.token) {
    return { name: 'login', query: { redirect: to.fullPath } }
  }
})

export default router