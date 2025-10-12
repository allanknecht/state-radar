# 🏠 Sistema de Busca de Imóveis - MVP

Um sistema web que automatiza a coleta de dados de imóveis de múltiplas imobiliárias, centralizando as informações em uma única plataforma para facilitar a busca e comparação de propriedades.

## 👥 Integrantes da Equipe
- **Allan Knecht** - Desenvolvimento Full-Stack

## 🎯 Objetivo do Projeto

Desenvolver uma aplicação web que resolva o problema da fragmentação de informações imobiliárias, permitindo que usuários encontrem propriedades de múltiplas fontes em um único local, com funcionalidades de busca, filtros e comparação.

## 🚀 Tecnologias Utilizadas

### Backend
- **Ruby 3.x** - Linguagem de programação
- **Ruby on Rails 8.0** - Framework web
- **PostgreSQL** - Banco de dados
- **Devise + JWT** - Autenticação e autorização
- **Nokogiri** - Web scraping
- **Faraday** - Cliente HTTP
- **Sidekiq** - Processamento em background

### Frontend
- **HTML5 + CSS3** - Estrutura e estilização
- **Bootstrap 5** - Framework CSS responsivo
- **JavaScript ES6+** - Interatividade

### DevOps
- **Docker** - Containerização
- **Kamal** - Deploy automatizado
- **Git** - Controle de versão

## 📋 Funcionalidades Implementadas

### ✅ Funcionalidades Principais
- [x] **Autenticação de usuários** - Login, cadastro e gerenciamento de sessão
- [x] **Web scraping automatizado** - Coleta de dados de 3 imobiliárias diferentes
- [x] **API REST completa** - Endpoints para consulta e filtros
- [x] **Sistema de busca avançada** - Filtros por preço, localização, características
- [x] **Banco de dados centralizado** - Armazenamento estruturado dos dados
- [x] **Processamento em background** - Jobs para scraping automático

### 🔄 Funcionalidades em Desenvolvimento
- [ ] Interface web responsiva
- [ ] Sistema de favoritos
- [ ] Notificações por email
- [ ] Dashboard administrativo

## 🏗️ Arquitetura do Sistema

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   Frontend      │    │   Rails API      │    │   PostgreSQL    │
│   (Interface)   │◄──►│   (Backend)      │◄──►│   (Database)    │
└─────────────────┘    └──────────────────┘    └─────────────────┘
                              │
                              ▼
                       ┌──────────────────┐
                       │  Web Scrapers    │
                       │  (Background)    │
                       └──────────────────┘
                              │
                              ▼
                       ┌──────────────────┐
                       │   Imobiliárias   │
                       │  (Solar, Simão,  │
                       │      MWS)        │
                       └──────────────────┘
```

## 🚀 Instalação e Configuração

### Pré-requisitos
- Ruby 3.2+
- PostgreSQL 14+
- Docker (opcional)
- Git

### 1. Clone o repositório
```bash
git clone https://github.com/seu-usuario/teams-2023-t2-kiriku-e-pequeno.git
cd teams-2023-t2-kiriku-e-pequeno
```

### 2. Instale as dependências
```bash
bundle install
```

### 3. Configure o banco de dados
```bash
# Crie o banco de dados
rails db:create

# Execute as migrações
rails db:migrate

# (Opcional) Carregue dados de exemplo
rails db:seed
```

### 4. Configure as variáveis de ambiente
```bash
# Copie o arquivo de exemplo
cp .env.example .env

# Edite as configurações necessárias
nano .env
```

### 5. Inicie o servidor
```bash
rails server
```

O sistema estará disponível em `http://localhost:3000`

### 🐳 Usando Docker (Recomendado)
```bash
# Construa e inicie os containers
docker-compose up --build

# Execute as migrações
docker-compose exec web rails db:migrate
```

## 📚 Documentação da API

### Autenticação
O sistema utiliza JWT (JSON Web Token) para autenticação. Todas as requisições protegidas devem incluir o header:
```
Authorization: Bearer <seu_token_jwt>
```

### Endpoints Principais

#### 🔐 Autenticação
```http
POST /api/v1/users/sign_in
POST /api/v1/users/sign_up
PATCH /api/v1/users/password/change
DELETE /api/v1/users/sign_out
```

#### 🏠 Imóveis
```http
GET /api/v1/scraper_records           # Lista imóveis com filtros
GET /api/v1/scraper_records/:id       # Detalhes de um imóvel
GET /api/v1/scraper_records/sites     # Lista sites disponíveis
GET /api/v1/scraper_records/categories # Lista categorias (Venda/Locação)
```

