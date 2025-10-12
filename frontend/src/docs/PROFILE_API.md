# API de Perfil do Usuário - Documentação

## Endpoints Necessários no Backend

### 1. Alterar Senha
```
PUT /api/v1/users/password
```

**Headers:**
```
Authorization: Bearer <token>
Content-Type: application/json
```

**Body:**
```json
{
  "user": {
    "current_password": "senha_atual",
    "password": "nova_senha",
    "password_confirmation": "nova_senha"
  }
}
```

**Resposta de Sucesso:**
```json
{
  "message": "Senha alterada com sucesso"
}
```

**Resposta de Erro:**
```json
{
  "error": "Senha atual incorreta"
}
```

### 2. Deletar Conta
```
DELETE /api/v1/users
```

**Headers:**
```
Authorization: Bearer <token>
```

**Resposta de Sucesso:**
```json
{
  "message": "Conta deletada com sucesso"
}
```

**Resposta de Erro:**
```json
{
  "error": "Não foi possível deletar a conta"
}
```

## Implementação no Backend Rails

### Controller de Usuários

```ruby
module Api
  module V1
    class UsersController < ApplicationController
      before_action :authenticate_api_v1_user!

      # PUT /users/password
      def password
        if current_user.update_with_password(password_params)
          render json: { message: "Senha alterada com sucesso" }
        else
          render json: { error: current_user.errors.full_messages.join(', ') }, status: :unprocessable_entity
        end
      end

      # DELETE /users
      def destroy
        current_user.destroy
        render json: { message: "Conta deletada com sucesso" }
      end

      private

      def password_params
        params.require(:user).permit(:current_password, :password, :password_confirmation)
      end
    end
  end
end
```

### Rotas

```ruby
# config/routes.rb
namespace :api, defaults: { format: :json } do
  namespace :v1 do
    devise_for :users,
               path: "users",
               defaults: { format: :json },
               controllers: {
                 sessions: "api/v1/users/sessions",
                 registrations: "api/v1/users/registrations",
               }
    
    # Rotas adicionais para perfil
    resources :users, only: [] do
      collection do
        put :password
        delete :destroy
      end
    end
  end
end
```

## Funcionalidades Implementadas

### ✅ **Página de Perfil Completa**

1. **Informações da Conta**
   - Email do usuário
   - Data de criação da conta

2. **Alterar Senha**
   - Validação de senha atual
   - Confirmação de nova senha
   - Validação de tamanho mínimo
   - Feedback visual de sucesso/erro

3. **Deletar Conta**
   - Modal de confirmação
   - Campo de confirmação "DELETAR"
   - Aviso sobre irreversibilidade
   - Logout automático após exclusão

### 🎨 **Interface Moderna**

- **Design responsivo** para mobile e desktop
- **Estados de loading** durante operações
- **Mensagens de erro/sucesso** claras
- **Modal de confirmação** para ações perigosas
- **Validação em tempo real** dos formulários

### 🔒 **Segurança**

- **Autenticação obrigatória** para acessar o perfil
- **Validação de senha atual** antes de alterar
- **Confirmação dupla** para deletar conta
- **Logout automático** após exclusão

### 📱 **Experiência do Usuário**

- **Navegação intuitiva** com link no header
- **Feedback visual** para todas as ações
- **Prevenção de ações acidentais**
- **Interface limpa e organizada**

## Fluxo de Funcionamento

1. **Acesso**: Usuário clica em "Perfil" no header
2. **Autenticação**: Sistema verifica se está logado
3. **Carregamento**: Exibe informações da conta
4. **Alterar Senha**: Formulário com validações
5. **Deletar Conta**: Modal com confirmação obrigatória

## Estados da Interface

- **Loading**: Durante operações de API
- **Sucesso**: Mensagem de confirmação
- **Erro**: Mensagem de erro específica
- **Validação**: Campos obrigatórios e formato

A página de perfil está totalmente integrada com o sistema de autenticação e oferece uma experiência completa de gerenciamento de conta!
