# Backend - Sistema de Busca de Imóveis

API REST desenvolvida em Ruby on Rails que automatiza a coleta de dados de imóveis de múltiplas imobiliárias.

## 🚀 Tecnologias

- **Ruby 3.x** - Linguagem de programação
- **Ruby on Rails 8.0** - Framework web
- **PostgreSQL** - Banco de dados
- **Devise + JWT** - Autenticação
- **Nokogiri** - Web scraping
- **Sidekiq** - Background jobs

## 📋 Funcionalidades

- **API REST completa** - Endpoints para imóveis e autenticação
- **Web scraping automatizado** - 3 imobiliárias integradas
- **Autenticação JWT** - Sistema seguro de login
- **Sistema de filtros** - Busca avançada por múltiplos critérios
- **Paginação** - Navegação eficiente pelos resultados

## 🚀 Como Rodar

### Usando Docker (Recomendado)
```bash
# Iniciar o backend
docker-compose up backend

# Executar migrações
docker-compose exec backend rails db:migrate
```

### Desenvolvimento Local
```bash
# Instalar dependências
bundle install

# Configurar banco de dados
rails db:create db:migrate

# Iniciar servidor
rails server -p 3001
```

## 📚 Documentação

- **[API Documentation](docs/API.md)** - Documentação completa da API
- **[Architecture](docs/ARCHITECTURE.md)** - Arquitetura do sistema
- **[Installation Guide](docs/INSTALLATION.md)** - Guia detalhado de instalação
- **[Testing Guide](docs/TESTING.md)** - Guia de testes

## 🔧 Scripts Úteis

```bash
# Executar scraping manual
rails scrapers:run_all

# Executar testes
rails test

# Console Rails
rails console
```