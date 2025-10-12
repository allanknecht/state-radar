# 🚀 Guia de Instalação - Sistema de Busca de Imóveis

## 📋 Pré-requisitos

Antes de começar, certifique-se de ter os seguintes softwares instalados:

### Obrigatórios
- **Ruby 3.2+** - [Download](https://www.ruby-lang.org/en/downloads/)
- **PostgreSQL 14+** - [Download](https://www.postgresql.org/download/)
- **Git** - [Download](https://git-scm.com/downloads)
- **Bundler** - `gem install bundler`

### Opcionais (Recomendados)
- **Docker & Docker Compose** - [Download](https://www.docker.com/get-started)
- **Node.js 18+** - Para assets frontend
- **Redis** - Para background jobs (Sidekiq)

## 🖥️ Instalação Local

### 1. Clone o Repositório

```bash
git clone https://github.com/seu-usuario/teams-2023-t2-kiriku-e-pequeno.git
cd teams-2023-t2-kiriku-e-pequeno
```

### 2. Instale as Dependências Ruby

```bash
# Instalar gems do projeto
bundle install

# Verificar se todas as dependências foram instaladas
bundle check
```

### 3. Configure o Banco de Dados

#### 3.1. Crie o Usuário PostgreSQL (se necessário)

```bash
# Acesse o PostgreSQL como superuser
sudo -u postgres psql

# Crie um usuário para o projeto
CREATE USER rails_user WITH PASSWORD 'senha_segura';

# Crie o banco de dados
CREATE DATABASE teams_2023_t2_kiriku_e_pequeno_development OWNER rails_user;
CREATE DATABASE teams_2023_t2_kiriku_e_pequeno_test OWNER rails_user;

# Conceda privilégios
GRANT ALL PRIVILEGES ON DATABASE teams_2023_t2_kiriku_e_pequeno_development TO rails_user;
GRANT ALL PRIVILEGES ON DATABASE teams_2023_t2_kiriku_e_pequeno_test TO rails_user;

# Sair do PostgreSQL
\q
```

#### 3.2. Configure o arquivo database.yml

```yaml
# config/database.yml
default: &default
  adapter: postgresql
  encoding: unicode
  pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>
  username: <%= ENV.fetch("DATABASE_USERNAME") { "rails_user" } %>
  password: <%= ENV.fetch("DATABASE_PASSWORD") { "senha_segura" } %>

development:
  <<: *default
  database: teams_2023_t2_kiriku_e_pequeno_development
  host: localhost
  port: 5432

test:
  <<: *default
  database: teams_2023_t2_kiriku_e_pequeno_test
  host: localhost
  port: 5432

production:
  <<: *default
  database: teams_2023_t2_kiriku_e_pequeno_production
  host: <%= ENV["DATABASE_HOST"] %>
  port: <%= ENV["DATABASE_PORT"] || 5432 %>
  username: <%= ENV["DATABASE_USERNAME"] %>
  password: <%= ENV["DATABASE_PASSWORD"] %>
  url: <%= ENV["DATABASE_URL"] %>
```

#### 3.3. Execute as Migrações

```bash
# Criar o banco de dados
rails db:create

# Executar migrações
rails db:migrate

# (Opcional) Carregar dados de exemplo
rails db:seed
```

### 4. Configure as Variáveis de Ambiente

#### 4.1. Crie o arquivo .env

```bash
# Copie o arquivo de exemplo
cp .env.example .env
```

#### 4.2. Configure as variáveis necessárias

```bash
# .env
# Banco de dados
DATABASE_USERNAME=rails_user
DATABASE_PASSWORD=senha_segura
DATABASE_HOST=localhost
DATABASE_PORT=5432

# JWT Secret (gere uma chave segura)
DEVISE_JWT_SECRET_KEY=sua_chave_secreta_jwt_aqui

# Rails Master Key (para credentials)
RAILS_MASTER_KEY=sua_master_key_aqui

# Configurações de Scraping
SCRAPER_PAUSE=0.5
SCRAPER_MAX_RETRIES=3
SCRAPER_TIMEOUT=30

# Redis (para background jobs)
REDIS_URL=redis://localhost:6379/0

# Ambiente
RAILS_ENV=development
```

#### 4.3. Gere chaves seguras

```bash
# Gerar secret para JWT
rails secret

# Gerar master key para credentials
rails credentials:show
```

### 5. Configure as Credentials do Rails

```bash
# Editar credentials (usar editor padrão)
EDITOR="nano" rails credentials:edit

# Ou com VS Code
EDITOR="code --wait" rails credentials:edit
```

Adicione as seguintes configurações:

```yaml
# config/credentials.yml.enc
devise:
  jwt_secret_key: sua_chave_jwt_aqui
  
database:
  username: rails_user
  password: senha_segura
  
scraping:
  pause: 0.5
  max_retries: 3
  timeout: 30
```

### 6. Teste a Instalação

```bash
# Verificar se tudo está funcionando
rails server

# Em outro terminal, testar a API
curl http://localhost:3000/api/health/index
```

## 🐳 Instalação com Docker

### 1. Clone e Configure

```bash
git clone https://github.com/seu-usuario/teams-2023-t2-kiriku-e-pequeno.git
cd teams-2023-t2-kiriku-e-pequeno
```

### 2. Configure as Variáveis de Ambiente

```bash
# Copie e edite o arquivo de exemplo
cp .env.example .env.docker
```

```bash
# .env.docker
DATABASE_USERNAME=postgres
DATABASE_PASSWORD=password
DATABASE_HOST=db
DATABASE_PORT=5432

DEVISE_JWT_SECRET_KEY=sua_chave_secreta_jwt_aqui
RAILS_MASTER_KEY=sua_master_key_aqui

RAILS_ENV=development
```

### 3. Construa e Execute os Containers

```bash
# Construir e iniciar todos os serviços
docker-compose up --build

# Em background
docker-compose up -d --build
```

### 4. Execute as Migrações

```bash
# Executar migrações no container
docker-compose exec web rails db:create
docker-compose exec web rails db:migrate
docker-compose exec web rails db:seed
```

### 5. Verifique se Está Funcionando

```bash
# Verificar logs
docker-compose logs web

# Testar API
curl http://localhost:3000/api/health/index
```

## 🧪 Configuração para Testes

### 1. Banco de Dados de Teste

```bash
# Criar banco de teste
rails db:test:prepare

# Executar migrações no banco de teste
RAILS_ENV=test rails db:migrate
```

### 2. Executar Testes

```bash
# Todos os testes
rails test

# Testes específicos
rails test test/models/scraper_record_test.rb
rails test test/services/solar_scraper_service_test.rb

# Com coverage
COVERAGE=true rails test
```

## 🔧 Configurações Avançadas

### 1. Redis para Background Jobs

#### Instalação Local
```bash
# Ubuntu/Debian
sudo apt-get install redis-server

# macOS
brew install redis

# Iniciar Redis
redis-server
```

#### Configuração no Rails
```ruby
# config/application.rb
config.active_job.queue_adapter = :sidekiq
```

### 2. Sidekiq para Jobs

```bash
# Adicionar ao Gemfile
gem 'sidekiq'

# Instalar
bundle install

# Iniciar Sidekiq
bundle exec sidekiq
```

### 3. Configuração de Logs

```ruby
# config/environments/development.rb
config.log_level = :debug
config.log_formatter = ::Logger::Formatter.new

# config/environments/production.rb
config.log_level = :info
config.log_formatter = proc do |severity, datetime, progname, msg|
  "#{datetime.strftime('%Y-%m-%d %H:%M:%S')} [#{severity}] #{msg}\n"
end
```

## 🚀 Deploy em Produção

### 1. Heroku

```bash
# Instalar Heroku CLI
# https://devcenter.heroku.com/articles/heroku-cli

# Login
heroku login

# Criar app
heroku create seu-app-name

# Configurar variáveis de ambiente
heroku config:set RAILS_MASTER_KEY=sua_master_key
heroku config:set DEVISE_JWT_SECRET_KEY=sua_jwt_secret
heroku config:set DATABASE_URL=sua_database_url

# Adicionar addon do PostgreSQL
heroku addons:create heroku-postgresql:mini

# Deploy
git push heroku main

# Executar migrações
heroku run rails db:migrate
```

### 2. Render

1. Conecte seu repositório GitHub
2. Configure as variáveis de ambiente:
   - `RAILS_MASTER_KEY`
   - `DEVISE_JWT_SECRET_KEY`
   - `DATABASE_URL`
3. Deploy automático será executado

### 3. VPS/Cloud Provider

```bash
# Instalar dependências do sistema
sudo apt-get update
sudo apt-get install -y postgresql postgresql-contrib redis-server

# Configurar PostgreSQL
sudo -u postgres createuser -s rails_user
sudo -u postgres createdb teams_2023_t2_kiriku_e_pequeno_production

# Deploy com Capistrano ou similar
cap production deploy
```

## 🔍 Verificação da Instalação

### 1. Checklist de Verificação

```bash
# ✅ Ruby versão correta
ruby --version  # Deve ser 3.2+

# ✅ Bundler instalado
bundle --version

# ✅ PostgreSQL rodando
pg_isready

# ✅ Banco de dados criado
rails db:version

# ✅ Servidor iniciando
rails server  # Deve iniciar sem erros

# ✅ API respondendo
curl http://localhost:3000/api/health/index

# ✅ Testes passando
rails test
```

### 2. Teste de Funcionalidades

```bash
# Testar scraping manual
rails console
PropertyScraperJob.perform_now(:solar)

# Testar autenticação
curl -X POST http://localhost:3000/api/v1/users/sign_up \
  -H "Content-Type: application/json" \
  -d '{"user":{"email":"test@test.com","password":"123456","password_confirmation":"123456"}}'

# Testar busca de imóveis
curl -H "Authorization: Bearer <token>" \
  http://localhost:3000/api/v1/scraper_records
```

## 🐛 Solução de Problemas

### Problemas Comuns

#### 1. Erro de Conexão com PostgreSQL
```bash
# Verificar se PostgreSQL está rodando
sudo systemctl status postgresql

# Reiniciar PostgreSQL
sudo systemctl restart postgresql

# Verificar configuração
cat /etc/postgresql/*/main/postgresql.conf | grep listen_addresses
```

#### 2. Erro de Permissões no Banco
```bash
# Conceder privilégios
sudo -u postgres psql
GRANT ALL PRIVILEGES ON DATABASE nome_do_banco TO usuario;
\q
```

#### 3. Erro de Gem não Encontrada
```bash
# Limpar cache do Bundler
bundle clean --force

# Reinstalar gems
bundle install --redownload
```

#### 4. Erro de Credentials
```bash
# Regenerar credentials
rm config/credentials.yml.enc
EDITOR="nano" rails credentials:edit
```

#### 5. Erro de Migrações
```bash
# Reset do banco (CUIDADO: apaga dados)
rails db:drop db:create db:migrate db:seed
```

### Logs Úteis

```bash
# Logs do Rails
tail -f log/development.log

# Logs do PostgreSQL
sudo tail -f /var/log/postgresql/postgresql-*.log

# Logs do Redis
sudo tail -f /var/log/redis/redis-server.log

# Logs do Docker
docker-compose logs -f web
```

## 📞 Suporte

Se encontrar problemas durante a instalação:

1. **Verifique os logs** - Sempre comece pelos logs de erro
2. **Consulte a documentação** - README.md e API.md
3. **Procure por issues similares** - GitHub Issues
4. **Entre em contato** - allan.knecht@email.com

---

**Instalação concluída com sucesso! 🎉**
