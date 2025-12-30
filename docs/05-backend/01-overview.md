# Backend API - Overview

**Last Updated**: December 30, 2024  
**Technology**: NestJS (TypeScript)  
**Database**: PostgreSQL 16 + PostGIS  
**ORM**: Prisma

---

## Description

The Zoea Backend API is a NestJS-based RESTful API that serves all Zoea applications (mobile, merchant-mobile, admin, web). It provides authentication, business logic, data storage, and API endpoints for the entire platform.

---

## Technology Stack

- **Framework**: NestJS
- **Language**: TypeScript
- **Database**: PostgreSQL 16 + PostGIS
- **ORM**: Prisma
- **Authentication**: JWT (Access Token + Refresh Token)
- **Documentation**: Swagger/OpenAPI
- **Validation**: class-validator, class-transformer

---

## API Information

- **Production Base URL**: `https://zoea-africa.qtsoftwareltd.com/api`
- **Swagger Documentation**: `https://zoea-africa.qtsoftwareltd.com/api/docs`
- **Authentication**: JWT (Access Token + Refresh Token)

---

## Git Repository

**Repository**: `https://github.com/zoea-africa/zoea2-apis.git`

---

## Related Documentation

- [Codebase Analysis](./02-codebase-analysis.md)
- [API Reference](./03-api-reference.md)
- [Database Schema](./04-database-schema.md)
- [Migration Guide](./05-migration-guide.md)
- [Deployment](./06-deployment.md)
- [Filters and Sorting](./07-filters-and-sorting.md)

---

## Quick Start

```bash
cd backend
npm install
cp env.example .env
# Edit .env with your database credentials
npx prisma generate
npx prisma migrate dev
npm run start:dev
```
