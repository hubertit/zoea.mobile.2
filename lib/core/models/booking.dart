// Booking model for both hotel and restaurant bookings

class Booking {
  final String id;
  final String? bookingNumber;
  final String userId;
  final String? listingId;
  final String? eventId;
  final String? tourId;
  final BookingType type;
  final BookingStatus status;
  
  // Hotel-specific fields
  final DateTime? checkInDate;
  final DateTime? checkOutDate;
  final String? roomTypeId;
  final String? roomId;
  
  // Restaurant-specific fields
  final DateTime? bookingDate;
  final String? bookingTime; // Format: "19:00" (24-hour)
  final String? tableId;
  final String? timeSlotId;
  final int? partySize;
  
  // Common fields
  final int guestCount;
  final int? adults;
  final int? children;
  final double totalAmount;
  final double? subtotal;
  final double? taxAmount;
  final double? discountAmount;
  final String currency;
  final PaymentStatus? paymentStatus;
  final PaymentMethod? paymentMethod;
  final String? specialRequests;
  final List<BookingGuest> guests;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Booking({
    required this.id,
    this.bookingNumber,
    required this.userId,
    this.listingId,
    this.eventId,
    this.tourId,
    required this.type,
    required this.status,
    // Hotel fields
    this.checkInDate,
    this.checkOutDate,
    this.roomTypeId,
    this.roomId,
    // Restaurant fields
    this.bookingDate,
    this.bookingTime,
    this.tableId,
    this.timeSlotId,
    this.partySize,
    // Common fields
    required this.guestCount,
    this.adults,
    this.children,
    required this.totalAmount,
    this.subtotal,
    this.taxAmount,
    this.discountAmount,
    this.currency = 'RWF',
    this.paymentStatus,
    this.paymentMethod,
    this.specialRequests,
    this.guests = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create Booking from API response JSON
  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'] as String,
      bookingNumber: json['bookingNumber'] as String?,
      userId: json['userId'] as String,
      listingId: json['listingId'] as String?,
      eventId: json['eventId'] as String?,
      tourId: json['tourId'] as String?,
      type: _parseBookingType(json['bookingType'] as String? ?? json['type'] as String?),
      status: _parseBookingStatus(json['status'] as String),
      // Hotel fields
      checkInDate: json['checkInDate'] != null 
          ? DateTime.parse(json['checkInDate'] as String)
          : null,
      checkOutDate: json['checkOutDate'] != null
          ? DateTime.parse(json['checkOutDate'] as String)
          : null,
      roomTypeId: json['roomTypeId'] as String?,
      roomId: json['roomId'] as String?,
      // Restaurant fields
      bookingDate: json['bookingDate'] != null
          ? DateTime.parse(json['bookingDate'] as String)
          : null,
      bookingTime: json['bookingTime'] as String?,
      tableId: json['tableId'] as String?,
      timeSlotId: json['timeSlotId'] as String?,
      partySize: json['partySize'] as int?,
      // Common fields
      guestCount: json['guestCount'] as int? ?? 1,
      adults: json['adults'] as int?,
      children: json['children'] as int?,
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
      subtotal: (json['subtotal'] as num?)?.toDouble(),
      taxAmount: (json['taxAmount'] as num?)?.toDouble(),
      discountAmount: (json['discountAmount'] as num?)?.toDouble(),
      currency: json['currency'] as String? ?? 'RWF',
      paymentStatus: json['paymentStatus'] != null
          ? _parsePaymentStatus(json['paymentStatus'] as String)
          : null,
      paymentMethod: json['paymentMethod'] != null
          ? _parsePaymentMethod(json['paymentMethod'] as String)
          : null,
      specialRequests: json['specialRequests'] as String?,
      guests: json['guests'] != null
          ? (json['guests'] as List)
              .map((g) => BookingGuest.fromJson(g as Map<String, dynamic>))
              .toList()
          : [],
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  /// Convert Booking to JSON for API requests
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      if (bookingNumber != null) 'bookingNumber': bookingNumber,
      'userId': userId,
      if (listingId != null) 'listingId': listingId,
      if (eventId != null) 'eventId': eventId,
      if (tourId != null) 'tourId': tourId,
      'bookingType': type.name,
      'status': status.name,
      // Hotel fields
      if (checkInDate != null) 'checkInDate': checkInDate!.toIso8601String().split('T')[0],
      if (checkOutDate != null) 'checkOutDate': checkOutDate!.toIso8601String().split('T')[0],
      if (roomTypeId != null) 'roomTypeId': roomTypeId,
      if (roomId != null) 'roomId': roomId,
      // Restaurant fields
      if (bookingDate != null) 'bookingDate': bookingDate!.toIso8601String().split('T')[0],
      if (bookingTime != null) 'bookingTime': bookingTime,
      if (tableId != null) 'tableId': tableId,
      if (timeSlotId != null) 'timeSlotId': timeSlotId,
      if (partySize != null) 'partySize': partySize,
      // Common fields
      'guestCount': guestCount,
      if (adults != null) 'adults': adults,
      if (children != null) 'children': children,
      'totalAmount': totalAmount,
      if (subtotal != null) 'subtotal': subtotal,
      if (taxAmount != null) 'taxAmount': taxAmount,
      if (discountAmount != null) 'discountAmount': discountAmount,
      'currency': currency,
      if (paymentStatus != null) 'paymentStatus': paymentStatus!.name,
      if (paymentMethod != null) 'paymentMethod': paymentMethod!.name,
      if (specialRequests != null) 'specialRequests': specialRequests,
      if (guests.isNotEmpty) 'guests': guests.map((g) => g.toJson()).toList(),
    };
  }

