# Responsibilities & Ownership

## Application Responsibilities

### Consumer Mobile App (`mobile/`) Responsibilities

**Primary Role**: Consumer-facing mobile application

#### UI/UX Responsibilities
- ✅ User interface design and implementation
- ✅ Navigation and routing
- ✅ Form validation and user input handling
- ✅ Loading states and error handling
- ✅ Responsive design for different screen sizes
- ✅ Platform-specific UI (iOS/Android)

#### Data Responsibilities
- ✅ API communication (HTTP requests)
- ✅ Local data caching
- ✅ Token storage and management
- ✅ Offline data handling (future)
- ✅ Image caching

#### Business Logic Responsibilities
- ✅ Client-side validation
- ✅ State management (Riverpod)
- ✅ Navigation logic
- ✅ User feedback (snackbars, dialogs)
- ✅ Share functionality
- ✅ URL/Phone launching

#### What Consumer Mobile Does NOT Do
- ❌ Database operations (uses API)
- ❌ Authentication logic (uses API)
- ❌ Payment processing (uses API)
- ❌ Business rule enforcement (uses API)
- ❌ Data persistence (uses API + local cache)
- ❌ Business management (merchant features)

---

### Merchant Mobile App (`merchant-mobile/`) Responsibilities

**Primary Role**: Merchant business management mobile application

#### UI/UX Responsibilities
- ✅ Merchant-focused interface design
- ✅ Business dashboard UI
- ✅ Listing management UI
- ✅ Booking management UI
- ✅ Analytics visualization
- ✅ Revenue tracking UI

#### Data Responsibilities
- ✅ API communication (merchant endpoints)
- ✅ Local data caching
- ✅ Token storage and management
- ✅ Business data synchronization

#### Business Logic Responsibilities
- ✅ Client-side validation
- ✅ State management (Riverpod)
- ✅ Navigation logic
- ✅ Business metrics calculation
- ✅ Booking status management

#### What Merchant Mobile Does NOT Do
- ❌ Database operations (uses API)
- ❌ Authentication logic (uses API)
- ❌ Payment processing (uses API)
- ❌ Consumer features (browsing, booking as user)
- ❌ Admin features (platform management)

---

### Backend API (`backend/`) Responsibilities

**Primary Role**: Business logic, data management, API provider

#### Core Responsibilities
- ✅ **Authentication & Authorization**
  - User registration/login
  - JWT token generation and validation
  - Role-based access control
  - Password hashing and validation

- ✅ **Data Management**
  - Database operations (PostgreSQL)
  - Data validation and sanitization
  - Data relationships and joins
  - Data aggregation and calculations

- ✅ **Business Logic**
  - Booking availability checking
  - Price calculations
  - Discount/coupon application
  - Review moderation workflow
  - Payment processing integration

- ✅ **API Endpoints**
  - RESTful API design
  - Request/response handling
  - Error handling and status codes
  - API documentation (Swagger)

- ✅ **Security**
  - Input validation
  - SQL injection prevention
  - XSS prevention
  - Rate limiting
  - CORS configuration

- ✅ **Integration**
  - External API integration (SINC for events)
  - Payment gateway integration
  - Email service integration
  - Notification service integration

#### What Backend Does NOT Do
- ❌ UI rendering (provides data only)
- ❌ Client-side validation (validates server-side)
- ❌ Mobile-specific logic (platform-agnostic)
- ❌ Direct database access from clients (API only)

---

### Admin Dashboard (`admin/`) Responsibilities

**Primary Role**: Administrative interface for platform management

#### Core Responsibilities
- ✅ **Dashboard & Analytics**
  - Data visualization
  - Charts and graphs
  - Key metrics display
  - Report generation

- ✅ **Content Management**
  - Listing management (CRUD)
  - User management
  - Booking management
  - Review moderation

- ✅ **Merchant Management**
  - Merchant onboarding
  - Merchant verification
  - Merchant statistics
  - Merchant support

- ✅ **Administrative Actions**
  - Approve/reject listings
  - Moderate reviews
  - Manage users
  - Handle disputes

#### What Admin Does NOT Do
- ❌ Direct database access (uses API)
- ❌ Business logic implementation (uses API)
- ❌ Payment processing (uses API)
- ❌ Mobile app functionality

---

### Public Web App (`web/`) Responsibilities

**Primary Role**: Public-facing website (Future)

#### Planned Responsibilities
- ⏳ **Public Information**
  - Homepage
  - About page
  - Contact information
  - Blog/News

- ⏳ **Public Listings**
  - Browse listings (no login required)
  - View listing details
  - Search functionality

- ⏳ **Marketing**
  - Promotional content
  - Special offers
  - Newsletter signup

#### What Web Will NOT Do
- ❌ User authentication (optional, for bookings)
- ❌ Admin functionality
- ❌ Direct database access

---

## Feature Ownership Matrix

