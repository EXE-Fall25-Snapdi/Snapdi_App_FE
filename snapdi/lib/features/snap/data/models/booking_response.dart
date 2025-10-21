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

class BookingStatus {
  final int statusId;
  final String statusName;

  BookingStatus({
    required this.statusId,
    required this.statusName,
  });

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
  final BookingUser photographer;
  final String scheduleAt;
  final String locationAddress;
  final BookingStatus status;
  final int price;
  final String? note;

  BookingData({
    required this.bookingId,
    required this.customer,
    required this.photographer,
    required this.scheduleAt,
    required this.locationAddress,
    required this.status,
    required this.price,
    this.note,
  });

  factory BookingData.fromJson(Map<String, dynamic> json) {
    return BookingData(
      bookingId: json['bookingId'] ?? 0,
      customer: BookingUser.fromJson(json['customer'] ?? {}),
      photographer: BookingUser.fromJson(json['photographer'] ?? {}),
      scheduleAt: json['scheduleAt'] ?? '',
      locationAddress: json['locationAddress'] ?? '',
      status: BookingStatus.fromJson(json['status'] ?? {}),
      price: json['price'] ?? 0,
      note: json['note'],
    );
  }
}

class BookingResponse {
  final bool success;
  final String? message;
  final BookingData? data;

  BookingResponse({
    required this.success,
    this.message,
    this.data,
  });

  factory BookingResponse.fromJson(Map<String, dynamic> json) {
    return BookingResponse(
      success: json['bookingId'] != null, // If bookingId exists, it's success
      message: json['message'],
      data: json['bookingId'] != null 
          ? BookingData.fromJson(json)
          : null,
    );
  }
}
