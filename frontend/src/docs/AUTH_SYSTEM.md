# Sistema de Autenticação - Documentação

## Visão Geral

O sistema de autenticação foi implementado com integração completa ao backend Rails, utilizando JWT (JSON Web Tokens) para autenticação segura.

## Endpoints da API

### 1. Cadastro de Usuário
- **URL**: `POST /api/v1/users`
- **Controller**: `Api::V1::Users::RegistrationsController`
- **Parâmetros**:
  ```json
  {
    "user": {
      "email": "usuario@exemplo.com",
      "password": "senha123",
      "password_confirmation": "senha123"
    }
  }
  ```
- **Resposta de Sucesso** (201):
  ```json
  {
    "user": {
      "id": 1,
      "email": "usuario@exemplo.com"
    }
  }
  ```
- **Resposta de Erro** (422):
  ```json
  {
    "errors": ["Email has already been taken", "Password is too short"]
  }
  ```

### 2. Login de Usuário
- **URL**: `POST /api/v1/users/sign_in`
- **Controller**: `Api::V1::Users::SessionsController`
- **Parâmetros**:
  ```json
  {
    "user": {
      "email": "usuario@exemplo.com",
      "password": "senha123"
    }
  }
  ```
- **Resposta de Sucesso** (200):
  ```json
  {
    "user": {
      "id": 1,
      "email": "usuario@exemplo.com"
    },
    "token": "eyJhbGciOiJIUzI1NiJ9..."
  }
  ```
- **Resposta de Erro** (401):
  ```json
  {
    "error": "Invalid email or password"
  }
  ```

### 3. Logout de Usuário
- **URL**: `DELETE /api/v1/users/sign_out`
- **Headers**: `Authorization: Bearer <token>`
- **Resposta**: `204 No Content`

## Componentes Frontend

### 1. RegisterView.vue
**Funcionalidades:**
- Formulário de cadastro com validação
- Campos: email, senha, confirmação de senha
- Validação em tempo real
- Integração com API de cadastro
- Redirecionamento para login após sucesso

**Validações:**
- Email obrigatório e formato válido
- Senha mínima de 6 caracteres
- Confirmação de senha deve coincidir
- Feedback visual de erros

### 2. LoginView.vue
**Funcionalidades:**
- Formulário de login
- Campos: email, senha
- Integração com API de login
- Redirecionamento após login
- Exibição de mensagens de sucesso

### 3. AuthStore (stores/auth.js)
**Funcionalidades:**
- Gerenciamento de estado de autenticação
- Armazenamento de token no localStorage
- Métodos de login, logout e verificação
- Interceptação de requisições para adicionar token

## Fluxo de Autenticação

### Cadastro de Novo Usuário
```
1. Usuário acessa /register
2. Preenche formulário de cadastro
3. Validação frontend (email, senha, confirmação)
4. Requisição POST /api/v1/users
5. Backend valida e cria usuário
6. Redirecionamento para /login com mensagem de sucesso
7. Usuário faz login normalmente
```

### Login de Usuário
```
1. Usuário acessa /login
2. Preenche email e senha
3. Requisição POST /api/v1/users/sign_in
4. Backend valida credenciais
5. Retorna token JWT
6. Token armazenado no localStorage
7. Redirecionamento para /lista
```

### Proteção de Rotas
```
1. Usuário tenta acessar rota protegida
2. Router verifica se há token válido
3. Se não há token, redireciona para /login
4. Se há token, permite acesso à rota
```

## Configuração da API

### Interceptadores Axios
```javascript
// Adiciona token automaticamente nas requisições
api.interceptors.request.use((config) => {
  const auth = useAuthStore()
  if (auth.token) {
    config.headers.Authorization = `Bearer ${auth.token}`
  }
  return config
})

// Trata erros de autenticação
api.interceptors.response.use(
  (resp) => resp,
  (error) => {
    if (error?.response?.status === 401) {
      const auth = useAuthStore()
      auth.logout()
      window.location.href = '/login'
    }
    return Promise.reject(error)
  }
)
```

## Segurança

### JWT Token
- Token gerado pelo Devise JWT
- Incluído automaticamente nas requisições
- Verificação de validade no backend
- Logout automático em caso de token inválido

### Validações
- **Frontend**: Validação em tempo real dos campos
- **Backend**: Validação de dados e regras de negócio
- **Senha**: Mínimo 6 caracteres
- **Email**: Formato válido e único

### Armazenamento
- Token armazenado no localStorage
- Persistência entre sessões do navegador
- Limpeza automática em logout

## Tratamento de Erros

### Erros de Cadastro
- Email já existente
- Senha muito curta
- Confirmação de senha não confere
- Validação de formato de email

### Erros de Login
- Credenciais inválidas
- Usuário não encontrado
- Senha incorreta

### Erros de Autenticação
- Token expirado
- Token inválido
- Usuário não autenticado

## Responsividade

### Design Mobile-First
- Layout adaptativo para todos os dispositivos
- Formulários otimizados para touch
- Navegação intuitiva em mobile

### Componentes Responsivos
- Cards de login/cadastro adaptáveis
- Botões com tamanho adequado para touch
- Tipografia legível em todas as telas

## Exemplos de Uso

### Cadastro Programático
```javascript
// Exemplo de uso do store de autenticação
import { useAuthStore } from '@/stores/auth'

const auth = useAuthStore()

// Verificar se está logado
if (auth.isLoggedIn) {
  console.log('Usuário logado:', auth.user)
}

// Fazer logout
auth.logout()
```

### Proteção de Componentes
```vue
<template>
  <div v-if="auth.isLoggedIn">
    Conteúdo protegido
  </div>
  <div v-else>
    Faça login para continuar
  </div>
</template>

<script setup>
import { useAuthStore } from '@/stores/auth'
const auth = useAuthStore()
</script>
```

## Vantagens da Implementação

1. **Segurança**: JWT tokens com validação no backend
2. **UX**: Validação em tempo real e feedback visual
3. **Performance**: Armazenamento local do token
4. **Escalabilidade**: Fácil adicionar novos campos
5. **Manutenibilidade**: Código modular e bem estruturado
6. **Responsividade**: Funciona em todos os dispositivos
