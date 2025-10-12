# 🧪 Guia de Testes - Sistema de Busca de Imóveis

## Visão Geral

O sistema utiliza o framework de testes padrão do Rails (Minitest) para garantir a qualidade e confiabilidade do código. Os testes cobrem models, controllers, services, jobs e integração.

## 📁 Estrutura de Testes

```
test/
├── controllers/           # Testes de controllers
├── fixtures/             # Dados de teste
├── jobs/                 # Testes de background jobs
├── models/               # Testes de models
├── services/             # Testes de services
├── integration/          # Testes de integração
└── support/              # Helpers e configurações de teste
```

## 🚀 Executando Testes

### Comandos Básicos

```bash
# Executar todos os testes
rails test

# Executar testes específicos
rails test test/models/scraper_record_test.rb
rails test test/services/solar_scraper_service_test.rb

# Executar testes com detalhes
rails test --verbose

# Executar testes em paralelo (mais rápido)
rails test --parallel

# Executar apenas testes que falharam
rails test --fail-fast
```

### Executando Testes Específicos

```bash
# Por arquivo
rails test test/models/user_test.rb

# Por método específico
rails test test/models/scraper_record_test.rb::test_should_validate_site_presence

# Por padrão (regex)
rails test -n /scraper/
```

## 📊 Cobertura de Testes

### Configuração de Coverage

```bash
# Instalar gem de coverage
gem 'simplecov', group: :test

# Executar com coverage
COVERAGE=true rails test
```

### Relatório de Coverage

Após executar os testes com coverage, o relatório estará disponível em:
```
coverage/index.html
```

## 🧩 Tipos de Testes

### 1. **Testes de Models**

#### Exemplo: ScraperRecord
```ruby
# test/models/scraper_record_test.rb
require "test_helper"

class ScraperRecordTest < ActiveSupport::TestCase
  def setup
    @record = ScraperRecord.new(
      site: "solar",
      categoria: "Venda",
      codigo: "SOL123",
      titulo: "Apartamento teste"
    )
  end

  test "should be valid with valid attributes" do
    assert @record.valid?
  end

  test "should require site" do
    @record.site = nil
    assert_not @record.valid?
    assert_includes @record.errors[:site], "can't be blank"
  end

  test "should require valid site" do
    @record.site = "invalid_site"
    assert_not @record.valid?
    assert_includes @record.errors[:site], "is not included in the list"
  end

  test "should require unique code per site and category" do
    @record.save!
    
    duplicate_record = ScraperRecord.new(
      site: "solar",
      categoria: "Venda",
      codigo: "SOL123"
    )
    
    assert_not duplicate_record.valid?
    assert_includes duplicate_record.errors[:codigo], "has already been taken"
  end

  test "should normalize category" do
    @record.categoria = "venda"
    assert_equal "Venda", @record.categoria
    
    @record.categoria = "locação"
    assert_equal "Locação", @record.categoria
  end
end
```

### 2. **Testes de Controllers**

#### Exemplo: ScraperRecordsController
```ruby
# test/controllers/scraper_records_controller_test.rb
require "test_helper"

class ScraperRecordsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:one)
    @token = generate_jwt_token(@user)
    @headers = { 'Authorization' => "Bearer #{@token}" }
  end

  test "should get index with authentication" do
    get api_v1_scraper_records_path, headers: @headers
    assert_response :success
    
    json_response = JSON.parse(response.body)
    assert json_response.key?('data')
    assert json_response.key?('meta')
  end

  test "should not get index without authentication" do
    get api_v1_scraper_records_path
    assert_response :unauthorized
  end

  test "should filter by category" do
    get api_v1_scraper_records_path, 
        params: { category: "Venda" }, 
        headers: @headers
    
    assert_response :success
    
    json_response = JSON.parse(response.body)
    json_response['data'].each do |record|
      assert_equal "Venda", record['categoria']
    end
  end

  test "should filter by price range" do
    get api_v1_scraper_records_path, 
        params: { min_price: 100000, max_price: 500000 }, 
        headers: @headers
    
    assert_response :success
    
    json_response = JSON.parse(response.body)
    json_response['data'].each do |record|
      price = record['preco_brl']
      assert price >= 100000
      assert price <= 500000
    end
  end

  test "should return pagination metadata" do
    get api_v1_scraper_records_path, headers: @headers
    
    assert_response :success
    
    json_response = JSON.parse(response.body)
    meta = json_response['meta']
    
    assert meta.key?('page')
    assert meta.key?('total_pages')
    assert meta.key?('total_count')
    assert meta.key?('per')
  end
end
```

