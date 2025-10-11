class Event {
  final int id;
  final int eventId;
  final int userId;
  final int creatorId;
  final bool isBlocked;
  final String slug;
  final int organizerProfileId;
  final String type;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String commentCount;
  final String likeCount;
  final String sincCount;
  final bool hasLiked;
  final EventDetails event;
  final EventOwner owner;

  const Event({
    required this.id,
    required this.eventId,
    required this.userId,
    required this.creatorId,
    required this.isBlocked,
    required this.slug,
    required this.organizerProfileId,
    required this.type,
    required this.createdAt,
    required this.updatedAt,
    required this.commentCount,
    required this.likeCount,
    required this.sincCount,
    required this.hasLiked,
    required this.event,
    required this.owner,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'] ?? 0,
      eventId: json['EventId'] ?? 0,
      userId: json['userId'] ?? 0,
      creatorId: json['creatorId'] ?? 0,
      isBlocked: json['isBlocked'] ?? false,
      slug: json['slug'] ?? '',
      organizerProfileId: json['OrganizerProfileId'] ?? 0,
      type: json['type'] ?? '',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
      commentCount: json['commentcount'] ?? '0',
      likeCount: json['likecount'] ?? '0',
      sincCount: json['sinccount'] ?? '0',
      hasLiked: json['hasLiked'] ?? false,
      event: EventDetails.fromJson(json['Event'] ?? {}),
      owner: EventOwner.fromJson(json['owner'] ?? {}),
    );
  }
}

class EventDetails {
  final int id;
  final int userId;
  final String name;
  final String description;
  final int organizerProfileId;
  final String flyer;
  final int imageId;
  final int fileId;
  final EventLocation location;
  final String locationName;
  final bool isAcceptable;
  final int eventContextId;
  final int maxAttendance;
  final int attending;
  final DateTime startDate;
  final DateTime endDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String setup;
  final String privacy;
  final int postId;
  final bool ongoing;
  final List<EventTicket> tickets;
  final List<EventAttachment> attachments;
  final EventContext? eventContext;

  const EventDetails({
    required this.id,
    required this.userId,
    required this.name,
    required this.description,
    required this.organizerProfileId,
    required this.flyer,
    required this.imageId,
    required this.fileId,
    required this.location,
    required this.locationName,
    required this.isAcceptable,
    required this.eventContextId,
    required this.maxAttendance,
    required this.attending,
    required this.startDate,
    required this.endDate,
    required this.createdAt,
    required this.updatedAt,
    required this.setup,
    required this.privacy,
    required this.postId,
    required this.ongoing,
    required this.tickets,
    required this.attachments,
    this.eventContext,
  });

  factory EventDetails.fromJson(Map<String, dynamic> json) {
    return EventDetails(
      id: json['id'] ?? 0,
      userId: json['userId'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      organizerProfileId: json['OrganizerProfileId'] ?? 0,
      flyer: json['flyer'] ?? '',
      imageId: json['imageId'] ?? 0,
      fileId: json['fileId'] ?? 0,
      location: EventLocation.fromJson(json['location'] ?? {}),
      locationName: json['locationName'] ?? '',
      isAcceptable: json['isAcceptable'] ?? false,
      eventContextId: json['EventContextId'] ?? 0,
      maxAttendance: json['maxAttendance'] ?? 0,
      attending: json['attending'] ?? 0,
      startDate: DateTime.parse(json['startDate'] ?? DateTime.now().toIso8601String()),
      endDate: DateTime.parse(json['endDate'] ?? DateTime.now().toIso8601String()),
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
      setup: json['setup'] ?? '',
      privacy: json['privacy'] ?? '',
      postId: json['PostId'] ?? 0,
      ongoing: json['ongoing'] ?? false,
      tickets: (json['Tickets'] as List<dynamic>? ?? [])
          .map((ticket) => EventTicket.fromJson(ticket))
          .toList(),
      attachments: (json['Attachments'] as List<dynamic>? ?? [])
          .map((attachment) => EventAttachment.fromJson(attachment))
          .toList(),
      eventContext: json['EventContext'] != null 
          ? EventContext.fromJson(json['EventContext']) 
          : null,
    );
  }
}

class EventContext {
  final int id;
  final String name;
  final String description;
  final DateTime createdAt;
  final DateTime updatedAt;

  const EventContext({
    required this.id,
    required this.name,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
  });

  factory EventContext.fromJson(Map<String, dynamic> json) {
    return EventContext(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }
}

class EventLocation {
  final String type;
  final List<double> coordinates;

  const EventLocation({
    required this.type,
    required this.coordinates,
  });

  factory EventLocation.fromJson(Map<String, dynamic> json) {
    return EventLocation(
      type: json['type'] ?? '',
      coordinates: (json['coordinates'] as List<dynamic>? ?? [])
          .map((coord) => (coord as num).toDouble())
          .toList(),
    );
  }
}

class EventTicket {
  final int id;
  final int price;
  final String name;
  final bool disabled;
  final String type;
  final String orderType;
  final String currency;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? description;

  const EventTicket({
    required this.id,
    required this.price,
    required this.name,
    required this.disabled,
    required this.type,
    required this.orderType,
    required this.currency,
    required this.createdAt,
    required this.updatedAt,
    this.description,
  });

