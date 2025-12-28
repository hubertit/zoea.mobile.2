# Zoea Project

This is the main Zoea project directory containing all related applications and services.

## Structure

```
zoea2/
├── mobile/          # Consumer mobile app (Flutter)
│   ├── lib/         # Flutter source code
│   ├── android/     # Android platform files
│   ├── ios/         # iOS platform files
│   ├── pubspec.yaml # Flutter dependencies
│   └── .git/        # Git repository
├── merchant-mobile/  # Merchant mobile app (Flutter)
│   ├── lib/         # Flutter source code
│   ├── android/     # Android platform files
│   ├── ios/         # iOS platform files
│   ├── pubspec.yaml # Flutter dependencies
│   └── .git/        # Git repository
├── backend/         # NestJS backend API
│   ├── src/         # Source code
│   ├── prisma/      # Database schema
│   └── .git/        # Git repository
├── admin/           # Admin and partners dashboard (Next.js)
│   ├── src/         # Source code
│   └── .git/        # Git repository
├── web/             # Consumer web app (Next.js)
│   └── .git/        # Git repository (ready for remote)
├── merchant-web/    # Merchant web portal (Next.js) - Future
│   └── .git/        # Git repository (ready for remote)
├── docs/            # Documentation
├── scripts/         # Shared scripts
├── migration/       # Database migration scripts
└── database/        # Database schemas and dumps
```

## Git Repositories

Each application maintains its own git repository:

- **mobile/**: `https://github.com/hubertit/zoea.mobile.2.git`
- **merchant-mobile/**: (preserved from original location)
- **backend/**: `https://github.com/zoea-africa/zoea2-apis.git`
- **admin/**: (to be configured)
- **web/**: (to be configured)
- **merchant-web/**: (to be configured)

## Development

### Consumer Mobile (Flutter)
```bash
cd mobile
flutter pub get
flutter run
```

### Merchant Mobile (Flutter)
```bash
cd merchant-mobile
flutter pub get
flutter run
```

### Backend (NestJS)
```bash
cd backend
npm install
npm run start:dev
```

### Admin (Next.js)
```bash
cd admin
npm install
npm run dev
```

### Web (Public App)
```bash
cd web
npm install
npm run dev
```

## Deployment

Deployment scripts remain in their respective directories:
- Backend: `backend/sync-all-environments.sh` (uses relative paths)
- Mobile: Standard Flutter deployment
- Admin: Standard Next.js deployment

## Location

**Project Root**: `/Users/macbookpro/projects/flutter/zoea2`

This is your main working directory. All development happens here.
