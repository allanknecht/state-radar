<script setup>
import { useAuthStore } from './stores/auth'
const auth = useAuthStore()
auth.loadFromStorage()
</script>

<template>
  <router-view />
</template>