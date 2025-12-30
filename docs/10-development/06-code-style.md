# Code Style and Conventions

**Last Updated**: December 30, 2024

---

## Mobile App (Flutter/Dart)

### Naming Conventions
- **Files**: `snake_case.dart`
- **Classes**: `PascalCase`
- **Variables/Methods**: `camelCase`
- **Constants**: `UPPER_SNAKE_CASE`

### Code Organization
- Feature-based structure
- Core utilities in `core/`
- Shared widgets in `core/widgets/`
- Services in `core/services/`
- Providers in `core/providers/`

### Best Practices
- Use Riverpod for state management
- Use GoRouter for navigation
- Follow Flutter best practices
- Use `AppTheme` for consistent styling
- Handle errors gracefully
- Use async/await properly

---

## Backend (NestJS/TypeScript)

### Naming Conventions
- **Files**: `kebab-case.ts`
- **Classes**: `PascalCase`
- **Variables/Methods**: `camelCase`
- **Constants**: `UPPER_SNAKE_CASE`

### Code Organization
- Module-based structure
- Controllers for endpoints
- Services for business logic
- DTOs for data transfer
- Entities for database models

### Best Practices
- Use dependency injection
- Validate input with DTOs
- Handle errors with exception filters
- Use Prisma for database access
- Document APIs with Swagger

---

## Admin Dashboard (Next.js/TypeScript)

### Naming Conventions
- **Files**: `kebab-case.tsx`
- **Components**: `PascalCase`
- **Variables/Methods**: `camelCase`

### Code Organization
- Feature-based structure
- Components in `components/`
- Pages in `app/`
- Utilities in `lib/`

### Best Practices
- Use React best practices
- Use Tailwind for styling
- Follow Next.js conventions
- Handle errors gracefully

---

## General Guidelines

- Write clear, self-documenting code
- Add comments for complex logic
- Keep functions small and focused
- Follow SOLID principles
- Write tests for critical functionality
- Update documentation with code changes

---

## Related Documentation

- [Development Guide](./01-development-guide.md)
- [Contributing](./05-contributing.md)