#### Exemplo de Requisição
```bash
curl -H "Authorization: Bearer <token>" \
     -H "Content-Type: application/json" \
     "http://localhost:3000/api/v1/scraper_records?category=Venda&min_price=100000&max_price=500000"
```

### Parâmetros de Filtro
- `category` - Categoria (Venda/Locação)
- `site` - Site de origem (solar/simao/mws)
- `min_price` - Preço mínimo
- `max_price` - Preço máximo
- `min_bedrooms` - Número mínimo de dormitórios
- `q` - Busca por localização
- `sort` - Ordenação (price_asc, price_desc)
- `page` - Página para paginação

## 🔄 Executando o Scraping

### Manual (via Rails Console)
```ruby
# Executar scraping de todos os sites
PropertyScraperJob.perform_now

# Executar scraping de um site específico
PropertyScraperJob.perform_now(:solar)
```

### Via Rake Task
```bash
# Executar todos os scrapers
rails scrapers:run_all

# Executar scraper específico
rails scrapers:run solar
```

### Agendamento Automático
O sistema suporta agendamento via cron ou sistemas como Sidekiq-Cron para execução automática.

## 🧪 Testes

```bash
# Executar todos os testes
rails test

# Executar testes específicos
rails test test/models/scraper_record_test.rb
rails test test/services/solar_scraper_service_test.rb
```

## 📊 Estrutura do Banco de Dados

### Tabela `scraper_records`
Armazena os dados dos imóveis coletados:

| Campo | Tipo | Descrição |
|-------|------|-----------|
| `site` | string | Site de origem (solar/simao/mws) |
| `categoria` | string | Venda ou Locação |
| `codigo` | string | Código único do imóvel |
| `titulo` | string | Título do anúncio |
| `localizacao` | string | Endereço/localização |
| `preco_brl` | decimal | Preço em reais |
| `dormitorios` | integer | Número de dormitórios |
| `area_m2` | decimal | Área em metros quadrados |
| `link` | string | URL original do anúncio |
| `imagem` | string | URL da imagem principal |
| `amenities` | jsonb | Array de comodidades |

## 🚀 Deploy

### Heroku
```bash
# Configure o Heroku CLI
heroku create seu-app-name

# Configure as variáveis de ambiente
heroku config:set RAILS_MASTER_KEY=seu_master_key
heroku config:set DATABASE_URL=sua_database_url

# Deploy
git push heroku main
heroku run rails db:migrate
```

### Render
1. Conecte seu repositório GitHub no Render
2. Configure as variáveis de ambiente
3. Deploy automático será executado

## 🔧 Configurações Avançadas

### Variáveis de Ambiente
```bash
# Banco de dados
DATABASE_URL=postgresql://user:pass@localhost/dbname

# JWT
DEVISE_JWT_SECRET_KEY=seu_secret_key

# Scraping
SCRAPER_PAUSE=0.5
SCRAPER_MAX_RETRIES=3
```

### Logs
```bash
# Visualizar logs em desenvolvimento
tail -f log/development.log

# Logs de scraping
grep "ScraperJob" log/development.log
```

## 🤝 Contribuição

1. Fork o projeto
2. Crie uma branch para sua feature (`git checkout -b feature/nova-feature`)
3. Commit suas mudanças (`git commit -am 'Adiciona nova feature'`)
4. Push para a branch (`git push origin feature/nova-feature`)
5. Abra um Pull Request

## 📄 Licença

Este projeto está sob a licença MIT. Veja o arquivo [LICENSE](LICENSE) para mais detalhes.

## 📞 Suporte

Para dúvidas ou suporte, entre em contato:
- **Email:** allan.knecht@email.com
- **GitHub Issues:** [Criar uma issue](https://github.com/seu-usuario/teams-2023-t2-kiriku-e-pequeno/issues)

## 🎯 Roadmap Futuro

### Versão 2.0
- [ ] Interface web completa e responsiva
- [ ] Sistema de notificações por email
- [ ] Dashboard com estatísticas
- [ ] API GraphQL
- [ ] Cache Redis para performance

### Versão 3.0
- [ ] Machine Learning para preços
- [ ] Integração com mapas
- [ ] Sistema de avaliações
- [ ] Chat em tempo real

---

**Desenvolvido com ❤️ para o projeto acadêmico de Engenharia de Software**
