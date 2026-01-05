# Ask Zoea - AI Assistant Implementation

## Overview
"Ask Zoea" is an AI-powered chatbot feature that helps users discover places, tours, products, and services in Rwanda. It uses OpenAI's GPT-4 with function calling to provide natural, conversational responses grounded in the app's internal data.

## Implementation Date
January 2, 2026

---

## Backend Implementation

### 1. Database Schema

#### New Tables Created:
- **`integrations`** - Stores API keys and configurations for external services
  - Fields: `id`, `name`, `display_name`, `description`, `is_active`, `config`, `created_at`, `updated_at`
  - Indexes: `name` (unique), `is_active`

- **`assistant_conversations`** - Stores chat conversations
  - Fields: `id`, `user_id`, `title`, `created_at`, `last_message_at`
  - Indexes: `user_id + last_message_at`, `created_at`
  - Retention: 90 days (auto-cleanup via cron)

- **`assistant_messages`** - Stores individual messages
  - Fields: `id`, `conversation_id`, `role` (user/assistant), `text`, `created_at`
  - Indexes: `conversation_id + created_at`

- **`assistant_message_cards`** - Stores clickable content cards
  - Fields: `id`, `message_id`, `type` (listing/tour/product/service), `entity_id`, `title`, `subtitle`, `image_url`, `route`, `params`, `created_at`
  - Indexes: `message_id`

### 2. Backend Modules

#### Integrations Module (`/backend/src/modules/integrations/`)
- **Purpose**: Manage API keys and external service configurations
- **Files**:
  - `integrations.module.ts`
  - `integrations.service.ts`
  - `integrations.controller.ts`
  - `dto/integration.dto.ts`
- **Endpoints**:
  - `GET /api/integrations` - List all integrations
  - `GET /api/integrations/:name` - Get specific integration
  - `POST /api/integrations` - Create integration
  - `PATCH /api/integrations/:name` - Update integration
  - `DELETE /api/integrations/:name` - Delete integration

#### Assistant Module (`/backend/src/modules/assistant/`)
- **Purpose**: Handle AI chat functionality
- **Files**:
  - `assistant.module.ts`
  - `assistant.service.ts` - Main service for conversation management
  - `assistant.controller.ts` - API endpoints
  - `content-search.service.ts` - Search across all content types
  - `openai.service.ts` - OpenAI integration with function calling
  - `assistant.cron.ts` - Cleanup old conversations (90+ days)
  - `dto/chat.dto.ts`

- **Endpoints**:
  - `POST /api/assistant/chat` - Send a message and get AI response
  - `GET /api/assistant/conversations` - Get user's conversations
  - `GET /api/assistant/conversations/:id/messages` - Get conversation messages
  - `DELETE /api/assistant/conversations/:id` - Delete conversation

### 3. Content Search Service

The `ContentSearchService` is the core "tool" that the AI uses to search internal data:

- **Searchable Content Types**:
  - Listings (restaurants, hotels, attractions)
  - Tours (experiences, adventures)
  - Products (items for sale)
  - Services (bookable services)
  - ❌ Events (excluded - from external partner)

- **Search Features**:
  - Full-text search across names and descriptions
  - Tag-based search
  - Location-based search (when user asks "near me")
  - Category filtering
  - Sorting by rating and featured status

### 4. OpenAI Integration

- **Model**: GPT-4 Turbo Preview
- **Function Calling**: Two tools available to AI:
  1. `searchContent` - Search for places, tours, products, services
  2. `getCategories` - Get all available categories

- **System Prompt**: Configured for friendly, short, human-like responses
- **Response Flow**:
  1. User sends message
  2. AI decides if it needs to call a function
  3. If yes, function is executed and results are returned
  4. AI generates natural response with results
  5. Backend saves message + cards
  6. Frontend displays message with clickable cards

### 5. Cron Jobs

- **Conversation Cleanup**: Runs daily at 2 AM
  - Deletes conversations older than 90 days
  - Cascading delete removes all messages and cards

### 6. Configuration

**OpenAI Integration** (in database):
```json
{
  "name": "openai",
  "displayName": "OpenAI",
  "isActive": true,
  "config": {
    "apiKey": "sk-proj-...",
    "model": "gpt-4-turbo-preview",
    "maxTokens": 1000,
    "temperature": 0.7
  }
}
```

