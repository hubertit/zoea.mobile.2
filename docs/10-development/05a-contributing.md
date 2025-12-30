# Contributing Guide

## How to Contribute

Thank you for considering contributing to the Zoea project! This guide will help you get started.

## Development Workflow

### 1. Setup Development Environment

See `ENVIRONMENT_SETUP.md` for complete setup instructions.

### 2. Choose What to Work On

- Check existing issues/tasks
- Discuss with team before starting major features
- Review `FEATURES.md` for planned features

### 3. Create a Branch

Each app has its own git repository:

```bash
# Mobile
cd mobile
git checkout -b feature/your-feature-name

# Backend
cd backend
git checkout -b feature/your-feature-name

# Admin
cd admin
git checkout -b feature/your-feature-name
```

### 4. Make Changes

- Follow code style guidelines
- Write tests for new features
- Update documentation
- Test thoroughly

### 5. Commit Changes

```bash
git add .
git commit -m "feat: Add your feature description"
```

**Commit Message Format**:
- `feat:` - New feature
- `fix:` - Bug fix
- `docs:` - Documentation
- `style:` - Code style (formatting)
- `refactor:` - Code refactoring
- `test:` - Tests
- `chore:` - Maintenance

### 6. Push and Create Pull Request

```bash
git push origin feature/your-feature-name
```

Then create a pull request on GitHub.

---

## Code Style

### Mobile (Flutter/Dart)

- Follow [Flutter Style Guide](https://flutter.dev/docs/development/ui/widgets-intro)
- Use `dart format` before committing
- Run `flutter analyze` before committing

### Backend (NestJS/TypeScript)

- Follow [NestJS Style Guide](https://docs.nestjs.com/)
- Use ESLint configuration
- Run `npm run lint` before committing

### Admin (Next.js/TypeScript)

- Follow [Next.js Best Practices](https://nextjs.org/docs)
- Use ESLint configuration
- Run `npm run lint` before committing

---

## Testing

### Before Submitting

- ✅ All tests pass
- ✅ Code analysis passes (no errors)
- ✅ Manual testing completed
- ✅ Documentation updated

### Running Tests

**Mobile**:
```bash
cd mobile
flutter test
```

**Backend**:
```bash
cd backend
npm test
```

**Admin**:
```bash
cd admin
npm test  # If configured
```

---

## Documentation

### When to Update Documentation

- ✅ New feature added
- ✅ API changes
- ✅ Workflow changes
- ✅ Configuration changes
- ✅ Bug fixes that affect behavior

### Documentation Files

- Update relevant files in `docs/`
- Update app-specific README.md
- Update API documentation (if backend changes)

---

## Pull Request Process

### PR Checklist

- [ ] Code follows style guidelines
- [ ] Tests added/updated
- [ ] Documentation updated
- [ ] No breaking changes (or documented)
- [ ] Reviewed by at least one team member
- [ ] All CI checks pass

### PR Description

Include:
- What changed
- Why it changed
- How to test
- Screenshots (if UI changes)
- Related issues

---

## Questions?

- Check documentation in `docs/`
- Ask team members
- Review existing code
- Check GitHub issues

---

## Code of Conduct

- Be respectful
- Be constructive
- Help others learn
- Follow project guidelines

