# 📚 Documentação da API - Sistema de Busca de Imóveis

## Visão Geral

Esta API REST permite o acesso programático ao sistema de busca de imóveis. Todas as requisições retornam JSON e utilizam autenticação JWT para endpoints protegidos.

**Base URL:** `http://localhost:3000/api/v1`

## 🔐 Autenticação

O sistema utiliza JWT (JSON Web Token) para autenticação. Para acessar endpoints protegidos, inclua o token no header:

```
Authorization: Bearer <seu_token_jwt>
```

### Fluxo de Autenticação

1. **Registro de usuário** - `POST /users/sign_up`
2. **Login** - `POST /users/sign_in`
3. **Usar token** - Incluir no header `Authorization`
4. **Logout** - `DELETE /users/sign_out`

## 📋 Endpoints

### 🔐 Autenticação

#### POST /users/sign_up
Registra um novo usuário no sistema.

**Request Body:**
```json
{
  "user": {
    "email": "usuario@email.com",
    "password": "senha123",
    "password_confirmation": "senha123"
  }
}
```

**Response (201):**
```json
{
  "status": "success",
  "message": "Usuário criado com sucesso",
  "data": {
    "user": {
      "id": 1,
      "email": "usuario@email.com"
    }
  }
}
```

#### POST /users/sign_in
Autentica um usuário e retorna o token JWT.

**Request Body:**
```json
{
  "user": {
    "email": "usuario@email.com",
    "password": "senha123"
  }
}
```

**Response (200):**
```json
{
  "status": "success",
  "message": "Login realizado com sucesso",
  "data": {
    "user": {
      "id": 1,
      "email": "usuario@email.com"
    },
    "token": "eyJhbGciOiJIUzI1NiJ9..."
  }
}
```

#### PATCH /users/password/change
Altera a senha do usuário autenticado.

**Headers:** `Authorization: Bearer <token>`

**Request Body:**
```json
{
  "user": {
    "current_password": "senha_atual",
    "password": "nova_senha",
    "password_confirmation": "nova_senha"
  }
}
```

#### DELETE /users/sign_out
Realiza logout do usuário (invalida o token).

**Headers:** `Authorization: Bearer <token>`

**Response (200):**
```json
{
  "status": "success",
  "message": "Logout realizado com sucesso"
}
```

### 🏠 Imóveis

#### GET /scraper_records
Lista imóveis com filtros e paginação.

**Headers:** `Authorization: Bearer <token>`

**Query Parameters:**
- `category` (string) - Categoria: "Venda" ou "Locação"
- `site` (string) - Site de origem: "solar", "simao", "mws"
- `min_price` (number) - Preço mínimo em reais
- `max_price` (number) - Preço máximo em reais
- `min_bedrooms` (integer) - Número mínimo de dormitórios
- `q` (string) - Busca por localização
- `sort` (string) - Ordenação: "price_asc", "price_desc"
- `page` (integer) - Número da página (padrão: 1)

**Exemplo de Requisição:**
```bash
GET /scraper_records?category=Venda&min_price=100000&max_price=500000&min_bedrooms=2&page=1
```

**Response (200):**
```json
{
  "data": [
    {
      "id": 1,
      "site": "solar",
      "categoria": "Venda",
      "codigo": "SOL123",
      "titulo": "Apartamento 2 dormitórios",
      "localizacao": "Centro, São Paulo - SP",
      "link": "https://solar.com/imovel/123",
      "imagem": "https://solar.com/images/123.jpg",
      "preco_brl": 350000.0,
      "dormitorios": 2,
      "suites": 1,
      "vagas": 1,
      "area_m2": 75.5,
      "condominio": 850.0,
      "iptu": 450.0,
      "banheiros": 2,
      "lavabos": 1,
      "area_privativa_m2": 65.0,
      "mobiliacao": "Não mobiliado",
      "amenities": ["Piscina", "Academia", "Playground"],
      "descricao": "Apartamento bem localizado...",
      "created_at": "2025-01-15T10:30:00.000Z",
      "updated_at": "2025-01-15T10:30:00.000Z"
    }
  ],
  "meta": {
    "page": 1,
    "total_pages": 25,
    "total_count": 500,
    "per": 20
  }
}
```

#### GET /scraper_records/:id
Retorna os detalhes de um imóvel específico.

**Headers:** `Authorization: Bearer <token>`

**Response (200):**
```json
{
  "data": {
    "id": 1,
    "site": "solar",
    "categoria": "Venda",
    "codigo": "SOL123",
    "titulo": "Apartamento 2 dormitórios",
    "localizacao": "Centro, São Paulo - SP",
    "link": "https://solar.com/imovel/123",
    "imagem": "https://solar.com/images/123.jpg",
    "preco_brl": 350000.0,
    "dormitorios": 2,
    "suites": 1,
    "vagas": 1,
    "area_m2": 75.5,
    "condominio": 850.0,
    "iptu": 450.0,
    "banheiros": 2,
    "lavabos": 1,
    "area_privativa_m2": 65.0,
    "mobiliacao": "Não mobiliado",
    "amenities": ["Piscina", "Academia", "Playground"],
    "descricao": "Apartamento bem localizado...",
    "created_at": "2025-01-15T10:30:00.000Z",
    "updated_at": "2025-01-15T10:30:00.000Z"
  }
}
```