**Visit Rwanda Integration** (placeholder for future):
```json
{
  "name": "visit_rwanda",
  "displayName": "Visit Rwanda Events",
  "isActive": false,
  "config": {
    "eventsUrl": "",
    "syncInterval": 3600,
    "lastSyncAt": null
  }
}
```

---

## Mobile Implementation

### 1. New Screens

#### Ask Zoea Screen (`/mobile/lib/features/assistant/screens/ask_zoea_screen.dart`)
- **Location**: 5th tab in bottom navigation
- **Features**:
  - Chat interface with user and assistant messages
  - Clickable content cards (listings, tours, products, services)
  - Typing indicator while AI is thinking
  - Suggested prompts (3 suggestions at a time)
  - Conversation history modal
  - Empty state with welcome message
  - Auto-scroll to latest message
  - Error handling

#### Tour Detail Screen (`/mobile/lib/features/explore/screens/tour_detail_screen.dart`)
- **Purpose**: Display full tour details before booking
- **Features**:
  - Image header with favorite button
  - Tour information (duration, difficulty, price, group size)
  - About section
  - What's included/excluded
  - Requirements
  - Available languages
  - "Book Now" button

### 2. Services & Providers

#### Assistant Service (`/mobile/lib/core/services/assistant_service.dart`)
- Methods:
  - `sendMessage()` - Send chat message with optional location
  - `getConversations()` - Get conversation list
  - `getMessages()` - Get messages for a conversation
  - `deleteConversation()` - Delete a conversation

#### Assistant Provider (`/mobile/lib/core/providers/assistant_provider.dart`)
- `assistantServiceProvider` - Service instance
- `conversationsProvider` - Async list of conversations
- `conversationMessagesProvider` - Async messages for a conversation

### 3. Navigation Updates

#### Shell Widget (`/mobile/lib/core/widgets/shell.dart`)
- Added 5th tab: "Ask Zoea" with smart_toy icon
- Updated navigation logic to handle 5 tabs
- Route: `/ask-zoea`

#### Router (`/mobile/lib/core/router/app_router.dart`)
- Added `/ask-zoea` route
- Added `/tour/:id` route for tour details
- Updated experiences screen to navigate to tour detail instead of directly to booking

### 4. UI/UX Features

**Chat Interface**:
- User messages: Right-aligned, primary color background
- Assistant messages: Left-aligned, card background
- Bot avatar: Smart toy icon in circle
- Message cards: Clickable with image, title, subtitle, and chevron

**Content Cards**:
- Support for 4 types: listing, tour, product, service
- Each card navigates to the appropriate detail screen
- Images loaded with caching
- Fallback icons when no image available

**Suggestions**:
- Displayed as chips below the chat
- Updated dynamically based on AI response
- Initial suggestions: "Show me popular places", "Find restaurants in Kigali", "What tours are available?"

**Empty State**:
- Friendly welcome message
- Bot avatar
- Suggested prompts as buttons

---

## Testing Checklist

### Backend
- [x] Backend compiles successfully
- [x] Server starts without errors
- [x] OpenAI initializes with API key
- [x] All assistant endpoints registered
- [x] Database tables created
- [x] Integrations seeded
- [ ] Test `/api/assistant/chat` endpoint
- [ ] Test content search functionality
- [ ] Test conversation management
- [ ] Test cron job (manual trigger)

### Mobile
- [x] No linter errors
- [x] All imports resolved
- [x] Router configured correctly
- [x] Shell navigation updated
- [ ] Test Ask Zoea tab navigation
- [ ] Test chat interface
- [ ] Test sending messages
- [ ] Test clickable cards
- [ ] Test tour detail screen
- [ ] Test conversation history
- [ ] Test error handling

### Integration
- [ ] End-to-end: Send message → Get AI response → Click card → Navigate to detail
- [ ] Test "near me" functionality with location
- [ ] Test conversation persistence
- [ ] Test 90-day retention
- [ ] Test with different content types (listings, tours, products, services)

---

## API Examples

### Send a Chat Message
```bash
POST /api/assistant/chat
Authorization: Bearer <token>
Content-Type: application/json

{
  "message": "Find 5 restaurants in Kigali",
  "conversationId": "optional-uuid",
  "location": {
    "lat": -1.9403,
    "lng": 30.0644
  }
}
```

