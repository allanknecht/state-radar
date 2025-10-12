# 📝 Changelog

Todas as mudanças notáveis neste projeto serão documentadas neste arquivo.

O formato é baseado em [Keep a Changelog](https://keepachangelog.com/pt-BR/1.0.0/),
e este projeto adere ao [Semantic Versioning](https://semver.org/lang/pt-BR/).

## [Unreleased]

### Adicionado
- Documentação completa da API
- Guia de instalação detalhado
- Documentação de arquitetura
- Guia de testes abrangente
- Configuração de ambiente exemplo

## [1.0.0] - 2025-01-15

### 🎉 Lançamento Inicial

#### Adicionado
- **Sistema de Autenticação**
  - Login e cadastro de usuários
  - Autenticação JWT
  - Middleware de autorização
  - Controle de sessões

- **API REST Completa**
  - Endpoints para listagem de imóveis
  - Sistema de filtros avançados (preço, localização, características)
  - Paginação automática
  - Busca por texto livre
  - Ordenação por preço e data

- **Sistema de Web Scraping**
  - Scraper base com template method pattern
  - Integração com 3 imobiliárias (Solar, Simão, MWS)
  - Extração de dados detalhados
  - Controle de rate limiting
  - Tratamento de erros robusto

- **Banco de Dados**
  - Modelo de dados completo para imóveis
  - Índices otimizados para performance
  - Validações de integridade
  - Suporte a campos JSON para amenities

- **Background Jobs**
  - Processamento assíncrono de scraping
  - Sistema de retry automático
  - Logging detalhado
  - Upsert inteligente de registros

- **Arquitetura**
  - Padrões de design implementados (Template Method, Strategy, Factory)
  - Separação clara de responsabilidades
  - Código modular e extensível
  - Configuração flexível

#### Detalhes Técnicos
- **Framework**: Ruby on Rails 8.0
- **Banco de Dados**: PostgreSQL 14+
- **Autenticação**: Devise + JWT
- **Scraping**: Nokogiri + Faraday
- **Background Jobs**: ActiveJob + Sidekiq
- **Containerização**: Docker + Docker Compose

#### Funcionalidades Principais
- ✅ Coleta automatizada de dados de imóveis
- ✅ Armazenamento centralizado no banco de dados
- ✅ API REST para consulta e filtros
- ✅ Autenticação e autorização de usuários
- ✅ Sistema de busca avançada
- ✅ Paginação e ordenação
- ✅ Processamento em background

#### Sites Integrados
- **Solar Imóveis**: https://solarimoveis.com.br
- **Simão Imóveis**: https://simaoimoveis.com.br  
- **MWS Imóveis**: https://mwsimoveis.com.br

#### Campos de Dados Coletados
- Informações básicas (título, localização, preço)
- Características físicas (dormitórios, banheiros, área)
- Detalhes adicionais (condomínio, IPTU, vagas)
- Amenidades e comodidades
- Links e imagens dos anúncios originais

### Melhorias Técnicas
- **Performance**: Índices otimizados no banco de dados
- **Segurança**: Validação de dados e sanitização
- **Escalabilidade**: Arquitetura stateless
- **Manutenibilidade**: Código bem documentado e testado
- **Monitoramento**: Health checks e logging estruturado

### Configurações
- Suporte a múltiplos ambientes (development, test, production)
- Configuração flexível via variáveis de ambiente
- Integração com Docker para desenvolvimento
- Preparação para deploy em Heroku/Render

## [0.9.0] - 2025-01-10

### Adicionado
- Sistema base de scraping
- Estrutura inicial da API
- Modelos de dados básicos

### Alterado
- Refatoração da arquitetura de scrapers
- Melhoria no tratamento de erros

### Removido
- Implementações experimentais antigas

## [0.8.0] - 2025-01-05

### Adicionado
- Integração com primeira imobiliária (Solar)
- Sistema básico de autenticação
- Estrutura inicial do banco de dados

### Alterado
- Otimização das queries de scraping
- Melhoria na estrutura de dados

## [0.7.0] - 2024-12-28

### Adicionado
- Configuração inicial do projeto Rails
- Setup do banco PostgreSQL
- Estrutura base da aplicação

---

## 🔮 Roadmap

### Versão 1.1.0 (Planejada)
- [ ] Interface web responsiva
- [ ] Sistema de favoritos para usuários
- [ ] Melhorias na performance do scraping
- [ ] Dashboard administrativo básico

### Versão 1.2.0 (Planejada)
- [ ] Sistema de notificações por email
- [ ] API GraphQL
- [ ] Cache Redis para performance
- [ ] Métricas de uso e analytics

### Versão 2.0.0 (Planejada)
- [ ] Machine Learning para preços
- [ ] Integração com mapas
- [ ] Sistema de avaliações
- [ ] Chat em tempo real
- [ ] Mobile app (React Native)

## 📊 Estatísticas do Projeto

### Código
- **Linhas de código**: ~3,500
- **Arquivos**: ~45
- **Testes**: ~25 arquivos de teste
- **Cobertura de testes**: >80%

### Funcionalidades
- **Endpoints API**: 8
- **Scrapers**: 3
- **Jobs**: 1
- **Models**: 2
- **Services**: 4

### Dados
- **Campos por imóvel**: 20+
- **Sites integrados**: 3
- **Categorias**: 2 (Venda/Locação)
- **Capacidade estimada**: 100k+ registros

## 🤝 Contribuições

### Como Contribuir
1. Fork o projeto
2. Crie uma branch para sua feature (`git checkout -b feature/nova-feature`)
3. Commit suas mudanças (`git commit -am 'Adiciona nova feature'`)
4. Push para a branch (`git push origin feature/nova-feature`)
5. Abra um Pull Request

### Padrões de Commit
Utilizamos o padrão [Conventional Commits](https://www.conventionalcommits.org/):

```
feat: adiciona novo scraper para imobiliária XYZ
fix: corrige erro de parsing de preços
docs: atualiza documentação da API
test: adiciona testes para novo service
refactor: melhora estrutura do BaseScraperService
```

### Tipos de Mudanças
- `feat`: Nova funcionalidade
- `fix`: Correção de bug
- `docs`: Mudanças na documentação
- `style`: Formatação, ponto e vírgula, etc.
- `refactor`: Refatoração de código
- `test`: Adição ou correção de testes
- `chore`: Mudanças em ferramentas, configurações, etc.

## 📞 Suporte

### Contato
- **Desenvolvedor**: Allan Knecht
- **Email**: allan.knecht@email.com
- **GitHub**: [Criar uma issue](https://github.com/seu-usuario/teams-2023-t2-kiriku-e-pequeno/issues)

### Documentação
- [README.md](README.md) - Visão geral do projeto
- [docs/API.md](docs/API.md) - Documentação da API
- [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) - Arquitetura do sistema
- [docs/INSTALLATION.md](docs/INSTALLATION.md) - Guia de instalação
- [docs/TESTING.md](docs/TESTING.md) - Guia de testes

---

**Desenvolvido com ❤️ para o projeto acadêmico de Engenharia de Software**
