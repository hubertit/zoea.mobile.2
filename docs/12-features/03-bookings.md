# Booking System Analysis: Dining vs Hotel Bookings

## Executive Summary

This document analyzes the differences and similarities between **Dining (Restaurant) Bookings** and **Hotel (Accommodation) Bookings** in the Zoea app, including UI, API, and database structures.

---

## 1. UI Analysis

### 1.1 Hotel Booking Screen (`accommodation_booking_screen.dart`)

**Key Features:**
- ✅ **Check-in & Check-out dates** (date range selection)
- ✅ **Guest count** (1-10 guests)
- ✅ **Room count** (1-5 rooms)
- ✅ **Selected rooms section** (displays pre-selected room types with quantities)
- ✅ **Price breakdown** (base price × rooms, taxes & fees, total)
- ✅ **Special requests** (optional text field)
- ✅ **Coupon code** (discount application)
- ✅ **Room selection** (if not pre-selected)

**Data Collected:**
- `checkInDate`: DateTime
- `checkOutDate`: DateTime
- `guestCount`: int (1-10)
- `roomCount`: int (1-5)
- `selectedRooms`: Map<String, Map<String, dynamic>> (roomType → {roomType, quantity})
- `specialRequests`: String
- `couponCode`: String
- `discountAmount`: double

**Navigation Flow:**
1. User selects rooms from accommodation detail screen
2. Navigates to booking screen with pre-selected rooms
3. Selects dates, adjusts guest/room count
4. Reviews price breakdown
5. Applies coupon (optional)
6. Submits booking → Payment/Confirmation screen

---

### 1.2 Dining Booking Screen (`dining_booking_screen.dart`)

**Key Features:**
- ✅ **Single date selection** (booking date)
- ✅ **Time slot selection** (available time slots like "12:00 PM", "6:30 PM")
- ✅ **Guest count** (1-20 guests, called "party size")
- ✅ **Contact information** (Full Name, Phone Number, Email Address)
- ✅ **Special requests** (dietary requirements, seating preferences)
- ✅ **Coupon code** (discount application)
- ✅ **Total price display** (bottom bar)

**Data Collected:**
- `selectedDate`: DateTime (single date)
- `selectedTimeSlot`: String (e.g., "12:00 PM", "6:30 PM")
- `guestCount`: int (1-20, called "partySize")
- `fullName`: String
- `contactNumber`: String
- `email`: String
- `specialRequests`: String
- `couponCode`: String
- `discountAmount`: double

**Navigation Flow:**
1. User navigates from restaurant listing
2. Selects date → Time slots appear
3. Selects time slot
4. Enters guest count
5. Fills contact information (required)
6. Adds special requests (optional)
7. Applies coupon (optional)
8. Confirms booking → Shows confirmation modal → Confirmation screen

---

### 1.3 Key UI Differences

| Feature | Hotel Booking | Dining Booking |
|---------|--------------|----------------|
| **Date Selection** | Check-in & Check-out (date range) | Single booking date |
| **Time Selection** | ❌ Not required | ✅ Required (time slots) |
| **Room Selection** | ✅ Required (room types & quantities) | ❌ Not applicable |
| **Guest Count** | 1-10 guests | 1-20 guests (party size) |
| **Contact Info** | ❌ Not collected (uses logged-in user) | ✅ Required (Full Name, Phone, Email) |
| **Price Calculation** | Base price × rooms + taxes | Base price × guests - discount |
| **Pre-selection** | ✅ Rooms can be pre-selected | ❌ No pre-selection |

---

## 2. API Analysis

### 2.1 Backend Endpoints

**Base Endpoint:** `/api/bookings` (Note: Controller uses `/bookings`, not `/booking`)

**Common Endpoints:**
- `GET /api/bookings` - Get my bookings (supports `type` filter: 'hotel', 'restaurant', 'event', 'tour')
- `GET /api/bookings/upcoming` - Get upcoming bookings
- `GET /api/bookings/:id` - Get booking details
- `POST /api/bookings` - Create booking
- `PUT /api/bookings/:id` - Update booking
- `POST /api/bookings/:id/cancel` - Cancel booking
- `POST /api/bookings/:id/confirm-payment` - Confirm payment

**All endpoints require JWT authentication.**

---

### 2.2 Create Booking DTO (`CreateBookingDto`)

