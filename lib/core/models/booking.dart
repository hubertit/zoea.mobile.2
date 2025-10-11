// 

// 

// // @JsonSerializable()
class Booking {
  final String id;
  final String userId;
  final String listingId;
  final BookingType type;
  final BookingStatus status;
  final DateTime checkInDate;
  final DateTime checkOutDate;
  final int guestCount;
  final double totalAmount;
  final String currency;
  final PaymentMethod paymentMethod;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? specialRequests;
  final List<BookingGuest> guests;

  const Booking({
    required this.id,
    required this.userId,
    required this.listingId,
    required this.type,
    required this.status,
    required this.checkInDate,
    required this.checkOutDate,
    required this.guestCount,
    required this.totalAmount,
    required this.currency,
    required this.paymentMethod,
    required this.createdAt,
    required this.updatedAt,
    this.specialRequests,
    this.guests = const [],
  });

  // factory Booking.fromJson(Map<String, dynamic> json) => _$BookingFromJson(json);
  // // Map<String, dynamic> toJson() => _$BookingToJson(this);
}

// // @JsonSerializable()
class BookingGuest {
  final String firstName;
  final String lastName;
  final String? email;
  final String? phoneNumber;
  final bool isPrimary;

  const BookingGuest({
    required this.firstName,
    required this.lastName,
    this.email,
    this.phoneNumber,
    this.isPrimary = false,
  });

  // factory BookingGuest.fromJson(Map<String, dynamic> json) => _$BookingGuestFromJson(json);
  // // Map<String, dynamic> toJson() => _$BookingGuestToJson(this);
}

enum BookingType {
  // // @JsonValue('hotel')
  hotel,
  // // @JsonValue('restaurant')
  restaurant,
  // // @JsonValue('tour')
  tour,
  // // @JsonValue('event')
  event,
}

enum BookingStatus {
  // // @JsonValue('pending')
  pending,
  // // @JsonValue('confirmed')
  confirmed,
  // // @JsonValue('cancelled')
  cancelled,
  // // @JsonValue('completed')
  completed,
  // // @JsonValue('refunded')
  refunded,
}

enum PaymentMethod {
  // // @JsonValue('zoea_card')
  zoeaCard,
  // // @JsonValue('momo')
  momo,
  // // @JsonValue('bank_transfer')
  bankTransfer,
  // // @JsonValue('cash')
  cash,
}
