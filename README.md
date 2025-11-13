# Real Estate Search System

Web system that automates the collection of real estate data from multiple real estate agencies, centralizing information in a single platform to facilitate property search and comparison.

## 🚀 Technologies Used

### Backend
- **Ruby 3.x** - Programming language
- **Ruby on Rails 8.0** - Web framework
- **PostgreSQL** - Database
- **Devise + JWT** - Authentication
- **Nokogiri** - Web scraping
- **Sidekiq** - Background jobs

### Frontend
- **Vue 3** - JavaScript framework
- **Vue Router** - Routing
- **Pinia** - State management
- **Axios** - HTTP client
- **Custom CSS** - Custom design system

### DevOps
- **Docker** - Containerization
- **Docker Compose** - Orchestration

## 📋 Features

- **Complete REST API** - Endpoints for properties and authentication
- **Automated web scraping** - 3 integrated real estate agencies (Solar, Simão, MWS)
- **Vue.js Frontend** - Modern and responsive interface
- **JWT Authentication** - Secure login system
- **Filter system** - Advanced search by multiple criteria
- **Pagination** - Efficient navigation through results

## 🚀 How to Run

### Prerequisites
- **Docker & Docker Compose** (Recommended)
- **Ruby 3.2+** and **Node.js 18+** (Local development)

### Using Docker (Recommended)
```bash
# Clone the repository
git clone <your-repository>
cd sistema-busca-imoveis

# Start all services
docker-compose up --build

# Run migrations
docker-compose exec backend rails db:migrate

# Access the application
# Frontend: http://localhost:3000
# Backend API: http://localhost:3001
```

### Local Development
```bash
# Backend
cd backend
bundle install
rails db:create db:migrate
rails server -p 3001

# Frontend (in another terminal)
cd frontend
npm install
npm run dev
```

## 📚 Documentation

- **[API Documentation](backend/docs/API.md)** - Complete API documentation
- **[Architecture](backend/docs/ARCHITECTURE.md)** - System architecture
- **[Installation Guide](backend/docs/INSTALLATION.md)** - Detailed installation guide
- **[Testing Guide](backend/docs/TESTING.md)** - Testing guide

## 🔧 Development Scripts

```bash
# Install dependencies for both projects
npm run install:all

# Run in development mode
npm run dev

# Run tests
npm run test:backend
npm run test:all

# Build for production
npm run build
```

## 🌐 Access URLs

### Development
- **Frontend**: http://localhost:3001
- **Backend API**: http://localhost:3000

### Production
- **Frontend**: https://seuapp.com
- **Backend API**: https://api.seuapp.com

## 📄 License

This project is under the MIT license. See the [LICENSE](LICENSE) file for more details.