**Common Fields:**
```typescript
{
  bookingType: 'hotel' | 'restaurant' | 'event' | 'tour',
  guestCount?: number,
  adults?: number,
  children?: number,
  specialRequests?: string,
  guests?: BookingGuestDto[]
}
```

**Hotel-Specific Fields:**
```typescript
{
  listingId: string,        // Required for hotel
  roomTypeId?: string,      // Optional: specific room type
  checkInDate?: string,     // Required: ISO date string
  checkOutDate?: string,    // Required: ISO date string
}
```

**Restaurant-Specific Fields:**
```typescript
{
  listingId: string,        // Required for restaurant
  tableId?: string,         // Optional: specific table
  bookingDate?: string,     // Required: ISO date string
  bookingTime?: string,     // Required: Time string (e.g., "19:00")
  partySize?: number,       // Alternative to guestCount
}
```

**Note:** The DTO uses `bookingType` to determine which fields are required.

---

### 2.3 API Request Examples

**Hotel Booking:**
```json
POST /api/bookings
{
  "bookingType": "hotel",
  "listingId": "uuid-here",
  "roomTypeId": "uuid-here",  // Optional
  "checkInDate": "2025-12-01",
  "checkOutDate": "2025-12-05",
  "guestCount": 2,
  "adults": 2,
  "children": 0,
  "specialRequests": "Late checkout requested",
  "guests": [
    {
      "fullName": "John Doe",
      "email": "john@example.com",
      "phone": "+250788000000",
      "isPrimary": true
    }
  ]
}
```

**Restaurant Booking:**
```json
POST /api/bookings
{
  "bookingType": "restaurant",
  "listingId": "uuid-here",
  "tableId": "uuid-here",  // Optional
  "bookingDate": "2025-12-01",
  "bookingTime": "19:00",
  "partySize": 4,
  "guestCount": 4,
  "specialRequests": "Window seat preferred",
  "guests": [
    {
      "fullName": "Jane Smith",
      "email": "jane@example.com",
      "phone": "+250788111111",
      "isPrimary": true
    }
  ]
}
```

---

## 3. Database Schema Analysis

### 3.1 Booking Model (`Booking`)

**Common Fields:**
- `id`: UUID (primary key)
- `bookingNumber`: String (unique, auto-generated)
- `userId`: UUID (foreign key to User)
- `bookingType`: enum ('hotel', 'restaurant', 'tour', 'event', 'experience')
- `status`: enum ('pending', 'confirmed', 'checked_in', 'completed', 'cancelled', 'no_show', 'refunded')
- `guestCount`: Int (default: 1)
- `adults`: Int (default: 1)
- `children`: Int (default: 0)
- `subtotal`: Decimal
- `taxAmount`: Decimal
- `discountAmount`: Decimal
- `totalAmount`: Decimal
- `currency`: String (default: "RWF")
- `paymentStatus`: enum
- `paymentMethod`: enum
- `specialRequests`: String
- `createdAt`: DateTime
- `updatedAt`: DateTime

**Hotel-Specific Fields:**
- `listingId`: UUID (foreign key to Listing)
- `roomTypeId`: UUID (foreign key to RoomType)
- `roomId`: UUID (foreign key to Room - specific room assigned)
- `checkInDate`: Date
- `checkOutDate`: Date

**Restaurant-Specific Fields:**
- `listingId`: UUID (foreign key to Listing)
- `tableId`: UUID (foreign key to RestaurantTable)
- `time_slot_id`: UUID (foreign key to reservation_time_slots)
- `bookingDate`: Date
- `bookingTime`: Time
- `partySize`: Int

**Other Type-Specific Fields:**
- `eventId`: UUID (for event bookings)
- `tourId`: UUID (for tour bookings)
- `tourScheduleId`: UUID (for tour bookings)
- `ticketId`: UUID (for event bookings)
- `ticketQuantity`: Int (for event bookings)

---

### 3.2 BookingGuest Model

**Fields:**
- `id`: UUID
- `bookingId`: UUID (foreign key to Booking)
- `fullName`: String
- `email`: String (optional)
- `phone`: String (optional)
- `isPrimary`: Boolean (default: false)
- `idType`: String (optional)
- `idNumber`: String (optional)
- `nationality`: String (optional)

**Note:** Guests are stored separately and linked to bookings via `bookingId`. This allows multiple guests per booking.