  factory EventTicket.fromJson(Map<String, dynamic> json) {
    return EventTicket(
      id: json['id'] ?? 0,
      price: json['price'] ?? 0,
      name: json['name'] ?? '',
      disabled: json['disabled'] ?? false,
      type: json['type'] ?? '',
      orderType: json['orderType'] ?? '',
      currency: json['currency'] ?? '',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
      description: json['description'],
    );
  }
}

class EventAttachment {
  final int id;
  final String blurhash;
  final String url;
  final String fileType;
  final int imageId;
  final int width;
  final int height;
  final int? videoId;
  final int fileId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int? contentId;
  final int eventId;
  final String color;
  final String? medium;
  final String? small;
  final bool isDark;
  final bool isMainFlyer;

  const EventAttachment({
    required this.id,
    required this.blurhash,
    required this.url,
    required this.fileType,
    required this.imageId,
    required this.width,
    required this.height,
    this.videoId,
    required this.fileId,
    required this.createdAt,
    required this.updatedAt,
    this.contentId,
    required this.eventId,
    required this.color,
    this.medium,
    this.small,
    required this.isDark,
    required this.isMainFlyer,
  });

  factory EventAttachment.fromJson(Map<String, dynamic> json) {
    return EventAttachment(
      id: json['id'] ?? 0,
      blurhash: json['blurhash'] ?? '',
      url: json['url'] ?? '',
      fileType: json['fileType'] ?? '',
      imageId: json['imageId'] ?? 0,
      width: json['width'] ?? 0,
      height: json['height'] ?? 0,
      videoId: json['videoId'],
      fileId: json['fileId'] ?? 0,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
      contentId: json['ContentId'],
      eventId: json['EventId'] ?? 0,
      color: json['color'] ?? '',
      medium: json['medium'],
      small: json['small'],
      isDark: json['isDark'] ?? false,
      isMainFlyer: json['isMainFlyer'] ?? false,
    );
  }
}

class EventOwner {
  final int id;
  final String username;
  final String name;
  final String email;
  final String imageUrl;
  final String? bgUrl;
  final bool isPrivate;
  final String accountType;
  final bool isActive;
  final DateTime createdAt;
  final int maxDistance;
  final String? bio;
  final bool isVerified;
  final bool organizerProfileVerified;
  final bool isCallerSubscribedToUser;
  final bool isUserSubscribedToCaller;

  const EventOwner({
    required this.id,
    required this.username,
    required this.name,
    required this.email,
    required this.imageUrl,
    this.bgUrl,
    required this.isPrivate,
    required this.accountType,
    required this.isActive,
    required this.createdAt,
    required this.maxDistance,
    this.bio,
    required this.isVerified,
    required this.organizerProfileVerified,
    required this.isCallerSubscribedToUser,
    required this.isUserSubscribedToCaller,
  });

  factory EventOwner.fromJson(Map<String, dynamic> json) {
    return EventOwner(
      id: json['id'] ?? 0,
      username: json['username'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      bgUrl: json['bgUrl'],
      isPrivate: json['isPrivate'] ?? false,
      accountType: json['accountType'] ?? '',
      isActive: json['isActive'] ?? false,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      maxDistance: json['maxDistance'] ?? 0,
      bio: json['bio'],
      isVerified: json['isVerified'] ?? false,
      organizerProfileVerified: json['OrganizerProfileVerified'] ?? false,
      isCallerSubscribedToUser: json['isCallerSubscribedToUser'] ?? false,
      isUserSubscribedToCaller: json['isUserSubscribedToCaller'] ?? false,
    );
  }
}

class EventsResponse {
  final String statusCode;
  final String message;
  final EventsData data;

  const EventsResponse({
    required this.statusCode,
    required this.message,
    required this.data,
  });

  factory EventsResponse.fromJson(Map<String, dynamic> json) {
    return EventsResponse(
      statusCode: json['statusCode'] ?? '',
      message: json['message'] ?? '',
      data: EventsData.fromJson(json['data'] ?? {}),
    );
  }
}

class EventsData {
  final List<Event> events;
  final int count;
  final EventsPagination pagination;

  const EventsData({
    required this.events,
    required this.count,
    required this.pagination,
  });

  factory EventsData.fromJson(Map<String, dynamic> json) {
    return EventsData(
      events: (json['events'] as List<dynamic>? ?? [])
          .map((event) => Event.fromJson(event))
          .toList(),
      count: json['count'] ?? 0,
      pagination: EventsPagination.fromJson(json['pagination'] ?? {}),
    );
  }
}

class EventsPagination {
  final int current;
  final int limit;
  final int total;
  final EventsPaginationNext? next;

  const EventsPagination({
    required this.current,
    required this.limit,
    required this.total,
    this.next,
  });

  factory EventsPagination.fromJson(Map<String, dynamic> json) {
    return EventsPagination(
      current: json['current'] ?? 0,
      limit: json['limit'] ?? 0,
      total: json['total'] ?? 0,
      next: json['next'] != null ? EventsPaginationNext.fromJson(json['next']) : null,
    );
  }
}

class EventsPaginationNext {
  final int page;
  final int limit;
  final int total;

  const EventsPaginationNext({
    required this.page,
    required this.limit,
    required this.total,
  });

  factory EventsPaginationNext.fromJson(Map<String, dynamic> json) {
    return EventsPaginationNext(
      page: json['page'] ?? 0,
      limit: json['limit'] ?? 0,
      total: json['total'] ?? 0,
    );
  }
}