  static BookingType _parseBookingType(String? type) {
    if (type == null) return BookingType.hotel;
    switch (type.toLowerCase()) {
      case 'hotel':
        return BookingType.hotel;
      case 'restaurant':
        return BookingType.restaurant;
      case 'tour':
        return BookingType.tour;
      case 'event':
        return BookingType.event;
      default:
        return BookingType.hotel;
    }
  }

  static BookingStatus _parseBookingStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return BookingStatus.pending;
      case 'confirmed':
        return BookingStatus.confirmed;
      case 'checked_in':
        return BookingStatus.checkedIn;
      case 'completed':
        return BookingStatus.completed;
      case 'cancelled':
        return BookingStatus.cancelled;
      case 'no_show':
        return BookingStatus.noShow;
      case 'refunded':
        return BookingStatus.refunded;
      default:
        return BookingStatus.pending;
    }
  }

  static PaymentStatus _parsePaymentStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return PaymentStatus.pending;
      case 'paid':
        return PaymentStatus.paid;
      case 'failed':
        return PaymentStatus.failed;
      case 'refunded':
        return PaymentStatus.refunded;
      default:
        return PaymentStatus.pending;
    }
  }

  static PaymentMethod _parsePaymentMethod(String method) {
    switch (method.toLowerCase()) {
      case 'card':
        return PaymentMethod.card;
      case 'momo':
        return PaymentMethod.momo;
      case 'bank_transfer':
        return PaymentMethod.bankTransfer;
      case 'cash':
        return PaymentMethod.cash;
      case 'zoea_card':
        return PaymentMethod.zoeaCard;
      default:
        return PaymentMethod.cash;
    }
  }
}

class BookingGuest {
  final String fullName;
  final String? email;
  final String? phone;
  final bool isPrimary;
  final String? idType;
  final String? idNumber;
  final String? nationality;

  const BookingGuest({
    required this.fullName,
    this.email,
    this.phone,
    this.isPrimary = false,
    this.idType,
    this.idNumber,
    this.nationality,
  });

  factory BookingGuest.fromJson(Map<String, dynamic> json) {
    return BookingGuest(
      fullName: json['fullName'] as String,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      isPrimary: json['isPrimary'] as bool? ?? false,
      idType: json['idType'] as String?,
      idNumber: json['idNumber'] as String?,
      nationality: json['nationality'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      if (email != null) 'email': email,
      if (phone != null) 'phone': phone,
      'isPrimary': isPrimary,
      if (idType != null) 'idType': idType,
      if (idNumber != null) 'idNumber': idNumber,
      if (nationality != null) 'nationality': nationality,
    };
  }
}

enum BookingType {
  hotel,
  restaurant,
  tour,
  event,
}

enum BookingStatus {
  pending,
  confirmed,
  checkedIn,
  completed,
  cancelled,
  noShow,
  refunded,
}

enum PaymentStatus {
  pending,
  paid,
  failed,
  refunded,
}

enum PaymentMethod {
  card,
  momo,
  bankTransfer,
  cash,
  zoeaCard,
}
