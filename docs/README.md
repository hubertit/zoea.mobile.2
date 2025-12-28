# Zoea Project Documentation

Welcome to the Zoea project documentation. This directory contains comprehensive documentation for the entire project.

## Documentation Index

### Important Notes
- **[Temporary Changes](./TEMPORARY_CHANGES.md)** - Documents temporary changes that need to be reverted in the future

### 📋 Overview & Structure
- **[PROJECT_OVERVIEW.md](./PROJECT_OVERVIEW.md)** - Project description, technology stack, and architecture overview
- **[FEATURES.md](./FEATURES.md)** - Complete feature breakdown by application
- **[RESPONSIBILITIES.md](./RESPONSIBILITIES.md)** - Who does what, ownership matrix, and decision-making

### 🔄 Flows & Processes
- **[USER_FLOWS.md](./USER_FLOWS.md)** - Detailed user flows, system flows, and data flow diagrams

### 💻 Development
- **[DEVELOPMENT_GUIDE.md](./DEVELOPMENT_GUIDE.md)** - Getting started, development workflows, and best practices

### 📊 Analysis & Integration
- **[API_CODEBASE_ANALYSIS.md](./API_CODEBASE_ANALYSIS.md)** - Backend API analysis
- **[API_COMPARISON_ANALYSIS.md](./API_COMPARISON_ANALYSIS.md)** - API comparison and integration status
- **[API_REFERENCE.md](./API_REFERENCE.md)** - Quick API endpoint reference
- **[AUTH_INTEGRATION_SUMMARY.md](./AUTH_INTEGRATION_SUMMARY.md)** - Authentication integration details
- **[BOOKING_ANALYSIS.md](./BOOKING_ANALYSIS.md)** - Booking system analysis (hotel vs restaurant)
- **[CODEBASE_ANALYSIS.md](./CODEBASE_ANALYSIS.md)** - Flutter codebase analysis
- **[COMPREHENSIVE_CODEBASE_ANALYSIS.md](./COMPREHENSIVE_CODEBASE_ANALYSIS.md)** - Comprehensive codebase overview
- **[SESSION_PERSISTENCE_IMPROVEMENTS.md](./SESSION_PERSISTENCE_IMPROVEMENTS.md)** - Session management improvements

### 🛠️ Setup & Operations
- **[ENVIRONMENT_SETUP.md](./ENVIRONMENT_SETUP.md)** - Complete environment setup guide
- **[INTELLIJ_SETUP.md](./INTELLIJ_SETUP.md)** - IntelliJ IDEA project setup guide
- **[TROUBLESHOOTING.md](./TROUBLESHOOTING.md)** - Common issues and solutions
- **[DATABASE_SCHEMA.md](./DATABASE_SCHEMA.md)** - Database schema documentation
- **[CONTRIBUTING.md](./CONTRIBUTING.md)** - Contribution guidelines
- **[TESTING_GUIDE.md](./TESTING_GUIDE.md)** - Testing strategies and examples

### 🏗️ Architecture
- **[ARCHITECTURE.md](./ARCHITECTURE.md)** - System architecture documentation
- **[ARCHITECTURE_DIAGRAMS.md](./ARCHITECTURE_DIAGRAMS.md)** - Visual architecture diagrams
- **[PROJECT_STRUCTURE_RECOMMENDATION.md](./PROJECT_STRUCTURE_RECOMMENDATION.md)** - Recommended project structure (consumer, merchant, admin)

## Quick Links

### Applications
- **Consumer Mobile**: `/mobile/` - Flutter consumer mobile app
- **Merchant Mobile**: `/merchant-mobile/` - Flutter merchant mobile app
- **Backend**: `/backend/` - NestJS backend API
- **Admin**: `/admin/` - Next.js admin & partners dashboard
- **Consumer Web**: `/web/` - Consumer web application (future)
- **Merchant Web**: `/merchant-web/` - Merchant web portal (future)

### Key Directories
- **Documentation**: `/docs/` - This directory (all project documentation)
  - `/docs/backend/` - Backend-specific documentation (analysis, migration, deployment)
  - `/docs/admin/` - Admin dashboard documentation (codebase analysis, database docs)
  - `/docs/merchant-mobile/` - Merchant mobile app documentation
- **Database**: `/database/` - Database schemas and dumps
- **Migrations**: `/migration/` - Database migration scripts
- **Scripts**: `/scripts/` - Shared utility scripts

## Application-Specific Documentation

### Backend Documentation
See `/docs/backend/` for:
- Backend codebase analysis
- Migration guides and history
- Deployment documentation
- API analysis

### Admin Dashboard Documentation
See `/docs/admin/` for:
- Admin codebase analysis
- Database analysis and analytics
- Merchant module documentation
- Test credentials

### Merchant Mobile App Documentation
See `/docs/merchant-mobile/` for:
- Merchant mobile app analysis
- Feature documentation

## Project Status

### ✅ Completed
- Project restructure (monorepo)
- Mobile app API integration (auth, listings, favorites, reviews)
- Backend API development
- Admin dashboard
- Documentation structure

### 🚧 In Progress
- Booking system integration
- Payment processing
- Push notifications

### ⏳ Planned
- Public web app
- Advanced analytics
- Offline mode
- Maps integration

## Getting Help

### For Mobile Development
- See `DEVELOPMENT_GUIDE.md` → Mobile Development section
- Check `mobile/README.md` (if exists)

### For Backend Development
- See `DEVELOPMENT_GUIDE.md` → Backend Development section
- Check `backend/README.md`
- API docs: `https://zoea-africa.qtsoftwareltd.com/api/docs`

### For Admin Development
- See `DEVELOPMENT_GUIDE.md` → Admin Development section
- Check `admin/README.md`

## Contributing

1. Read the relevant documentation
2. Follow the development guide
3. Maintain code style
4. Write tests
5. Update documentation

## Last Updated

**Date**: December 28, 2024  
**Version**: 2.0.0
