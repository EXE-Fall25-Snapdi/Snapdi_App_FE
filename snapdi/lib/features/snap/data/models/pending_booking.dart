import 'package:json_annotation/json_annotation.dart';

part 'pending_booking.g.dart';

@JsonSerializable()
class PendingBookingResponse {
  @JsonKey(name: 'data')
  final List<PendingBooking> data;

  @JsonKey(name: 'totalCount')
  final int totalCount;

  @JsonKey(name: 'currentPage')
  final int currentPage;

  @JsonKey(name: 'pageSize')
  final int pageSize;

  @JsonKey(name: 'totalPages')
  final int totalPages;

  @JsonKey(name: 'hasNextPage')
  final bool hasNextPage;

  @JsonKey(name: 'hasPreviousPage')
  final bool hasPreviousPage;

  PendingBookingResponse({
    required this.data,
    required this.totalCount,
    required this.currentPage,
    required this.pageSize,
    required this.totalPages,
    required this.hasNextPage,
    required this.hasPreviousPage,
  });

  factory PendingBookingResponse.fromJson(Map<String, dynamic> json) =>
      _$PendingBookingResponseFromJson(json);

  Map<String, dynamic> toJson() => _$PendingBookingResponseToJson(this);
}

@JsonSerializable()
class PendingBooking {
  @JsonKey(name: 'bookingId')
  final int bookingId;

  @JsonKey(name: 'user')
  final PendingBookingUser user;

  @JsonKey(name: 'photographer')
  final PendingBookingPhotographer photographer;

  @JsonKey(name: 'scheduleAt')
  final String scheduleAt;

  @JsonKey(name: 'locationAddress')
  final String locationAddress;

  @JsonKey(name: 'price')
  final double price;

  @JsonKey(name: 'status')
  final BookingStatus status;

  @JsonKey(name: 'duration')
  final int duration;

  @JsonKey(name: 'photoType')
  final PhotoType photoType;

  @JsonKey(name: 'note')
  final String? note;

  @JsonKey(name: 'photoLink')
  final String? photoLink;

  PendingBooking({
    required this.bookingId,
    required this.user,
    required this.photographer,
    required this.scheduleAt,
    required this.locationAddress,
    required this.price,
    required this.status,
    required this.duration,
    required this.photoType,
    this.note,
    this.photoLink,
  });

  factory PendingBooking.fromJson(Map<String, dynamic> json) =>
      _$PendingBookingFromJson(json);

  Map<String, dynamic> toJson() => _$PendingBookingToJson(this);
}

@JsonSerializable()
class PendingBookingUser {
  @JsonKey(name: 'userId')
  final int userId;

  @JsonKey(name: 'avatarUrl')
  final String? avatarUrl;

  @JsonKey(name: 'name')
  final String? name;

  @JsonKey(name: 'email')
  final String? email;

  @JsonKey(name: 'phone')
  final String? phone;

  PendingBookingUser({
    required this.userId,
    this.avatarUrl,
    this.name,
    this.email,
    this.phone,
  });

  factory PendingBookingUser.fromJson(Map<String, dynamic> json) =>
      _$PendingBookingUserFromJson(json);

  Map<String, dynamic> toJson() => _$PendingBookingUserToJson(this);
}

@JsonSerializable()
class PendingBookingPhotographer {
  @JsonKey(name: 'userId')
  final int userId;

  @JsonKey(name: 'avatarUrl')
  final String? avatarUrl;

  @JsonKey(name: 'name')
  final String? name;

  @JsonKey(name: 'email')
  final String? email;

  @JsonKey(name: 'phone')
  final String? phone;

  @JsonKey(name: 'avgRating')
  final double? avgRating;

  @JsonKey(name: 'isAvailable')
  final bool? isAvailable;

  @JsonKey(name: 'levelPhotographer')
  final String? levelPhotographer;

  PendingBookingPhotographer({
    required this.userId,
    this.avatarUrl,
    this.name,
    this.email,
    this.phone,
    this.avgRating,
    this.isAvailable,
    this.levelPhotographer,
  });

  factory PendingBookingPhotographer.fromJson(Map<String, dynamic> json) =>
      _$PendingBookingPhotographerFromJson(json);

  Map<String, dynamic> toJson() => _$PendingBookingPhotographerToJson(this);
}

@JsonSerializable()
class BookingStatus {
  @JsonKey(name: 'statusId')
  final int statusId;

  @JsonKey(name: 'statusName')
  final String statusName;

  BookingStatus({
    required this.statusId,
    required this.statusName,
  });

  factory BookingStatus.fromJson(Map<String, dynamic> json) =>
      _$BookingStatusFromJson(json);

  Map<String, dynamic> toJson() => _$BookingStatusToJson(this);
}

@JsonSerializable()
class PhotoType {
  @JsonKey(name: 'photoTypeId')
  final int photoTypeId;

  @JsonKey(name: 'photoTypeName')
  final String photoTypeName;

  @JsonKey(name: 'photoPrice')
  final double photoPrice;

  @JsonKey(name: 'time')
  final int time;

  PhotoType({
    required this.photoTypeId,
    required this.photoTypeName,
    required this.photoPrice,
    required this.time,
  });

  factory PhotoType.fromJson(Map<String, dynamic> json) =>
      _$PhotoTypeFromJson(json);

  Map<String, dynamic> toJson() => _$PhotoTypeToJson(this);
}