### 3. **Testes de Services**

#### Exemplo: SolarScraperService
```ruby
# test/services/solar_scraper_service_test.rb
require "test_helper"

class SolarScraperServiceTest < ActiveSupport::TestCase
  def setup
    @scraper = SolarScraperService.new
  end

  test "should initialize with correct base URL" do
    assert_equal "https://solarimoveis.com.br", @scraper.instance_variable_get(:@base_url)
  end

  test "should have correct site name" do
    assert_equal "Solar", @scraper.send(:site_name)
  end

  test "should build correct page URL" do
    path = "/venda"
    page = 2
    expected_url = "/venda?pagina=2"
    
    assert_equal expected_url, @scraper.send(:build_page_url, path, page)
  end

  test "should parse price correctly" do
    assert_equal 350000.0, @scraper.send(:parse_brl, "R$ 350.000,00")
    assert_equal 1250.50, @scraper.send(:parse_brl, "R$ 1.250,50")
    assert_nil @scraper.send(:parse_brl, "Preço sob consulta")
  end

  test "should normalize vagas range" do
    assert_equal [1, 1], @scraper.send(:normalize_vagas_range, "1")
    assert_equal [1, 2], @scraper.send(:normalize_vagas_range, "1 a 2")
    assert_equal [2, 3], @scraper.send(:normalize_vagas_range, "2 ou 3")
    assert_equal [nil, nil], @scraper.send(:normalize_vagas_range, "Indisponível")
  end

  test "should handle network errors gracefully" do
    # Mock Faraday para simular erro de rede
    stub_request(:get, /solarimoveis.com.br/)
      .to_return(status: 500, body: "Server Error")
    
    doc = @scraper.send(:get_doc, "/venda")
    assert_instance_of Nokogiri::HTML::Document, doc
  end
end
```

### 4. **Testes de Jobs**

#### Exemplo: PropertyScraperJob
```ruby
# test/jobs/property_scraper_job_test.rb
require "test_helper"

class PropertyScraperJobTest < ActiveJob::TestCase
  def setup
    @job = PropertyScraperJob.new
  end

  test "should perform scraping for all sites" do
    # Mock dos scrapers para evitar requisições reais
    SolarScraperService.any_instance.stubs(:scrape_category).returns([])
    SimaoScraperService.any_instance.stubs(:scrape_category).returns([])
    MwsScraperService.any_instance.stubs(:scrape_category).returns([])

    assert_no_difference 'ScraperRecord.count' do
      PropertyScraperJob.perform_now
    end
  end

  test "should perform scraping for specific site" do
    SolarScraperService.any_instance.stubs(:scrape_category).returns([])
    
    assert_no_difference 'ScraperRecord.count' do
      PropertyScraperJob.perform_now(:solar)
    end
  end

  test "should upsert records correctly" do
    record_data = {
      site: "solar",
      categoria: "Venda",
      codigo: "TEST123",
      titulo: "Apartamento teste",
      link: "https://test.com",
      preco_brl: 300000.0
    }

    assert_difference 'ScraperRecord.count', 1 do
      @job.send(:upsert_record!, record_data, :solar)
    end

    record = ScraperRecord.last
    assert_equal "solar", record.site
    assert_equal "Venda", record.categoria
    assert_equal "TEST123", record.codigo
    assert_equal 300000.0, record.preco_brl
  end

  test "should handle validation errors gracefully" do
    invalid_record = {
      site: nil,  # Inválido
      categoria: "Venda",
      codigo: "TEST123"
    }

    assert_no_difference 'ScraperRecord.count' do
      @job.send(:upsert_record!, invalid_record, :solar)
    end
  end
end
```

## 🔧 Fixtures e Factories

### 1. **Fixtures**

