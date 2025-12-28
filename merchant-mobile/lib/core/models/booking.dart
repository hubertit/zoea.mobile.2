/// Booking model - Bookings made by customers for merchant listings
/// Booking fields vary based on business/listing type
class Booking {
  final String id;
  final String listingId;
  final String businessId;
  final String customerId;
  final String customerName;
  final String? customerEmail;
  final String? customerPhone;
  final BookingType type;
  final BookingStatus status;
  final double totalAmount;
  final String currency;
  final PaymentMethod paymentMethod;
  final PaymentStatus paymentStatus;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? specialRequests;
  final String? listingName;
  final String? businessName;

  // Type-specific booking details
  final AccommodationBookingDetails? accommodationDetails;
  final DiningBookingDetails? diningDetails;
  final TourBookingDetails? tourDetails;
  final EventBookingDetails? eventDetails;

  const Booking({
    required this.id,
    required this.listingId,
    required this.businessId,
    required this.customerId,
    required this.customerName,
    this.customerEmail,
    this.customerPhone,
    required this.type,
    required this.status,
    required this.totalAmount,
    required this.currency,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.createdAt,
    required this.updatedAt,
    this.specialRequests,
    this.listingName,
    this.businessName,
    this.accommodationDetails,
    this.diningDetails,
    this.tourDetails,
    this.eventDetails,
  });

  // Convenience getters
  int get guestCount {
    switch (type) {
      case BookingType.accommodation:
        return accommodationDetails?.guestCount ?? 1;
      case BookingType.dining:
        return diningDetails?.partySize ?? 1;
      case BookingType.tour:
        return tourDetails?.participants ?? 1;
      case BookingType.event:
        return eventDetails?.ticketCount ?? 1;
    }
  }

  DateTime get bookingDate {
    switch (type) {
      case BookingType.accommodation:
        return accommodationDetails?.checkInDate ?? createdAt;
      case BookingType.dining:
        return diningDetails?.reservationDate ?? createdAt;
      case BookingType.tour:
        return tourDetails?.tourDate ?? createdAt;
      case BookingType.event:
        return eventDetails?.eventDate ?? createdAt;
    }
  }

  Booking copyWith({
    String? id,
    String? listingId,
    String? businessId,
    String? customerId,
    String? customerName,
    String? customerEmail,
    String? customerPhone,
    BookingType? type,
    BookingStatus? status,
    double? totalAmount,
    String? currency,
    PaymentMethod? paymentMethod,
    PaymentStatus? paymentStatus,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? specialRequests,
    String? listingName,
    String? businessName,
    AccommodationBookingDetails? accommodationDetails,
    DiningBookingDetails? diningDetails,
    TourBookingDetails? tourDetails,
    EventBookingDetails? eventDetails,
  }) {
    return Booking(
      id: id ?? this.id,
      listingId: listingId ?? this.listingId,
      businessId: businessId ?? this.businessId,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      customerEmail: customerEmail ?? this.customerEmail,
      customerPhone: customerPhone ?? this.customerPhone,
      type: type ?? this.type,
      status: status ?? this.status,
      totalAmount: totalAmount ?? this.totalAmount,
      currency: currency ?? this.currency,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      specialRequests: specialRequests ?? this.specialRequests,
      listingName: listingName ?? this.listingName,
      businessName: businessName ?? this.businessName,
      accommodationDetails: accommodationDetails ?? this.accommodationDetails,
      diningDetails: diningDetails ?? this.diningDetails,
      tourDetails: tourDetails ?? this.tourDetails,
      eventDetails: eventDetails ?? this.eventDetails,
    );
  }
}

/// Accommodation booking details (Hotels)
class AccommodationBookingDetails {
  final DateTime checkInDate;
  final DateTime checkOutDate;
  final int nights;
  final int roomCount;
  final int guestCount;
  final String? roomType;
  final TimeOfDay? checkInTime;
  final TimeOfDay? checkOutTime;
  final List<BookingGuest> guests;

