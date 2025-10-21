class BookingRequest {
  final int customerId;
  final int photographerId;
  final String scheduleAt;
  final String locationAddress;
  final int price;
  final String? note;

  BookingRequest({
    required this.customerId,
    required this.photographerId,
    required this.scheduleAt,
    required this.locationAddress,
    required this.price,
    this.note,
  });

  Map<String, dynamic> toJson() {
    return {
      'customerId': customerId,
      'photographerId': photographerId,
      'scheduleAt': scheduleAt,
      'locationAddress': locationAddress,
      'price': price,
      if (note != null) 'note': note,
    };
  }
}
