class BookingRequest {
  final int customerId;
  final int photographerId;
  final String scheduleAt;
  final String locationAddress;
  final int price;
  final String? note;
  final int? photoTypeId;
  final int? time;

  BookingRequest({
    required this.customerId,
    required this.photographerId,
    required this.scheduleAt,
    required this.locationAddress,
    required this.price,
    this.note,
    this.photoTypeId,
    this.time,
  });

  Map<String, dynamic> toJson() {
    return {
      'customerId': customerId,
      'photographerId': photographerId,
      'scheduleAt': scheduleAt,
      'locationAddress': locationAddress,
      'price': price,
      if (note != null) 'note': note,
      if (photoTypeId != null) 'photoTypeId': photoTypeId,
      if (time != null) 'time': time,
    };
  }
}