**Response**:
```json
{
  "conversationId": "uuid",
  "assistantMessage": {
    "id": "uuid",
    "text": "Here are 5 great restaurants in Kigali! Any specific cuisine or budget in mind?",
    "createdAt": "2026-01-02T09:00:00Z"
  },
  "cards": [
    {
      "type": "listing",
      "id": "uuid",
      "title": "Heaven Restaurant",
      "subtitle": "Kigali • Restaurant",
      "imageUrl": "https://...",
      "route": "/listing/:id",
      "params": { "id": "uuid" }
    }
  ],
  "suggestions": [
    "Show me more options",
    "Filter by price",
    "What's nearby?"
  ]
}
```

---

## Architecture Decisions

1. **Backend-Proxy for OpenAI**: All OpenAI calls go through the backend to:
   - Secure API keys
   - Control costs and usage
   - Enable function calling with internal data
   - Log conversations for debugging

2. **Function Calling vs RAG**: Used OpenAI's function calling instead of RAG because:
   - Real-time data access
   - No need to maintain vector embeddings
   - Simpler implementation
   - Direct database queries

3. **90-Day Retention**: Balances:
   - User privacy
   - Storage costs
   - Useful history for returning users

4. **Clickable Cards Only for Internal Content**: External recommendations (from OpenAI's knowledge) are text-only to avoid confusion and maintain quality control.

5. **Separate Tour Detail Screen**: Created dedicated screen instead of reusing booking screen for better UX and separation of concerns.

---

## Future Enhancements

1. **Voice Input**: Add speech-to-text for voice messages
2. **Multi-language**: Support Kinyarwanda, French, Swahili
3. **Conversation Sharing**: Share chat conversations with friends
4. **Saved Recommendations**: Bookmark specific AI recommendations
5. **Visit Rwanda Events Sync**: Implement external events integration
6. **Advanced Filters**: Allow users to specify budget, distance, ratings in natural language
7. **Image Upload**: "Find places like this" with image recognition
8. **Itinerary Builder**: "Plan a 3-day trip to Rwanda"
9. **Analytics**: Track popular queries, successful recommendations, conversion rates

---

## Files Changed/Created

### Backend
**New Files**:
- `backend/src/modules/integrations/*` (module, service, controller, DTOs)
- `backend/src/modules/assistant/*` (module, service, controller, DTOs, cron)
- `backend/add_assistant_tables.sql`
- `backend/prisma/seed-integrations.ts`

**Modified Files**:
- `backend/prisma/schema.prisma` - Added 4 new models
- `backend/src/app.module.ts` - Imported new modules
- `backend/src/modules/tours/tours.controller.ts` - Fixed parameter order
- `backend/package.json` - Added `openai` and `@nestjs/schedule`

### Mobile
**New Files**:
- `mobile/lib/features/assistant/screens/ask_zoea_screen.dart`
- `mobile/lib/features/explore/screens/tour_detail_screen.dart`
- `mobile/lib/core/services/assistant_service.dart`
- `mobile/lib/core/providers/assistant_provider.dart`

**Modified Files**:
- `mobile/lib/core/router/app_router.dart` - Added routes
- `mobile/lib/core/widgets/shell.dart` - Added 5th tab
- `mobile/lib/features/explore/screens/experiences_screen.dart` - Updated navigation

---

## Deployment Notes

1. **Environment Variables**: Ensure `DATABASE_URL` is set correctly
2. **Database Migration**: Run SQL script to create tables
3. **Seed Integrations**: Run seed script or manually insert OpenAI config
4. **API Key Security**: Never commit API keys to version control
5. **Rate Limiting**: Consider adding rate limits to `/api/assistant/chat` endpoint
6. **Monitoring**: Set up alerts for OpenAI API failures and high token usage
7. **Backup**: Regular backups of `assistant_conversations` table

---

## Support & Maintenance

**Monitoring**:
- OpenAI API usage and costs
- Average response time
- Error rates
- Popular queries
- Conversation completion rates

**Maintenance Tasks**:
- Review and update system prompt monthly
- Analyze failed queries and improve content search
- Update OpenAI model as new versions release
- Monitor and adjust conversation retention period
- Review and moderate inappropriate content

---

## Credits

**Implementation**: AI Assistant (Claude Sonnet 4.5)
**Date**: January 2, 2026
**Project**: Zoea Africa v2
**Feature**: Ask Zoea - AI-Powered Rwanda Guide

