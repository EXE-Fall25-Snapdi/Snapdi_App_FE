import 'package:json_annotation/json_annotation.dart';

part 'portfolio_create_response.g.dart';

@JsonSerializable()
class PortfolioCreateResponse {
  final List<CreatedPortfolio> createdPortfolios;
  final List<String> failedPhotoUrls;
  final int totalAttempted;
  final int successCount;
  final int failedCount;
  final bool isCompleteSuccess;
  final String message;

  PortfolioCreateResponse({
    required this.createdPortfolios,
    required this.failedPhotoUrls,
    required this.totalAttempted,
    required this.successCount,
    required this.failedCount,
    required this.isCompleteSuccess,
    required this.message,
  });

  factory PortfolioCreateResponse.fromJson(Map<String, dynamic> json) =>
      _$PortfolioCreateResponseFromJson(json);

  Map<String, dynamic> toJson() => _$PortfolioCreateResponseToJson(this);
}

@JsonSerializable()
class CreatedPortfolio {
  final int photoPortfolioId;
  final int userId;
  final String photoUrl;

  CreatedPortfolio({
    required this.photoPortfolioId,
    required this.userId,
    required this.photoUrl,
  });

  factory CreatedPortfolio.fromJson(Map<String, dynamic> json) =>
      _$CreatedPortfolioFromJson(json);

  Map<String, dynamic> toJson() => _$CreatedPortfolioToJson(this);
}