**Response (404):**
```json
{
  "error": {
    "code": "not_found",
    "message": "Registro não encontrado"
  }
}
```

#### GET /scraper_records/sites
Lista todos os sites de origem disponíveis.

**Headers:** `Authorization: Bearer <token>`

**Response (200):**
```json
{
  "data": ["solar", "simao", "mws"]
}
```

#### GET /scraper_records/categories
Lista todas as categorias disponíveis.

**Headers:** `Authorization: Bearer <token>`

**Response (200):**
```json
{
  "data": ["Venda", "Locação"]
}
```

### 🏥 Health Check

#### GET /health/index
Verifica o status da aplicação.

**Response (200):**
```json
{
  "status": "ok",
  "timestamp": "2025-01-15T10:30:00.000Z",
  "version": "1.0.0"
}
```

## 📊 Códigos de Status HTTP

| Código | Descrição |
|--------|-----------|
| 200 | Sucesso |
| 201 | Criado com sucesso |
| 400 | Requisição inválida |
| 401 | Não autorizado |
| 404 | Não encontrado |
| 422 | Dados inválidos |
| 500 | Erro interno do servidor |

## 🔍 Filtros e Busca

### Filtros Disponíveis

#### Por Categoria
```bash
GET /scraper_records?category=Venda
GET /scraper_records?category=Locação
```

#### Por Site de Origem
```bash
GET /scraper_records?site=solar
GET /scraper_records?site=simao
GET /scraper_records?site=mws
```

#### Por Faixa de Preço
```bash
GET /scraper_records?min_price=200000&max_price=500000
```

#### Por Número de Dormitórios
```bash
GET /scraper_records?min_bedrooms=3
```

#### Por Localização
```bash
GET /scraper_records?q=Centro
GET /scraper_records?q=São Paulo
```

### Ordenação

#### Por Preço (Crescente)
```bash
GET /scraper_records?sort=price_asc
```

#### Por Preço (Decrescente)
```bash
GET /scraper_records?sort=price_desc
```

#### Por Data de Criação (Padrão)
```bash
GET /scraper_records
```

### Paginação

```bash
# Primeira página (padrão)
GET /scraper_records?page=1

# Segunda página
GET /scraper_records?page=2
```

## 🧪 Exemplos de Uso

### Exemplo 1: Buscar Apartamentos para Venda
```bash
curl -H "Authorization: Bearer <token>" \
     -H "Content-Type: application/json" \
     "http://localhost:3000/api/v1/scraper_records?category=Venda&min_bedrooms=2&max_price=400000"
```

### Exemplo 2: Buscar por Localização
```bash
curl -H "Authorization: Bearer <token>" \
     -H "Content-Type: application/json" \
     "http://localhost:3000/api/v1/scraper_records?q=Centro&category=Locação"
```

### Exemplo 3: Buscar com Múltiplos Filtros
```bash
curl -H "Authorization: Bearer <token>" \
     -H "Content-Type: application/json" \
     "http://localhost:3000/api/v1/scraper_records?category=Venda&site=solar&min_price=300000&max_price=600000&min_bedrooms=3&sort=price_asc"
```

## ⚠️ Limitações e Considerações

### Rate Limiting
- **Requests por minuto:** 100 (por usuário)
- **Requests por hora:** 1000 (por usuário)

### Paginação
- **Itens por página:** 20 (fixo)
- **Páginas máximas:** 100

### Filtros
- **Busca por localização:** Máximo 100 caracteres
- **Faixa de preço:** Valores devem ser positivos
- **Dormitórios:** Apenas números inteiros positivos

## 🐛 Tratamento de Erros

### Erro de Validação (422)
```json
{
  "error": {
    "code": "validation_failed",
    "message": "Dados inválidos",
    "details": {
      "email": ["já está em uso"],
      "password": ["muito curta"]
    }
  }
}
```

### Erro de Autenticação (401)
```json
{
  "error": {
    "code": "unauthorized",
    "message": "Token inválido ou expirado"
  }
}
```

### Erro de Servidor (500)
```json
{
  "error": {
    "code": "internal_error",
    "message": "Erro interno do servidor"
  }
}
```

## 📝 Changelog

### v1.0.0 (2025-01-15)
- ✅ Implementação inicial da API
- ✅ Autenticação JWT
- ✅ CRUD de imóveis
- ✅ Sistema de filtros e busca
- ✅ Paginação
- ✅ Documentação completa

---

**Para mais informações, consulte o [README.md](../README.md) do projeto.**