| Feature | Mobile | Backend | Admin | Web |
|---------|--------|---------|-------|-----|
| **User Registration** | UI | Logic + Storage | View Only | ⏳ |
| **User Login** | UI | Logic + Auth | View Only | ⏳ |
| **Browse Listings** | Display | Data + Filtering | Manage | Display |
| **View Listing Details** | Display | Data | Edit | Display |
| **Create Booking** | Form | Logic + Storage | View/Manage | ⏳ |
| **Cancel Booking** | Action | Logic | Action | ❌ |
| **Write Review** | Form | Storage + Moderation | Moderate | ⏳ |
| **Add Favorite** | Action | Storage | View Only | ❌ |
| **Search** | UI | Search Logic | Search | Search |
| **Payment** | UI | Processing | View | ⏳ |
| **Admin Dashboard** | ❌ | Data | Display | ❌ |
| **Analytics** | ❌ | Calculation | Display | ❌ |
| **Content Moderation** | ❌ | Workflow | Actions | ❌ |
| **Merchant Management** | ❌ | API | UI | ❌ |

---

## Data Ownership

### Who Owns What Data?

#### User Data
- **Storage**: Backend (PostgreSQL)
- **Access**: Mobile (own profile), Admin (all users), Backend (all operations)
- **Modification**: Mobile (own profile), Admin (any user), Backend (system)

#### Listing Data
- **Storage**: Backend (PostgreSQL)
- **Access**: Mobile (read), Admin (read/write), Backend (all operations)
- **Modification**: Admin, Backend, Merchants (via API)

#### Booking Data
- **Storage**: Backend (PostgreSQL)
- **Access**: Mobile (own bookings), Admin (all bookings), Backend (all operations)
- **Modification**: Mobile (own bookings - cancel), Admin (all bookings), Backend (all operations)

#### Review Data
- **Storage**: Backend (PostgreSQL)
- **Access**: Mobile (read/write own), Admin (all), Backend (all operations)
- **Modification**: Mobile (own reviews), Admin (moderate), Backend (all operations)

---

## API Ownership

### Who Calls What?

#### Mobile App API Calls
- ✅ `/auth/*` - Authentication
- ✅ `/users/me` - Own profile
- ✅ `/listings/*` - Browse and view
- ✅ `/categories/*` - Category data
- ✅ `/bookings/*` - Create and manage own bookings
- ✅ `/reviews/*` - Create and view reviews
- ✅ `/favorites/*` - Manage favorites
- ✅ `/search/*` - Search functionality
- ❌ `/admin/*` - No access (admin only)

#### Admin Dashboard API Calls
- ✅ `/auth/*` - Admin authentication
- ✅ `/admin/*` - All admin endpoints
- ✅ `/users/*` - User management
- ✅ `/listings/*` - Listing management
- ✅ `/bookings/*` - Booking management
- ✅ `/reviews/*` - Review moderation
- ✅ `/analytics/*` - Analytics data

#### Backend Internal Operations
- ✅ Database operations (Prisma)
- ✅ External API calls (SINC, payment gateways)
- ✅ Email notifications
- ✅ Background jobs
- ✅ Data migrations

---

## Development Workflow Ownership

### Mobile Development
- **Developer**: Mobile team
- **Repository**: `zoea.mobile.2.git`
- **Deployment**: Flutter build → App stores
- **Testing**: Unit tests, widget tests, integration tests

### Backend Development
- **Developer**: Backend team
- **Repository**: `zoea2-apis.git`
- **Deployment**: Docker → Server
- **Testing**: Unit tests, e2e tests, API tests

### Admin Development
- **Developer**: Admin team
- **Repository**: (to be configured)
- **Deployment**: Next.js build → Hosting
- **Testing**: Component tests, e2e tests

### Web Development
- **Developer**: Web team
- **Repository**: (to be configured)
- **Deployment**: (to be determined)
- **Testing**: (to be determined)

---

## Decision Making Ownership

### Who Decides What?

#### UI/UX Decisions
- **Mobile**: Mobile team (with design team)
- **Admin**: Admin team (with design team)
- **Web**: Web team (with design team)

#### API Design Decisions
- **Backend**: Backend team (with input from mobile/admin teams)
- **Approval**: Technical lead

#### Database Schema Decisions
- **Backend**: Backend team
- **Approval**: Technical lead + DBA

#### Feature Prioritization
- **Product**: Product manager
- **Input**: All teams
- **Final Decision**: Product manager

#### Technical Architecture
- **All Teams**: Technical lead
- **Input**: All teams
- **Final Decision**: Technical lead

---

## Support & Maintenance

### Who Supports What?

#### Mobile App Issues
- **Support**: Mobile team
- **Escalation**: Backend team (if API issue)

#### Backend API Issues
- **Support**: Backend team
- **Escalation**: DevOps (if infrastructure issue)

#### Admin Dashboard Issues
- **Support**: Admin team
- **Escalation**: Backend team (if API issue)

#### Database Issues
- **Support**: Backend team + DBA
- **Escalation**: DevOps (if infrastructure issue)

---

## Integration Points

### Mobile ↔ Backend
- **Protocol**: REST API (HTTPS)
- **Authentication**: JWT tokens
- **Data Format**: JSON
- **Error Handling**: Standard HTTP status codes

### Admin ↔ Backend
- **Protocol**: REST API (HTTPS)
- **Authentication**: JWT tokens (admin role)
- **Data Format**: JSON
- **Error Handling**: Standard HTTP status codes

### Backend ↔ Database
- **Protocol**: Prisma ORM
- **Database**: PostgreSQL
- **Connection**: Connection pooling
- **Migrations**: Prisma migrations

### Backend ↔ External Services
- **SINC API**: Events data
- **Payment Gateways**: Payment processing
- **Email Service**: Notifications
- **SMS Service**: OTP/Notifications

