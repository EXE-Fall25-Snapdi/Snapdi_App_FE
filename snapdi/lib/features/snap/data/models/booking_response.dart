class BookingUser {
  final int userId;
  final String name;
  final String email;
  final String phone;

  BookingUser({
    required this.userId,
    required this.name,
    required this.email,
    required this.phone,
  });

  factory BookingUser.fromJson(Map<String, dynamic> json) {
    return BookingUser(
      userId: json['userId'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
    );
  }
}

/// Photographer-specific model returned inside booking response
class BookingPhotographer {
  final int userId;
  final String name;
  final String email;
  final String phone;
  final double? avgRating;
  final bool? isAvailable;
  final String? levelPhotographer;
  final int? photoPrice;
  final String? avatarUrl;

  BookingPhotographer({
    required this.userId,
    required this.name,
    required this.email,
    required this.phone,
    this.avgRating,
    this.isAvailable,
    this.levelPhotographer,
    this.photoPrice,
    this.avatarUrl,
  });

  factory BookingPhotographer.fromJson(Map<String, dynamic> json) {
    return BookingPhotographer(
      userId: json['userId'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      avgRating: json['avgRating'] != null
          ? (json['avgRating'] as num).toDouble()
          : null,
      isAvailable: json['isAvailable'],
      levelPhotographer: json['levelPhotographer'],
      photoPrice: json['photoPrice'],
      avatarUrl:
          (json['avatarUrl'] ??
                  json['avatar'] ??
                  json['image'] ??
                  json['photoUrl'])
              as String?,
    );
  }
}

class BookingStatus {
  final int statusId;
  final String statusName;

  BookingStatus({required this.statusId, required this.statusName});

  factory BookingStatus.fromJson(Map<String, dynamic> json) {
    return BookingStatus(
      statusId: json['statusId'] ?? 0,
      statusName: json['statusName'] ?? '',
    );
  }
}

class BookingData {
  final int bookingId;
  final BookingUser customer;
  final BookingPhotographer photographer;
  final String scheduleAt;
  final String locationAddress;
  final BookingStatus status;
  final int price;
  final String? note;
  final int photoTypeId;
  final int time;

  BookingData({
    required this.bookingId,
    required this.customer,
    required this.photographer,
    required this.scheduleAt,
    required this.locationAddress,
    required this.status,
    required this.price,
    required this.photoTypeId,
    required this.time,
    this.note,
  });

  factory BookingData.fromJson(Map<String, dynamic> json) {
    return BookingData(
      bookingId: json['bookingId'] ?? 0,
      customer: json.containsKey('customer')
          ? BookingUser.fromJson(json['customer'])
          : BookingUser(
              userId: json['customerId'] ?? 0,
              name: json['customerName'] ?? '',
              email: json['customerEmail'] ?? '',
              phone: json['customerPhone'] ?? '',
            ),
      photographer: json.containsKey('photographer')
          ? BookingPhotographer.fromJson(json['photographer'])
          : BookingPhotographer(
              userId: json['photographerId'] ?? 0,
              name: json['photographerName'] ?? '',
              email: json['photographerEmail'] ?? '',
              phone: json['photographerPhone'] ?? '',
              avgRating: 5.0,
            ),
      scheduleAt: json['scheduleAt'] ?? '',
      locationAddress: json['locationAddress'] ?? '',
      status: json.containsKey('status')
          ? BookingStatus.fromJson(json['status'])
          : BookingStatus(
              statusId: json['statusId'] ?? 0,
              statusName: json['statusName'] ?? '',
            ),
      price: json['price'] ?? 0,
      note: json['note'],
      photoTypeId: json['photoTypeId'] ?? 0,
      time: json['time'] ?? 0,
    );
  }
}

class BookingResponse {
  final bool success;
  final String? message;
  final BookingData? data;

  BookingResponse({required this.success, this.message, this.data});

  factory BookingResponse.fromJson(Map<String, dynamic> json) {
    return BookingResponse(
      success: json['bookingId'] != null, // If bookingId exists, it's success
      message: json['message'],
      data: json['bookingId'] != null ? BookingData.fromJson(json) : null,
    );
  }
}
