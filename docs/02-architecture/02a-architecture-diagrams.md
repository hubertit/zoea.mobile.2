# Architecture Diagrams

This document contains visual architecture diagrams using Mermaid syntax. These diagrams can be rendered in:
- GitHub (native support)
- VS Code (with Mermaid extension)
- Online tools (mermaid.live)

---

## System Overview

```mermaid
graph TB
    subgraph "Client Applications"
        Mobile[Mobile App<br/>Flutter]
        Admin[Admin Dashboard<br/>Next.js]
        Web[Web App<br/>Future]
    end
    
    subgraph "Backend Services"
        API[Backend API<br/>NestJS]
    end
    
    subgraph "Data & External"
        DB[(PostgreSQL<br/>Database)]
        SINC[SINC API<br/>Events]
        Email[Email Service]
    end
    
    Mobile -->|HTTPS/REST| API
    Admin -->|HTTPS/REST| API
    Web -->|HTTPS/REST| API
    API -->|Query| DB
    API -->|Fetch| SINC
    API -->|Send| Email
```

---

## Mobile App Architecture

```mermaid
graph TD
    subgraph "UI Layer"
        Screens[Screens/Pages]
        Widgets[Reusable Widgets]
    end
    
    subgraph "State Management"
        Providers[Riverpod Providers]
        State[App State]
    end
    
    subgraph "Business Logic"
        Services[API Services]
        Models[Data Models]
    end
    
    subgraph "Core"
        Config[App Config]
        Router[GoRouter]
        Storage[Local Storage]
    end
    
    Screens --> Widgets
    Screens --> Providers
    Widgets --> Providers
    Providers --> Services
    Services --> Models
    Services --> Config
    Providers --> State
    State --> Storage
    Screens --> Router
```

---

## Backend API Architecture

```mermaid
graph TB
    subgraph "API Layer"
        Controllers[Controllers]
        DTOs[DTOs]
    end
    
    subgraph "Business Logic"
        Services[Services]
        Guards[Guards]
        Interceptors[Interceptors]
    end
    
    subgraph "Data Access"
        Prisma[Prisma ORM]
        Repositories[Repositories]
    end
    
    subgraph "Database"
        PostgreSQL[(PostgreSQL)]
    end
    
    Controllers --> DTOs
    Controllers --> Services
    Controllers --> Guards
    Services --> Interceptors
    Services --> Repositories
    Repositories --> Prisma
    Prisma --> PostgreSQL
```

---

## Authentication Flow

```mermaid
sequenceDiagram
    participant U as User
    participant M as Mobile App
    participant B as Backend
    participant D as Database
    
    U->>M: Enter credentials
    M->>B: POST /auth/login
    B->>D: Verify user
    D-->>B: User data
    B->>B: Generate JWT tokens
    B-->>M: accessToken + refreshToken
    M->>M: Store tokens
    M->>B: API request + Bearer token
    B->>B: Validate token
    B-->>M: Response
```

---

## Booking Flow

```mermaid
sequenceDiagram
    participant U as User
    participant M as Mobile
    participant B as Backend
    participant D as Database
    participant E as Email
    
    U->>M: Create booking
    M->>M: Validate form
    M->>B: POST /bookings
    B->>B: Validate request
    B->>D: Check availability
    D-->>B: Available
    B->>B: Calculate price
    B->>D: Create booking
    D-->>B: Booking created
    B->>E: Send confirmation (async)
    B-->>M: Booking confirmation
    M->>U: Show success
```

---

## Database Schema

```mermaid
erDiagram
    User {
        uuid id PK
        string email
        string password
        string firstName
        string lastName
        datetime createdAt
    }
    
    Listing {
        uuid id PK
        string name
        string type
        uuid categoryId FK
        uuid cityId FK
        decimal rating
        decimal price
    }
    
    Booking {
        uuid id PK
        uuid userId FK
        uuid listingId FK
        string bookingType
        string status
        decimal totalAmount
        datetime createdAt
    }
    
    Review {
        uuid id PK
        uuid userId FK
        uuid listingId FK
        int rating
        string comment
        string status
    }
    
    Category {
        uuid id PK
        string name
        string slug
        uuid parentId FK
    }
    
    User ||--o{ Booking : makes
    User ||--o{ Review : writes
    Listing ||--o{ Booking : receives
    Listing ||--o{ Review : has
    Listing }o--|| Category : belongs_to
    Category ||--o{ Category : parent_child
```

---

## API Request Flow

```mermaid
flowchart TD
    Start[Client Request] --> Auth{Authenticated?}
    Auth -->|No| Reject[401 Unauthorized]
    Auth -->|Yes| Validate[Validate Request]
    Validate -->|Invalid| BadRequest[400 Bad Request]
    Validate -->|Valid| Controller[Controller]
    Controller --> Service[Service]
    Service --> BusinessLogic[Business Logic]
    BusinessLogic --> DB[(Database)]
    DB --> Response[Response Data]
    Response --> Transform[Transform Data]
    Transform --> Success[200 OK]
```

---

## Deployment Architecture

