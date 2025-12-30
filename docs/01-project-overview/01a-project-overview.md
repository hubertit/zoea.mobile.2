# Zoea Project Overview

## Project Description

Zoea is a comprehensive travel and tourism platform for Rwanda, providing users with access to accommodations, dining, experiences, events, tours, and more. The platform consists of multiple applications working together to deliver a seamless experience.

## Applications

### 1. Consumer Mobile App (`mobile/`)
- **Technology**: Flutter (Dart)
- **Platform**: iOS, Android
- **Purpose**: Consumer-facing mobile application
- **Users**: End users (travelers, tourists, locals)

### 2. Merchant Mobile App (`merchant-mobile/`)
- **Technology**: Flutter (Dart)
- **Platform**: iOS, Android
- **Purpose**: Merchant business management mobile app
- **Users**: Merchants (hotel owners, restaurant owners, tour operators)

### 3. Backend API (`backend/`)
- **Technology**: NestJS (TypeScript)
- **Database**: PostgreSQL + PostGIS
- **ORM**: Prisma
- **Purpose**: RESTful API serving all applications
- **Users**: All applications (mobile, merchant-mobile, admin, web)

### 4. Admin Dashboard (`admin/`)
- **Technology**: Next.js (React, TypeScript)
- **Purpose**: Admin and partners management dashboard
- **Users**: Platform administrators, partners, operators

### 5. Consumer Web App (`web/`)
- **Technology**: To be determined (Next.js recommended)
- **Purpose**: Public-facing website for consumers
- **Users**: General public, potential customers

### 6. Merchant Web Portal (`merchant-web/`)
- **Technology**: To be determined (Next.js recommended)
- **Purpose**: Merchant business management web portal
- **Users**: Merchants (web-based management)

## Project Structure

```
zoea2/
├── mobile/          # Consumer mobile app (Flutter)
├── merchant-mobile/ # Merchant mobile app (Flutter)
├── backend/         # NestJS API
├── admin/           # Admin & Partners dashboard (Next.js)
├── web/             # Consumer web app (Next.js - future)
├── merchant-web/    # Merchant web portal (Next.js - future)
├── docs/            # Project documentation
├── database/        # Database schemas and dumps
├── migration/       # Database migration scripts
└── scripts/         # Shared utility scripts
```

## Git Repositories

Each application maintains its own git repository:
- **mobile/**: `https://github.com/hubertit/zoea.mobile.2.git`
- **merchant-mobile/**: `https://github.com/zoea-africa/zoea-partner-mobile.git`
- **backend/**: `https://github.com/zoea-africa/zoea2-apis.git`
- **admin/**: (to be configured)
- **web/**: (to be configured)
- **merchant-web/**: (to be configured)

## Technology Stack Summary

| Application | Framework | Language | Database | Key Libraries |
|------------|-----------|----------|----------|---------------|
| Consumer Mobile | Flutter | Dart | N/A (API client) | Riverpod, GoRouter, Dio |
| Merchant Mobile | Flutter | Dart | N/A (API client) | Riverpod, GoRouter, Dio |
| Backend | NestJS | TypeScript | PostgreSQL | Prisma, JWT, Swagger |
| Admin | Next.js | TypeScript | MySQL (legacy) | React, Tailwind, ApexCharts |
| Consumer Web | Next.js (planned) | TypeScript | N/A (API client) | React, Tailwind |
| Merchant Web | Next.js (planned) | TypeScript | N/A (API client) | React, Tailwind |

## API Base URL

**Production**: `https://zoea-africa.qtsoftwareltd.com/api`  
**Documentation**: `https://zoea-africa.qtsoftwareltd.com/api/docs`

## Authentication

- **Method**: JWT (JSON Web Tokens)
- **Tokens**: Access token + Refresh token
- **Flow**: Login → Receive tokens → Include in requests → Auto-refresh on 401

