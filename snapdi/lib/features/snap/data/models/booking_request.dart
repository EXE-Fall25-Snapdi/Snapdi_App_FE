class BookingRequest {
  final int customerId;
  final int photographerId;
  final String scheduleAt;
  final String locationCity;
  final String locationAddress;
  final int styleId;
  final double price;

  BookingRequest({
    required this.customerId,
    required this.photographerId,
    required this.scheduleAt,
    required this.locationCity,
    required this.locationAddress,
    required this.styleId,
    required this.price,
  });

  Map<String, dynamic> toJson() {
    return {
      'customerId': customerId,
      'photographerId': photographerId,
      'scheduleAt': scheduleAt,
      'locationCity': locationCity,
      'locationAddress': locationAddress,
      'styleId': styleId,
      'price': price,
    };
  }
}