```mermaid
graph TB
    subgraph "Development"
        Dev[Developer Machine]
    end
    
    subgraph "Version Control"
        Git[Git Repository]
    end
    
    subgraph "CI/CD"
        CI[GitHub Actions<br/>Future]
    end
    
    subgraph "Production Servers"
        Primary[Primary Server<br/>172.16.40.61]
        Backup[Backup Server]
    end
    
    subgraph "Services"
        Docker1[Docker Container<br/>Backend API]
        Docker2[Docker Container<br/>Backend API]
    end
    
    subgraph "Database"
        DB[(PostgreSQL<br/>Remote)]
    end
    
    Dev -->|git push| Git
    Git -->|trigger| CI
    CI -->|deploy| Primary
    CI -->|deploy| Backup
    Primary --> Docker1
    Backup --> Docker2
    Docker1 --> DB
    Docker2 --> DB
```

---

## Security Architecture

```mermaid
graph TB
    subgraph "Security Layers"
        HTTPS[HTTPS/TLS]
        JWT[JWT Authentication]
        RBAC[Role-Based Access]
        Validation[Input Validation]
        Hashing[Password Hashing]
    end
    
    Request[Incoming Request] --> HTTPS
    HTTPS --> JWT
    JWT --> RBAC
    RBAC --> Validation
    Validation --> Hashing
    Hashing --> Process[Process Request]
```

---

## Data Flow - Listing Search

```mermaid
flowchart LR
    User[User] -->|Search Query| Mobile[Mobile App]
    Mobile -->|GET /search?q=query| API[Backend API]
    API -->|Full-text Search| DB[(Database)]
    DB -->|Results| API
    API -->|Rank & Sort| API
    API -->|JSON Response| Mobile
    Mobile -->|Display| User
```

---

## Component Interaction - Booking

```mermaid
graph TD
    Screen[BookingScreen] --> Form[BookingForm]
    Form --> Service[BookingsService]
    Service --> Provider[bookingsProvider]
    Provider --> API[POST /bookings]
    API --> Success[Success Response]
    Success --> Navigation[Navigate to Confirmation]
```

---

## Module Dependencies

```mermaid
graph TD
    Auth[Auth Module] --> Users[Users Module]
    Listings[Listings Module] --> Categories[Categories Module]
    Bookings[Bookings Module] --> Listings
    Bookings --> Users
    Reviews[Reviews Module] --> Listings
    Reviews --> Users
    Favorites[Favorites Module] --> Listings
    Favorites --> Users
```

---

## Error Handling Flow

```mermaid
flowchart TD
    Request[API Request] --> Try{Try}
    Try -->|Success| Success[200 OK]
    Try -->|Error| Catch[Catch Error]
    Catch --> Type{Error Type}
    Type -->|400| Validation[Validation Error]
    Type -->|401| Auth[Auth Error]
    Type -->|404| NotFound[Not Found]
    Type -->|500| Server[Server Error]
    Validation --> Log[Log Error]
    Auth --> Log
    NotFound --> Log
    Server --> Log
    Log --> Response[Error Response]
    Response --> Client[Client]
```

---

## Token Refresh Flow

```mermaid
sequenceDiagram
    participant C as Client
    participant B as Backend
    
    C->>B: API Request with Access Token
    B->>B: Validate Token
    B-->>C: 401 Unauthorized (expired)
    C->>C: Detect 401
    C->>B: POST /auth/refresh (refreshToken)
    B->>B: Validate Refresh Token
    B-->>C: New Access Token
    C->>C: Update Stored Token
    C->>B: Retry Original Request
    B-->>C: Success Response
```

---

## Database Query Flow

```mermaid
flowchart TD
    Service[Service Method] --> Prisma[Prisma Client]
    Prisma --> Query[Build Query]
    Query --> Validate[Validate Query]
    Validate --> Execute[Execute Query]
    Execute --> DB[(PostgreSQL)]
    DB --> Result[Query Result]
    Result --> Transform[Transform Data]
    Transform --> Return[Return to Service]
```

---

## Mobile State Management Flow

```mermaid
graph LR
    UI[UI Widget] --> Watch[watch Provider]
    Watch --> Provider[Riverpod Provider]
    Provider --> Service[API Service]
    Service --> API[Backend API]
    API --> Response[Response]
    Response --> Provider
    Provider --> State[Update State]
    State --> UI
```

---

## Admin Dashboard Architecture

```mermaid
graph TB
    subgraph "Pages"
        Dashboard[Dashboard Page]
        Listings[Listings Page]
        Bookings[Bookings Page]
    end
    
    subgraph "Components"
        Tables[Data Tables]
        Charts[Charts]
        Forms[Forms]
    end
    
    subgraph "API Client"
        Client[API Client]
    end
    
    Dashboard --> Charts
    Listings --> Tables
    Bookings --> Tables
    Tables --> Client
    Charts --> Client
    Forms --> Client
    Client --> Backend[Backend API]
```

---

## How to View These Diagrams

### GitHub
These diagrams render automatically in GitHub markdown files.

### VS Code
Install the "Markdown Preview Mermaid Support" extension.

### Online
Copy the diagram code to [mermaid.live](https://mermaid.live) to view and export.

### Documentation Tools
- GitBook
- Notion
- Confluence (with Mermaid plugin)