---

## 4. Similarities

### 4.1 Common Features
1. ✅ **Both require listing selection** (`listingId`)
2. ✅ **Both support guest count** (`guestCount` or `partySize`)
3. ✅ **Both support special requests** (`specialRequests`)
4. ✅ **Both support coupon codes** (handled via `discountAmount`)
5. ✅ **Both use same booking status flow** (pending → confirmed → completed/cancelled)
6. ✅ **Both support payment confirmation** (`confirm-payment` endpoint)
7. ✅ **Both can have multiple guests** (`BookingGuest[]` array)
8. ✅ **Both use same currency** (RWF by default)

### 4.2 Common API Patterns
- Same authentication (JWT required)
- Same query parameters for filtering (`status`, `type`, `page`, `limit`)
- Same cancellation flow (`POST /bookings/:id/cancel`)
- Same payment confirmation (`POST /bookings/:id/confirm-payment`)

---

## 5. Differences

### 5.1 Date/Time Handling

| Aspect | Hotel | Restaurant |
|--------|-------|------------|
| **Date Field** | `checkInDate` + `checkOutDate` | `bookingDate` (single date) |
| **Time Field** | ❌ Not used | ✅ `bookingTime` (required) |
| **Date Range** | ✅ Yes (check-in to check-out) | ❌ No (single date) |
| **Duration** | Calculated from date range | Single time slot |

### 5.2 Resource Selection

| Aspect | Hotel | Restaurant |
|--------|-------|------------|
| **Room Selection** | ✅ Required (`roomTypeId`, `roomId`) | ❌ Not applicable |
| **Table Selection** | ❌ Not applicable | ✅ Optional (`tableId`) |
| **Time Slot** | ❌ Not applicable | ✅ Optional (`time_slot_id`) |

### 5.3 Contact Information

| Aspect | Hotel | Restaurant |
|--------|-------|------------|
| **Contact Collection** | Uses logged-in user's info | ✅ Collects in UI (Full Name, Phone, Email) |
| **Guest Info** | Stored in `BookingGuest[]` | Stored in `BookingGuest[]` + UI fields |

**Note:** Both store guest information in `BookingGuest[]`, but restaurant booking UI explicitly collects contact info, while hotel booking relies on the logged-in user.

### 5.4 Price Calculation

| Aspect | Hotel | Restaurant |
|--------|-------|------------|
| **Base Price** | Room price × number of rooms × nights | Per person × number of guests |
| **Duration Factor** | ✅ Yes (nights) | ❌ No (single meal) |
| **Room Types** | ✅ Multiple room types supported | ❌ Not applicable |

---

## 6. Implementation Recommendations

### 6.1 Service Structure

**Option 1: Single Unified Service (Recommended)**
```dart
class BookingsService {
  // Common methods
  Future<Map<String, dynamic>> getBookings({...});
  Future<Map<String, dynamic>> getBooking(String id);
  Future<Map<String, dynamic>> cancelBooking(String id, String? reason);
  Future<Map<String, dynamic>> confirmPayment(String id, ...);
  
  // Type-specific create methods
  Future<Map<String, dynamic>> createHotelBooking({
    required String listingId,
    required DateTime checkInDate,
    required DateTime checkOutDate,
    String? roomTypeId,
    int guestCount = 1,
    int adults = 1,
    int children = 0,
    String? specialRequests,
    List<BookingGuest>? guests,
  });
  
  Future<Map<String, dynamic>> createRestaurantBooking({
    required String listingId,
    required DateTime bookingDate,
    required String bookingTime,  // "19:00" format
    required int partySize,
    String? tableId,
    String? timeSlotId,
    String? fullName,
    String? contactNumber,
    String? email,
    String? specialRequests,
    List<BookingGuest>? guests,
  });
}
```

**Option 2: Separate Services**
- `HotelBookingsService` - Hotel-specific logic
- `RestaurantBookingsService` - Restaurant-specific logic
- `BookingsService` - Common operations

**Recommendation:** Use **Option 1** (unified service) because:
- Most operations are shared
- Backend uses single endpoint with `bookingType` discriminator
- Easier to maintain and test
- Type-specific methods provide clear API

---

### 6.2 UI Integration Strategy

