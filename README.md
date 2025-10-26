# Sistema de Busca de Imóveis

Sistema web que automatiza a coleta de dados de imóveis de múltiplas imobiliárias, centralizando as informações em uma única plataforma para facilitar a busca e comparação de propriedades.

## 🚀 Tecnologias Utilizadas

### Backend
- **Ruby 3.x** - Linguagem de programação
- **Ruby on Rails 8.0** - Framework web
- **PostgreSQL** - Banco de dados
- **Devise + JWT** - Autenticação
- **Nokogiri** - Web scraping
- **Sidekiq** - Background jobs

### Frontend
- **Vue 3** - Framework JavaScript
- **Vue Router** - Roteamento
- **Pinia** - Gerenciamento de estado
- **Axios** - Cliente HTTP
- **CSS Customizado** - Sistema de design próprio

### DevOps
- **Docker** - Containerização
- **Docker Compose** - Orquestração

## 📋 Funcionalidades

- **API REST completa** - Endpoints para imóveis e autenticação
- **Web scraping automatizado** - 3 imobiliárias integradas (Solar, Simão, MWS)
- **Frontend Vue.js** - Interface moderna e responsiva
- **Autenticação JWT** - Sistema seguro de login
- **Sistema de filtros** - Busca avançada por múltiplos critérios
- **Paginação** - Navegação eficiente pelos resultados

## 🚀 Como Rodar

### Pré-requisitos
- **Docker & Docker Compose** (Recomendado)
- **Ruby 3.2+** e **Node.js 18+** (Desenvolvimento local)

### Usando Docker (Recomendado)
```bash
# Clone o repositório
git clone <seu-repositorio>
cd sistema-busca-imoveis

# Iniciar todos os serviços
docker-compose up --build

# Executar migrações
docker-compose exec backend rails db:migrate

# Acessar a aplicação
# Frontend: http://localhost:3000
# Backend API: http://localhost:3001
```

### Desenvolvimento Local
```bash
# Backend
cd backend
bundle install
rails db:create db:migrate
rails server -p 3001

# Frontend (em outro terminal)
cd frontend
npm install
npm run dev
```

## 📚 Documentação

- **[API Documentation](backend/docs/API.md)** - Documentação completa da API
- **[Architecture](backend/docs/ARCHITECTURE.md)** - Arquitetura do sistema
- **[Installation Guide](backend/docs/INSTALLATION.md)** - Guia detalhado de instalação
- **[Testing Guide](backend/docs/TESTING.md)** - Guia de testes

## 🔧 Scripts de Desenvolvimento

```bash
# Instalar dependências de ambos os projetos
npm run install:all

# Executar em modo desenvolvimento
npm run dev

# Executar testes
npm run test:backend
npm run test:all

# Build para produção
npm run build
```

## 🌐 URLs de Acesso

### Desenvolvimento
- **Frontend**: http://localhost:3001
- **Backend API**: http://localhost:3000

### Produção
- **Frontend**: https://seuapp.com
- **Backend API**: https://api.seuapp.com

## 📄 Licença

Este projeto está sob a licença MIT. Veja o arquivo [LICENSE](LICENSE) para mais detalhes.