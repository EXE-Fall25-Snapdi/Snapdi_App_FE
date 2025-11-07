class ReviewModel {
  final int reviewId;
  final int bookingId;
  final int fromUserId;
  final String fromUserName;
  final String fromUserAvatar;
  final int rating;
  final String comment;
  final DateTime createdAt;

  ReviewModel({
    required this.reviewId,
    required this.bookingId,
    required this.fromUserId,
    required this.fromUserName,
    required this.fromUserAvatar,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      reviewId: json['reviewId'] ?? 0,
      bookingId: json['bookingId'] ?? 0,
      fromUserId: json['fromUserId'] ?? 0,
      fromUserName: json['fromUserName'] ?? '',
      fromUserAvatar: json['fromUserAvatar'] ?? '',
      rating: json['rating'] ?? 0,
      comment: json['comment'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'reviewId': reviewId,
      'bookingId': bookingId,
      'fromUserId': fromUserId,
      'fromUserName': fromUserName,
      'fromUserAvatar': fromUserAvatar,
      'rating': rating,
      'comment': comment,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
