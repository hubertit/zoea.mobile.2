enum EventStatus {
  draft,
  published,
  cancelled,
  completed,
}

extension EventStatusX on EventStatus {
  String get displayName {
    switch (this) {
      case EventStatus.draft:
        return 'Draft';
      case EventStatus.published:
        return 'Published';
      case EventStatus.cancelled:
        return 'Cancelled';
      case EventStatus.completed:
        return 'Completed';
    }
  }
}

enum EventPrivacy {
  public,
  private,
  inviteOnly,
}

extension EventPrivacyX on EventPrivacy {
  String get displayName {
    switch (this) {
      case EventPrivacy.public:
        return 'Public';
      case EventPrivacy.private:
        return 'Private';
      case EventPrivacy.inviteOnly:
        return 'Invite Only';
    }
  }
}

enum TicketType {
  free,
  paid,
  vip,
  earlyBird,
}

extension TicketTypeX on TicketType {
  String get displayName {
    switch (this) {
      case TicketType.free:
        return 'Free';
      case TicketType.paid:
        return 'Standard';
      case TicketType.vip:
        return 'VIP';
      case TicketType.earlyBird:
        return 'Early Bird';
    }
  }
}

class EventTicket {
  final String id;
  final String name;
  final TicketType type;
  final double price;
  final String currency;
  final int quantity;
  final int sold;
  final String? description;
  final bool isDisabled;
  final String? orderType; // sequential, random

  const EventTicket({
    required this.id,
    required this.name,
    required this.type,
    required this.price,
    this.currency = 'RWF',
    required this.quantity,
    this.sold = 0,
    this.description,
    this.isDisabled = false,
    this.orderType,
  });

  int get available => quantity - sold;
  bool get isSoldOut => available <= 0;
}

class EventAttachment {
  final String id;
  final String url;
  final String? blurhash;
  final String fileType;
  final int? width;
  final int? height;
  final String? medium;
  final String? small;
  final bool isMainFlyer;

  const EventAttachment({
    required this.id,
    required this.url,
    this.blurhash,
    this.fileType = 'image',
    this.width,
    this.height,
    this.medium,
    this.small,
    this.isMainFlyer = false,
  });
}

class EventLocation {
  final String type;
  final double latitude;
  final double longitude;

  const EventLocation({
    this.type = 'Point',
    required this.latitude,
    required this.longitude,
  });

  List<double> get coordinates => [longitude, latitude];
}

class EventContext {
  final String id;
  final String name;
  final String? description;

  const EventContext({
    required this.id,
    required this.name,
    this.description,
  });
}

class Event {
  final String id;
  final String businessId;
  final String name;
  final String description;
  final String? flyerUrl;
  final List<EventAttachment> attachments;
  final DateTime startDate;
  final DateTime endDate;
  final String venue;
  final String? venueAddress;
  final EventLocation? location;
  final EventStatus status;
  final EventPrivacy privacy;
  final List<EventTicket> tickets;
  final int maxAttendance;
  final int attendingCount;
  final EventContext? context;
  final String? category;
  final List<String> tags;
  final bool isOngoing;
  final String? setup; // virtual, in-person, hybrid
  final int likeCount;
  final int commentCount;
  final int shareCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Event({
    required this.id,
    required this.businessId,
    required this.name,
    required this.description,
    this.flyerUrl,
    this.attachments = const [],
    required this.startDate,
    required this.endDate,
    required this.venue,
    this.venueAddress,
    this.location,
    this.status = EventStatus.draft,
    this.privacy = EventPrivacy.public,
    this.tickets = const [],
    this.maxAttendance = 0,
    this.attendingCount = 0,
    this.context,
    this.category,
    this.tags = const [],
    this.isOngoing = false,
    this.setup,
    this.likeCount = 0,
    this.commentCount = 0,
    this.shareCount = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  double get totalRevenue {
    return tickets.fold(0, (sum, t) => sum + (t.price * t.sold));
  }

  int get totalTicketsSold {
    return tickets.fold(0, (sum, t) => sum + t.sold);
  }

  int get totalCapacity {
    return tickets.fold(0, (sum, t) => sum + t.quantity);
  }

  int get availableSpots => maxAttendance > 0 ? maxAttendance - attendingCount : totalCapacity - totalTicketsSold;

  bool get isUpcoming => startDate.isAfter(DateTime.now());
  bool get isPast => endDate.isBefore(DateTime.now());
  bool get isSoldOut => availableSpots <= 0;

  String? get mainFlyerUrl {
    if (flyerUrl != null) return flyerUrl;
    final mainFlyer = attachments.where((a) => a.isMainFlyer).firstOrNull;
    return mainFlyer?.url ?? attachments.firstOrNull?.url;
  }
}

class EventAttendee {
  final String id;
  final String eventId;
  final String ticketId;
  final String ticketName;
  final String name;
  final String email;
  final String? phone;
  final bool checkedIn;
  final DateTime? checkedInAt;
  final DateTime purchasedAt;
  final String? qrCode;
  final double amountPaid;
  final String currency;

  const EventAttendee({
    required this.id,
    required this.eventId,
    required this.ticketId,
    this.ticketName = '',
    required this.name,
    required this.email,
    this.phone,
    this.checkedIn = false,
    this.checkedInAt,
    required this.purchasedAt,
    this.qrCode,
    this.amountPaid = 0,
    this.currency = 'RWF',
  });
}