```yaml
# test/fixtures/scraper_records.yml
solar_venda_1:
  site: solar
  categoria: Venda
  codigo: SOL001
  titulo: Apartamento 2 dormitórios
  localizacao: Centro, São Paulo - SP
  link: https://solar.com/imovel/001
  imagem: https://solar.com/images/001.jpg
  preco_brl: 350000.0
  dormitorios: 2
  suites: 1
  vagas: 1
  area_m2: 75.5
  condominio: 850.0
  iptu: 450.0
  banheiros: 2
  amenities: ["Piscina", "Academia"]
  created_at: <%= 1.day.ago %>
  updated_at: <%= 1.day.ago %>

solar_locacao_1:
  site: solar
  categoria: Locação
  codigo: SOL002
  titulo: Casa 3 dormitórios
  localizacao: Vila Madalena, São Paulo - SP
  link: https://solar.com/imovel/002
  imagem: https://solar.com/images/002.jpg
  preco_brl: 2500.0
  dormitorios: 3
  suites: 2
  vagas: 2
  area_m2: 120.0
  banheiros: 3
  amenities: ["Jardim", "Churrasqueira"]
  created_at: <%= 2.days.ago %>
  updated_at: <%= 2.days.ago %>

simao_venda_1:
  site: simao
  categoria: Venda
  codigo: SIM001
  titulo: Cobertura 4 dormitórios
  localizacao: Jardins, São Paulo - SP
  link: https://simao.com/imovel/001
  imagem: https://simao.com/images/001.jpg
  preco_brl: 850000.0
  dormitorios: 4
  suites: 3
  vagas: 3
  area_m2: 180.0
  condominio: 1200.0
  iptu: 1200.0
  banheiros: 4
  amenities: ["Piscina", "Academia", "Sauna"]
  created_at: <%= 3.days.ago %>
  updated_at: <%= 3.days.ago %>
```

```yaml
# test/fixtures/users.yml
test_user:
  email: test@example.com
  encrypted_password: <%= Devise::Encryptor.digest(User, 'password123') %>
  created_at: <%= 1.week.ago %>
  updated_at: <%= 1.week.ago %>

admin_user:
  email: admin@example.com
  encrypted_password: <%= Devise::Encryptor.digest(User, 'admin123') %>
  created_at: <%= 2.weeks.ago %>
  updated_at: <%= 2.weeks.ago %>
```

### 2. **Test Helpers**

```ruby
# test/support/test_helpers.rb
module TestHelpers
  def generate_jwt_token(user)
    Warden::JWTAuth::UserEncoder.new.call(user, :user, nil).first
  end

  def authenticate_user(user)
    token = generate_jwt_token(user)
    { 'Authorization' => "Bearer #{token}" }
  end

  def json_response
    JSON.parse(response.body)
  end

  def create_scraper_record(attributes = {})
    ScraperRecord.create!({
      site: "solar",
      categoria: "Venda",
      codigo: "TEST#{rand(1000)}",
      titulo: "Test Property",
      link: "https://test.com",
      preco_brl: 300000.0
    }.merge(attributes))
  end

  def mock_scraper_response(site, category)
    stub_request(:get, /#{site}/)
      .to_return(
        status: 200,
        body: File.read(Rails.root.join("test", "fixtures", "#{site}_#{category}.html")),
        headers: { 'Content-Type' => 'text/html' }
      )
  end
end

ActiveSupport::TestCase.include TestHelpers
ActionDispatch::IntegrationTest.include TestHelpers
```

## 🎯 Testes de Integração

### Exemplo: Fluxo Completo de API

```ruby
# test/integration/api_integration_test.rb
require "test_helper"

class ApiIntegrationTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:test_user)
    @token = generate_jwt_token(@user)
    @headers = { 'Authorization' => "Bearer #{@token}" }
  end

  test "complete API flow" do
    # 1. Verificar health check
    get api_health_path
    assert_response :success
    
    health_data = json_response
    assert_equal "ok", health_data['status']

    # 2. Listar sites disponíveis
    get api_v1_scraper_records_sites_path, headers: @headers
    assert_response :success
    
    sites = json_response['data']
    assert_includes sites, "solar"
    assert_includes sites, "simao"
    assert_includes sites, "mws"

    # 3. Listar categorias
    get api_v1_scraper_records_categories_path, headers: @headers
    assert_response :success
    
    categories = json_response['data']
    assert_includes categories, "Venda"
    assert_includes categories, "Locação"

    # 4. Buscar imóveis com filtros
    get api_v1_scraper_records_path, 
        params: { category: "Venda", min_price: 300000 }, 
        headers: @headers
    assert_response :success
    
    properties = json_response['data']
    assert properties.is_a?(Array)
    
    if properties.any?
      property = properties.first
      assert property.key?('id')
      assert property.key?('titulo')
      assert property.key?('preco_brl')
      assert_equal "Venda", property['categoria']
      assert property['preco_brl'] >= 300000
    end

    # 5. Ver detalhes de um imóvel específico
    if properties.any?
      property_id = properties.first['id']
      get api_v1_scraper_record_path(property_id), headers: @headers
      assert_response :success
      
      property_detail = json_response['data']
      assert property_detail.key?('descricao')
      assert property_detail.key?('amenities')
    end
  end

  test "authentication flow" do
    # 1. Tentar acessar endpoint protegido sem token
    get api_v1_scraper_records_path
    assert_response :unauthorized

    # 2. Acessar com token válido
    get api_v1_scraper_records_path, headers: @headers
    assert_response :success

    # 3. Testar logout
    delete api_v1_users_sign_out_path, headers: @headers
    assert_response :success

    # 4. Tentar usar token após logout
    get api_v1_scraper_records_path, headers: @headers
    assert_response :unauthorized
  end
end
```