  const AccommodationBookingDetails({
    required this.checkInDate,
    required this.checkOutDate,
    required this.nights,
    this.roomCount = 1,
    this.guestCount = 1,
    this.roomType,
    this.checkInTime,
    this.checkOutTime,
    this.guests = const [],
  });
}

/// Dining booking details (Restaurants)
class DiningBookingDetails {
  final DateTime reservationDate;
  final String timeSlot;
  final int partySize;
  final String? tablePreference;
  final String? occasion;
  final bool isHighChairNeeded;

  const DiningBookingDetails({
    required this.reservationDate,
    required this.timeSlot,
    required this.partySize,
    this.tablePreference,
    this.occasion,
    this.isHighChairNeeded = false,
  });
}

/// Tour booking details (Tour Operators)
class TourBookingDetails {
  final DateTime tourDate;
  final int participants;
  final String? pickupLocation;
  final String? pickupTime;
  final List<String> participantNames;
  final String? preferredLanguage;

  const TourBookingDetails({
    required this.tourDate,
    required this.participants,
    this.pickupLocation,
    this.pickupTime,
    this.participantNames = const [],
    this.preferredLanguage,
  });
}

/// Event booking details (Event Venues)
class EventBookingDetails {
  final DateTime eventDate;
  final String ticketType;
  final int ticketCount;
  final List<String> attendeeNames;
  final String? seatPreference;

  const EventBookingDetails({
    required this.eventDate,
    required this.ticketType,
    required this.ticketCount,
    this.attendeeNames = const [],
    this.seatPreference,
  });
}

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
}

// Helper class for TimeOfDay since it's from Flutter
class TimeOfDay {
  final int hour;
  final int minute;

  const TimeOfDay({required this.hour, required this.minute});

  String format() {
    final h = hour.toString().padLeft(2, '0');
    final m = minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}

enum BookingType {
  accommodation,
  dining,
  tour,
  event,
}

extension BookingTypeExtension on BookingType {
  String get displayName {
    switch (this) {
      case BookingType.accommodation:
        return 'Accommodation';
      case BookingType.dining:
        return 'Dining';
      case BookingType.tour:
        return 'Tour';
      case BookingType.event:
        return 'Event';
    }
  }

  String get icon {
    switch (this) {
      case BookingType.accommodation:
        return '🏨';
      case BookingType.dining:
        return '🍽️';
      case BookingType.tour:
        return '🗺️';
      case BookingType.event:
        return '🎫';
    }
  }
}

enum BookingStatus {
  pending,
  confirmed,
  checkedIn,
  completed,
  cancelled,
  noShow,
}

extension BookingStatusExtension on BookingStatus {
  String get displayName {
    switch (this) {
      case BookingStatus.pending:
        return 'Pending';
      case BookingStatus.confirmed:
        return 'Confirmed';
      case BookingStatus.checkedIn:
        return 'Checked In';
      case BookingStatus.completed:
        return 'Completed';
      case BookingStatus.cancelled:
        return 'Cancelled';
      case BookingStatus.noShow:
        return 'No Show';
    }
  }
}

enum PaymentMethod {
  zoeaCard,
  momo,
  bankTransfer,
  cash,
  card,
}

extension PaymentMethodExtension on PaymentMethod {
  String get displayName {
    switch (this) {
      case PaymentMethod.zoeaCard:
        return 'Zoea Card';
      case PaymentMethod.momo:
        return 'Mobile Money';
      case PaymentMethod.bankTransfer:
        return 'Bank Transfer';
      case PaymentMethod.cash:
        return 'Cash';
      case PaymentMethod.card:
        return 'Card';
    }
  }
}

enum PaymentStatus {
  pending,
  paid,
  partiallyPaid,
  refunded,
  failed,
}

extension PaymentStatusExtension on PaymentStatus {
  String get displayName {
    switch (this) {
      case PaymentStatus.pending:
        return 'Pending';
      case PaymentStatus.paid:
        return 'Paid';
      case PaymentStatus.partiallyPaid:
        return 'Partially Paid';
      case PaymentStatus.refunded:
        return 'Refunded';
      case PaymentStatus.failed:
        return 'Failed';
    }
  }
}
