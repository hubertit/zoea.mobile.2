# Documentation Organization

**Last Updated**: December 30, 2024

---

## Documentation Structure

All documentation is organized in `/docs` with the following structure:

```
docs/
├── README.md                    # Main documentation index
├── 01-project-overview/         # Project overview and status
├── 02-architecture/             # System architecture
├── 03-mobile/                   # Consumer mobile app
├── 04-merchant-mobile/          # Merchant mobile app
├── 05-backend/                  # Backend API
├── 06-admin/                    # Admin dashboard
├── 07-web/                      # Web applications (planned)
├── 08-database/                 # Database documentation
├── 09-deployment/               # Deployment guides
├── 10-development/              # Development guides
├── 11-api-reference/            # API reference
├── 12-features/                 # Features documentation
├── 13-testing/                  # Testing guides
└── 14-troubleshooting/          # Troubleshooting guides
```

---

## Naming Convention

- **Directories**: Numbered for ordering (e.g., `01-project-overview/`)
- **Files**: Lowercase with hyphens (e.g., `01-project-overview.md`)
- **Numbering**: Sequential numbering within each directory

---

## File Organization

### Project Overview (01-project-overview/)
- Project overview and description
- Project status and progress
- Features breakdown
- Quick reference guide

### Architecture (02-architecture/)
- System architecture
- Architecture diagrams
- Project structure recommendations
- Admin/merchant architecture

### Mobile App (03-mobile/)
- Mobile app overview
- Codebase analysis
- Features documentation
- User data collection
- API integration
- Authentication
- Bookings
- Search

### Merchant Mobile (04-merchant-mobile/)
- Merchant app overview
- Codebase analysis
- Features documentation

### Backend (05-backend/)
- Backend overview
- Codebase analysis
- API reference
- Database schema
- Migration guide
- Deployment
- Filters and sorting

### Admin (06-admin/)
- Admin overview
- Codebase analysis
- Merchants module
- Database analysis
- Dashboard analytics

### Web (07-web/)
- Consumer web (planned)
- Merchant web (planned)

### Database (08-database/)
- Database schema
- Schema analysis
- Migration history
- Optimization guides

### Deployment (09-deployment/)
- Deployment guide
- Deployment checklist
- Environment setup
- Deployment test results

### Development (10-development/)
- Development guide
- Environment setup
- IntelliJ setup
- Run configurations
- Contributing guidelines
- Code style

### API Reference (11-api-reference/)
- API overview
- Endpoints
- API comparison
- API codebase analysis

### Features (12-features/)
- Features overview
- User flows
- Bookings
- Search
- Session management

### Testing (13-testing/)
- Testing guide
- Test credentials

### Troubleshooting (14-troubleshooting/)
- Troubleshooting guide
- Temporary changes log

---

## Documentation Standards

1. **Consistency**: All files follow the same naming convention
2. **Cross-references**: Use relative paths for links
3. **Updates**: Maintain "Last Updated" dates
4. **Versioning**: Track version numbers for major changes
5. **Completeness**: Each major section has an overview file

---

## Migration Notes

- Old documentation files have been moved to appropriate directories
- Some files may exist in both old and new locations temporarily
- All new documentation should be created in the new structure
- Old files will be removed after verification

---

## Maintenance

- Update documentation with code changes
- Keep cross-references current
- Maintain index files
- Review and update regularly

---

**See [README.md](./README.md) for the complete documentation index**

