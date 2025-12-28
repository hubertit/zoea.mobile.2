#!/bin/bash

# Zoea Development Environment Setup Script
# This script helps set up the development environment

set -e

echo "🚀 Zoea Development Environment Setup"
echo "======================================"
echo ""

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Check prerequisites
check_prerequisite() {
    if command -v $1 &> /dev/null; then
        echo -e "${GREEN}✅ $1 installed${NC}"
        return 0
    else
        echo -e "${RED}❌ $1 not found${NC}"
        return 1
    fi
}

echo "Checking prerequisites..."
check_prerequisite node || echo "Install Node.js: https://nodejs.org/"
check_prerequisite npm || echo "npm comes with Node.js"
check_prerequisite flutter || echo "Install Flutter: https://flutter.dev/"
check_prerequisite psql || echo "Install PostgreSQL: https://www.postgresql.org/"
echo ""

# Backend setup
echo -e "${YELLOW}📦 Setting up Backend...${NC}"
cd backend

if [ ! -f ".env" ]; then
    echo "Creating .env file from env.example..."
    cp env.example .env
    echo -e "${YELLOW}⚠️  Please edit backend/.env with your database credentials${NC}"
else
    echo "✅ .env file exists"
fi

if [ ! -d "node_modules" ]; then
    echo "Installing backend dependencies..."
    npm install
else
    echo "✅ Backend dependencies installed"
fi

echo "Generating Prisma client..."
npx prisma generate || echo "⚠️  Prisma generate failed - check database connection"

cd ..
echo ""

# Mobile setup
echo -e "${YELLOW}📱 Setting up Mobile...${NC}"
cd mobile

if [ ! -d ".dart_tool" ]; then
    echo "Installing Flutter dependencies..."
    flutter pub get
else
    echo "✅ Mobile dependencies installed"
fi

cd ..
echo ""

# Admin setup
echo -e "${YELLOW}🖥️  Setting up Admin...${NC}"
cd admin

if [ ! -d "node_modules" ]; then
    echo "Installing admin dependencies..."
    npm install || pnpm install
else
    echo "✅ Admin dependencies installed"
fi

cd ..
echo ""

echo -e "${GREEN}✅ Setup complete!${NC}"
echo ""
echo "Next steps:"
echo "1. Configure backend/.env with database credentials"
echo "2. Run database migrations: cd backend && npx prisma migrate dev"
echo "3. Start backend: cd backend && npm run start:dev"
echo "4. Start mobile: cd mobile && flutter run"
echo "5. Start admin: cd admin && npm run dev"

