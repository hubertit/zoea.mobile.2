# IntelliJ IDEA Setup Guide

## Overview

This guide helps you set up IntelliJ IDEA (or Android Studio) to work with the Zoea monorepo project structure.

## Project Structure

The Zoea project is a monorepo containing:
- **mobile/** - Flutter mobile app
- **backend/** - NestJS backend API
- **admin/** - Next.js admin dashboard
- **web/** - Public web app (future)

## Initial Setup

### 1. Open Project in IntelliJ IDEA

1. Open IntelliJ IDEA
2. Select **File → Open**
3. Navigate to `/Users/macbookpro/projects/flutter/zoea2`
4. Click **Open**

### 2. Configure Project SDKs

#### For Flutter (Mobile)
1. Go to **File → Settings → Languages & Frameworks → Flutter**
2. Set Flutter SDK path (e.g., `/path/to/flutter`)
3. Set Dart SDK path (usually auto-detected)

#### For TypeScript/Node.js (Backend & Admin)
1. Go to **File → Settings → Languages & Frameworks → Node.js**
2. Set Node.js interpreter (e.g., `/usr/local/bin/node` or via nvm)
3. Enable **Coding assistance for Node.js**

### 3. Install Required Plugins

Install these plugins via **File → Settings → Plugins**:

- **Flutter** (includes Dart)
- **Node.js**
- **TypeScript and JavaScript**
- **Prisma** (for database schema)
- **Mermaid** (for viewing architecture diagrams)

## Module Configuration

The project is configured with multiple modules:

1. **zoea2** (root module)
2. **zoea2-mobile** (Flutter app)
3. **zoea2-backend** (NestJS API)
4. **zoea2-admin** (Next.js admin)
5. **zoea2-web** (Web app)

### Viewing Modules

1. Go to **File → Project Structure → Modules**
2. You should see all modules listed
3. Each module has its own source folders and dependencies

## Project View

### Recommended View Settings

1. Go to **View → Tool Windows → Project**
2. Select **Project** view (not Android view)
3. This shows the full directory structure

### Excluded Folders

The following folders are excluded from indexing (but visible in Project view):
- `node_modules/`
- `dist/`
- `build/`
- `.dart_tool/`
- `.next/`
- `ios/Pods/`

## Running Applications

### Mobile App (Flutter)

1. Open terminal in IntelliJ: **View → Tool Windows → Terminal**
2. Navigate to mobile: `cd mobile`
3. Run: `flutter run`

Or use the Flutter run configuration:
1. **Run → Edit Configurations**
2. Click **+** → **Flutter**
3. Set Dart entry point: `lib/main.dart`
4. Set working directory: `mobile/`

### Backend API (NestJS)

1. Open terminal
2. Navigate to backend: `cd backend`
3. Run: `npm run start:dev`

Or create a Node.js run configuration:
1. **Run → Edit Configurations**
2. Click **+** → **Node.js**
3. Set JavaScript file: `backend/src/main.ts`
4. Set working directory: `backend/`
5. Set Node interpreter: Your Node.js path

### Admin Dashboard (Next.js)

1. Open terminal
2. Navigate to admin: `cd admin`
3. Run: `npm run dev`

## Code Style

### Dart/Flutter

The project uses:
- 2-space indentation
- Standard Dart style guide

Configure in: **File → Settings → Editor → Code Style → Dart**

### TypeScript/JavaScript

The project uses:
- 2-space indentation
- No tabs

Configure in: **File → Settings → Editor → Code Style → TypeScript**

## Git Integration

### Multiple Git Repositories

Each sub-project has its own git repository:
- `mobile/.git`
- `backend/.git`
- `admin/.git`
- `web/.git`

IntelliJ is configured to recognize all repositories.

### Viewing Git Status

1. **View → Tool Windows → Version Control**
2. You'll see all git repositories
3. Switch between repositories using the dropdown

## Debugging

### Flutter Debugging

1. Set breakpoints in Dart code
2. Run in debug mode: **Run → Debug 'main.dart'**
3. Use Flutter DevTools for advanced debugging

### Node.js Debugging

1. Set breakpoints in TypeScript/JavaScript
2. Create a Node.js debug configuration:
   - **Run → Edit Configurations**
   - Click **+** → **Node.js**
   - Enable **Attach to Node.js/Chrome**
   - Set port: `9229` (default)

## Code Completion

### Flutter Packages

IntelliJ should auto-complete Flutter packages after:
1. Running `flutter pub get` in the mobile directory
2. Waiting for indexing to complete

### Node.js Packages

IntelliJ should auto-complete Node.js packages after:
1. Running `npm install` in backend/admin directories
2. Waiting for indexing to complete

## Troubleshooting

### Project Not Recognizing Files

1. **File → Invalidate Caches / Restart**
2. Select **Invalidate and Restart**
3. Wait for re-indexing

### Modules Not Showing

1. **File → Project Structure → Modules**
2. Click **+** → **Import Module**
3. Select the `.iml` file for each module

### Flutter SDK Not Found

1. **File → Settings → Languages & Frameworks → Flutter**
2. Click **...** next to Flutter SDK path
3. Navigate to your Flutter installation
4. Usually: `/path/to/flutter` or `~/flutter`

### Node.js Not Found

1. **File → Settings → Languages & Frameworks → Node.js**
2. Set Node.js interpreter
3. If using nvm: `/Users/username/.nvm/versions/node/v18.x.x/bin/node`

### Slow Indexing

1. Exclude large folders: **File → Project Structure → Modules**
2. Add to excluded folders: `node_modules`, `dist`, `build`
3. **File → Invalidate Caches / Restart**

## Recommended Settings

### Editor

- **File → Settings → Editor → General**
  - Enable **Soft-wrap** for long lines
  - Enable **Show line numbers**
  - Enable **Show whitespaces**

### Code Style

- **File → Settings → Editor → Code Style**
  - Set indentation to 2 spaces for TypeScript and Dart
  - Enable **Detect and use existing file indents**

### Inspections

- **File → Settings → Editor → Inspections**
  - Enable Dart inspections
  - Enable TypeScript/JavaScript inspections
  - Enable ESLint (for backend/admin)

## Keyboard Shortcuts

### Useful Shortcuts

- **Cmd+Shift+A** (Mac) / **Ctrl+Shift+A** (Windows): Find action
- **Cmd+E** / **Ctrl+E**: Recent files
- **Cmd+B** / **Ctrl+B**: Go to declaration
- **Cmd+Click** / **Ctrl+Click**: Go to definition
- **Cmd+F12** / **Ctrl+F12**: File structure
- **Shift+F6**: Rename
- **Cmd+Alt+L** / **Ctrl+Alt+L**: Reformat code

## Tips

1. **Use Project View**: Shows the actual file structure
2. **Multiple Terminals**: Open multiple terminal tabs for different services
3. **Run Configurations**: Save run configurations for quick access
4. **Scopes**: Create custom scopes for searching (e.g., "Backend only")
5. **Bookmarks**: Use bookmarks for frequently accessed files

## Run Configurations

IntelliJ is pre-configured with run configurations for all apps:

### Available Configurations

1. **Zoea Consumer Mobile** - Run consumer mobile app
2. **Zoea Merchant Mobile** - Run merchant mobile app
3. **Backend API** - Run backend server
4. **Admin Dashboard** - Run admin dashboard

### How to Use

1. **Select Configuration**: Click the run dropdown (top toolbar)
2. **Choose App**: Select which app to run
3. **Click Run**: Press ▶️ or `Shift + F10`

See `INTELLIJ_RUN_CONFIGURATIONS.md` for detailed guide.

## Next Steps

After setup:
1. ✅ Verify all modules are recognized
2. ✅ Test running each application (use run configurations)
3. ✅ Verify code completion works
4. ✅ Run configurations are ready to use
5. ✅ Configure git integration

## See Also

- [Development Guide](./DEVELOPMENT_GUIDE.md)
- [Environment Setup](./ENVIRONMENT_SETUP.md)
- [Project Overview](./PROJECT_OVERVIEW.md)