**1. Hotel Booking Flow:**
```dart
// In accommodation_booking_screen.dart
void _submitBooking() async {
  final booking = await bookingsService.createHotelBooking(
    listingId: widget.accommodationId,
    checkInDate: _checkInDate!,
    checkOutDate: _checkOutDate!,
    roomTypeId: _selectedRoomTypeId,
    guestCount: _guestCount,
    adults: _adults,
    children: _children,
    specialRequests: _specialRequests,
    guests: _buildGuestList(),
  );
  
  // Navigate to payment/confirmation
  context.push('/booking-confirmation/${booking['id']}');
}
```

**2. Restaurant Booking Flow:**
```dart
// In dining_booking_screen.dart
void _confirmBooking() async {
  final booking = await bookingsService.createRestaurantBooking(
    listingId: widget.placeId,
    bookingDate: _selectedDate!,
    bookingTime: _selectedTimeSlot!,  // "19:00" format
    partySize: _guestCount,
    tableId: _selectedTableId,
    fullName: _fullName,
    contactNumber: _contactNumber,
    email: _email,
    specialRequests: _specialRequests,
    guests: _buildGuestList(),
  );
  
  // Navigate to confirmation
  context.push('/dining-booking-confirmation/${booking['id']}');
}
```

---

### 6.3 Data Model Updates

**Update `Booking` model to match backend:**
```dart
class Booking {
  final String id;
  final String? bookingNumber;
  final String userId;
  final String? listingId;
  final BookingType type;
  final BookingStatus status;
  
  // Hotel fields
  final DateTime? checkInDate;
  final DateTime? checkOutDate;
  final String? roomTypeId;
  final String? roomId;
  
  // Restaurant fields
  final DateTime? bookingDate;
  final String? bookingTime;  // "19:00" format
  final String? tableId;
  final String? timeSlotId;
  final int? partySize;
  
  // Common fields
  final int guestCount;
  final int? adults;
  final int? children;
  final double totalAmount;
  final String currency;
  final PaymentMethod? paymentMethod;
  final String? specialRequests;
  final List<BookingGuest> guests;
  final DateTime createdAt;
  final DateTime updatedAt;
}
```

---

### 6.4 Error Handling

**Common Error Scenarios:**
1. **Date conflicts** (hotel: room not available for dates, restaurant: time slot taken)
2. **Capacity exceeded** (hotel: no rooms available, restaurant: table full)
3. **Invalid time slot** (restaurant: time slot not available)
4. **Payment failures** (both)
5. **Cancellation policies** (both)

**Handle in service:**
```dart
try {
  final booking = await createHotelBooking(...);
} on DioException catch (e) {
  if (e.response?.statusCode == 400) {
    // Handle validation errors (date conflicts, capacity, etc.)
    final message = e.response?.data['message'];
    // Show user-friendly error
  } else if (e.response?.statusCode == 409) {
    // Handle conflicts (room/time slot unavailable)
  }
}
```

---

## 7. Key Takeaways

### 7.1 Must Handle Differently
1. ✅ **Date fields**: Hotel uses `checkInDate`/`checkOutDate`, Restaurant uses `bookingDate` + `bookingTime`
2. ✅ **Time selection**: Restaurant requires time slot selection, Hotel does not
3. ✅ **Resource selection**: Hotel selects rooms, Restaurant selects tables/time slots
4. ✅ **Contact info**: Restaurant collects in UI, Hotel uses logged-in user

### 7.2 Can Share
1. ✅ **API endpoints**: Same endpoints with `bookingType` discriminator
2. ✅ **Booking status flow**: Same status management
3. ✅ **Payment flow**: Same payment confirmation
4. ✅ **Cancellation**: Same cancellation endpoint
5. ✅ **Guest management**: Same `BookingGuest[]` structure

### 7.3 Implementation Priority
1. **Phase 1**: Create unified `BookingsService` with type-specific create methods
2. **Phase 2**: Integrate hotel booking screen with API
3. **Phase 3**: Integrate restaurant booking screen with API
4. **Phase 4**: Add error handling and validation
5. **Phase 5**: Add payment integration

---

## 8. Next Steps

1. ✅ Create `BookingsService` with unified API
2. ✅ Update `Booking` model to match backend schema
3. ✅ Integrate hotel booking screen
4. ✅ Integrate restaurant booking screen
5. ✅ Add proper error handling
6. ✅ Test both booking flows end-to-end

