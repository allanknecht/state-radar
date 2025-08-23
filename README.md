# Scraper de Imóveis

## Integrantes da Equipe
- Allan Knecht

## Descrição do Problema
Atualmente, a busca por imóveis exige que o usuário acesse diversos sites de imobiliárias para comparar preços, localização e características. Esse processo é demorado e pouco prático, especialmente para quem busca agilidade e centralização das informações.

## Objetivo do Sistema
Desenvolver um sistema que automatize a coleta de informações de imóveis a partir de múltiplos sites de imobiliárias, armazene esses dados em um banco de dados centralizado e permita que usuários logados pesquisem e filtrem os imóveis de forma rápida e prática.

## Tecnologias Pretendidas
- **Linguagem:** Ruby  
- **Framework:** Ruby on Rails  
- **Banco de Dados:** PostgreSQL  
- **Bibliotecas para Web Scraping:** Nokogiri, HTTParty, ou Selenium (caso necessário)  
- **Frontend:** HTML, CSS, Bootstrap  
- **Autenticação:** Devise  
- **Hospedagem:** Heroku ou Render  

## Funcionalidades Principais
- [x] Coletar automaticamente dados de imóveis de múltiplas imobiliárias (obrigatória)
- [x] Salvar os dados no banco de dados centralizado (obrigatória)
- [x] Permitir que usuários logados pesquisem por imóveis (obrigatória)
- [ ] Filtros avançados de busca (opcional)
- [ ] Atualização periódica automática dos dados (opcional)

## Requisitos Funcionais e Não Funcionais
- **Funcionais:**
  - **RF01:** Permitir o login e cadastro de usuários.
  - **RF02:** Permitir busca por imóveis com base nos dados coletados.
  - **RF03:** Coletar dados de imóveis de pelo menos 3 sites diferentes.
  - **RF04:** Armazenar no banco de dados informações como título, preço, endereço, descrição, imagens e link original do anúncio.
  
- **Não Funcionais:**
  - **RNF01:** O sistema deve ser responsivo e funcionar em dispositivos móveis.
  - **RNF02:** A coleta de dados deve respeitar limites de requisições e termos de uso dos sites.
  - **RNF03:** O banco de dados deve suportar pelo menos 100 mil registros de imóveis.

## Prototipação Inicial
Ainda em fase inicial. Protótipo será desenvolvido no Figma ou diretamente no frontend do projeto.
