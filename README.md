# 🏠 Sistema de Busca de Imóveis - Monorepo

Um sistema completo de busca de imóveis com **backend Rails API** e **frontend Vue.js**, unificados em um monorepo para facilitar desenvolvimento e deploy.

## 🏗️ Arquitetura do Projeto

```
📂 sistema-busca-imoveis/
├── 📂 backend/              # Rails API (Ruby)
│   ├── app/                 # Controllers, Models, Services
│   ├── config/              # Configurações Rails
│   ├── db/                  # Migrations e Schema
│   ├── Gemfile              # Dependências Ruby
│   └── README.md            # Documentação do Backend
├── 📂 frontend/             # Vue.js SPA
│   ├── src/                 # Componentes Vue
│   ├── public/              # Assets estáticos
│   ├── package.json         # Dependências Node.js
│   └── README.md            # Documentação do Frontend
├── 📂 docs/                 # Documentação unificada
│   ├── API.md               # Documentação da API
│   ├── ARCHITECTURE.md      # Arquitetura do sistema
│   ├── INSTALLATION.md      # Guia de instalação
│   └── TESTING.md           # Guia de testes
├── 📄 docker-compose.yml    # Orquestração de containers
├── 📄 package.json          # Scripts de desenvolvimento
└── 📄 README.md             # Este arquivo
```

## 🚀 Tecnologias Utilizadas

### Backend (Rails API)
- **Ruby 3.x** - Linguagem de programação
- **Ruby on Rails 8.0** - Framework web
- **PostgreSQL** - Banco de dados
- **Devise + JWT** - Autenticação
- **Nokogiri** - Web scraping
- **Sidekiq** - Background jobs

### Frontend (Vue.js)
- **Vue 3** - Framework JavaScript
- **Vue Router** - Roteamento
- **Pinia** - Gerenciamento de estado
- **Axios** - Cliente HTTP
- **Bootstrap 5** - Framework CSS

### DevOps
- **Docker** - Containerização
- **Docker Compose** - Orquestração
- **Git** - Controle de versão

## 📋 Funcionalidades

### ✅ Implementadas
- [x] **API REST completa** - Endpoints para imóveis e autenticação
- [x] **Web scraping automatizado** - 3 imobiliárias integradas
- [x] **Frontend Vue.js** - Interface moderna e responsiva
- [x] **Autenticação JWT** - Sistema seguro de login
- [x] **Sistema de filtros** - Busca avançada por múltiplos critérios
- [x] **Paginação** - Navegação eficiente pelos resultados

### 🔄 Em Desenvolvimento
- [ ] Dashboard administrativo
- [ ] Sistema de favoritos
- [ ] Notificações por email
- [ ] PWA (Progressive Web App)

## 🚀 Instalação Rápida

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
# Frontend: http://localhost:3001
# Backend API: http://localhost:3000
```

### Desenvolvimento Local
```bash
# Backend (Docker - Recomendado)
docker-compose up backend -d

# Frontend (Local)
cd frontend
npm install
npm run dev

# Ou usar script do monorepo
npm run dev:frontend
```

## 📚 Documentação

- **[API Documentation](docs/API.md)** - Documentação completa da API
- **[Architecture](docs/ARCHITECTURE.md)** - Arquitetura do sistema
- **[Installation Guide](docs/INSTALLATION.md)** - Guia detalhado de instalação
- **[Testing Guide](docs/TESTING.md)** - Guia de testes

## 🔧 Scripts de Desenvolvimento

```bash
# Instalar dependências de ambos os projetos
npm run install:all

# Executar em modo desenvolvimento
npm run dev

# Executar testes
npm run test:backend
npm run test:frontend
npm run test:all

# Build para produção
npm run build

# Deploy
npm run deploy
```

## 🏗️ Estrutura Detalhada

### Backend (`/backend`)
- **API REST** com autenticação JWT
- **Web scraping** de 3 imobiliárias
- **Background jobs** para processamento
- **PostgreSQL** para persistência
- **CORS** configurado para frontend

### Frontend (`/frontend`)
- **SPA Vue.js** com roteamento
- **Autenticação** integrada com backend
- **Interface responsiva** com Bootstrap
- **Gerenciamento de estado** com Pinia
- **Componentes reutilizáveis**

## 🌐 URLs de Acesso

### Desenvolvimento
- **Frontend**: http://localhost:3000
- **Backend API**: http://localhost:3001
- **Admin Panel**: http://localhost:3000/admin

### Produção
- **Frontend**: https://seuapp.com
- **Backend API**: https://api.seuapp.com

## 🔄 Fluxo de Desenvolvimento

1. **Backend First** - Desenvolver endpoints na API
2. **Frontend Integration** - Integrar com componentes Vue
3. **Testing** - Testes unitários e de integração
4. **Deploy** - Deploy coordenado de ambos

## 📊 Métricas do Projeto

### Código
- **Backend**: ~3,500 linhas (Ruby/Rails)
- **Frontend**: ~2,000 linhas (Vue.js/JavaScript)
- **Total**: ~5,500 linhas de código

### Funcionalidades
- **API Endpoints**: 8
- **Vue Components**: ~15
- **Scrapers**: 3
- **Background Jobs**: 1

## 🚀 Deploy

### Desenvolvimento
```bash
# Usar Docker Compose para desenvolvimento local
docker-compose up --build
```

### Produção
```bash
# Deploy separado (recomendado)
# Backend: Heroku/Render
# Frontend: Vercel/Netlify

# Ou deploy unificado com Docker
docker-compose -f docker-compose.prod.yml up -d
```

## 🤝 Contribuição

1. Fork o projeto
2. Crie uma branch (`git checkout -b feature/nova-feature`)
3. Commit suas mudanças (`git commit -am 'Adiciona nova feature'`)
4. Push para a branch (`git push origin feature/nova-feature`)
5. Abra um Pull Request

## 📞 Suporte

- **Desenvolvedor**: Allan Knecht
- **Email**: allan.knecht@email.com
- **GitHub Issues**: [Criar uma issue](https://github.com/seu-usuario/sistema-busca-imoveis/issues)

## 📄 Licença

Este projeto está sob a licença MIT. Veja o arquivo [LICENSE](LICENSE) para mais detalhes.

---

**Desenvolvido com ❤️ para o projeto acadêmico de Engenharia de Software**