## 📈 Métricas de Qualidade

### 1. **Cobertura de Código**
- **Meta**: > 80%
- **Models**: > 90%
- **Controllers**: > 80%
- **Services**: > 85%

### 2. **Performance dos Testes**
- **Meta**: < 30 segundos para suite completa
- **Testes unitários**: < 100ms cada
- **Testes de integração**: < 1s cada

### 3. **Qualidade dos Testes**
- **Testes devem ser independentes**
- **Um teste, uma responsabilidade**
- **Nomes descritivos**
- **Setup e teardown apropriados**

## 🔧 Configurações de Teste

### 1. **Configuração do Banco de Teste**

```ruby
# config/environments/test.rb
Rails.application.configure do
  # Configurações específicas de teste
  config.cache_classes = true
  config.eager_load = false
  config.public_file_server.enabled = true
  config.public_file_server.headers = {
    'Cache-Control' => 'public, max-age=3600'
  }

  # Logs
  config.log_level = :warn
  config.log_formatter = ::Logger::Formatter.new

  # Banco de dados
  config.active_record.dump_schema_after_migration = false

  # Cache
  config.cache_store = :null_store

  # Jobs
  config.active_job.queue_adapter = :test
end
```

### 2. **Configuração de Test Helpers**

```ruby
# test/test_helper.rb
ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'rails/test_help'

class ActiveSupport::TestCase
  # Setup fixtures
  fixtures :all

  # Include helper modules
  include FactoryBot::Syntax::Methods if defined?(FactoryBot)
  
  # Cleanup after tests
  teardown do
    ActionMailer::Base.deliveries.clear
  end
end

class ActionDispatch::IntegrationTest
  # Setup for integration tests
  setup do
    # Clear any cached data
    Rails.cache.clear
  end
end
```

## 🚀 Executando Testes em CI/CD

### 1. **GitHub Actions**

```yaml
# .github/workflows/test.yml
name: Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    
    services:
      postgres:
        image: postgres:14
        env:
          POSTGRES_PASSWORD: postgres
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5

    steps:
    - uses: actions/checkout@v3
    
    - name: Set up Ruby
      uses: ruby/setup-ruby@v1
      with:
        ruby-version: 3.2
        bundler-cache: true
    
    - name: Set up database
      env:
        DATABASE_URL: postgresql://postgres:postgres@localhost:5432/rails_test
      run: |
        bundle exec rails db:create
        bundle exec rails db:migrate
    
    - name: Run tests
      env:
        DATABASE_URL: postgresql://postgres:postgres@localhost:5432/rails_test
      run: bundle exec rails test
    
    - name: Run tests with coverage
      env:
        COVERAGE: true
        DATABASE_URL: postgresql://postgres:postgres@localhost:5432/rails_test
      run: bundle exec rails test
    
    - name: Upload coverage to Codecov
      uses: codecov/codecov-action@v3
      with:
        file: ./coverage/coverage.xml
```

## 📝 Boas Práticas

### 1. **Estrutura de Testes**
- **AAA Pattern**: Arrange, Act, Assert
- **Testes independentes**: Cada teste deve poder rodar isoladamente
- **Nomes descritivos**: `test_should_create_user_with_valid_email`

### 2. **Mocking e Stubbing**
- **Mock apenas o necessário**: Evite over-mocking
- **Use VCR para HTTP requests**: Gravar e reutilizar requisições
- **Stub external dependencies**: Banco, APIs externas

### 3. **Dados de Teste**
- **Use fixtures para dados estáticos**: Configurações, usuários padrão
- **Use factories para dados dinâmicos**: Criação de objetos complexos
- **Cleanup adequado**: Limpar estado entre testes

### 4. **Assertions**
- **Assertions específicas**: Use `assert_equal` ao invés de `assert`
- **Mensagens claras**: Adicione mensagens descritivas às assertions
- **Teste edge cases**: Valores nulos, strings vazias, limites

---

**Execute os testes regularmente para manter a qualidade do código! 🎯**
