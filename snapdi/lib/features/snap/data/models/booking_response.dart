class BookingResponse {
  final bool success;
  final String? message;
  final dynamic data;

  BookingResponse({
    required this.success,
    this.message,
    this.data,
  });

  factory BookingResponse.fromJson(Map<String, dynamic> json) {
    return BookingResponse(
      success: json['success'] ?? false,
      message: json['message'],
      data: json['data'],
    );
  }
}
