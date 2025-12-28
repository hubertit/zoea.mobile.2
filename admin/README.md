# Zoea Admin Dashboard

Next.js admin and merchant management dashboard.

## Technology Stack

- **Framework**: Next.js 16
- **Language**: TypeScript
- **UI Library**: React 19
- **Styling**: Tailwind CSS
- **Charts**: ApexCharts, Recharts
- **Database**: MySQL (legacy, via API)

## Project Structure

```
admin/
├── src/
│   ├── app/                # Next.js app directory
│   │   ├── (dashboard)/    # Dashboard routes
│   │   ├── (auth)/        # Authentication routes
│   │   └── api/           # API routes (if any)
│   ├── lib/                # Utilities
│   │   ├── api.ts         # API client
│   │   ├── auth.ts        # Authentication
│   │   └── db.ts          # Database utilities
│   └── types/             # TypeScript types
├── public/                 # Static assets
└── package.json           # Dependencies
```

## Getting Started

### Prerequisites

- Node.js v18+
- npm or pnpm

### Installation

```bash
cd admin
npm install
# or
pnpm install
```

### Running

```bash
# Development mode
npm run dev

# Production build
npm run build
npm run start
```

Access at `http://localhost:3000` (or configured port)

## Features

- ✅ Dashboard with analytics
- ✅ User management
- ✅ Listing management
- ✅ Booking management
- ✅ Merchant management
- ✅ Review moderation
- ✅ Analytics and reports

## API Integration

The admin dashboard communicates with the backend API:
- **Base URL**: `https://zoea-africa.qtsoftwareltd.com/api`
- **Authentication**: JWT tokens
- **Endpoints**: `/admin/*` for admin operations

## Environment Variables

Create `.env.local` (if needed):

```env
NEXT_PUBLIC_API_URL=https://zoea-africa.qtsoftwareltd.com/api
```

## Git Repository

**Remote**: (to be configured)

## Documentation

See `/docs/` directory for comprehensive documentation:
- `PROJECT_OVERVIEW.md` - Project overview
- `FEATURES.md` - Feature breakdown
- `RESPONSIBILITIES.md` - Responsibilities
