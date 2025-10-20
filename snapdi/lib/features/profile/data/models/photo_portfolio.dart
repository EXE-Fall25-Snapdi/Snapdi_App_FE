import 'package:json_annotation/json_annotation.dart';

part 'photo_portfolio.g.dart';

@JsonSerializable()
class PhotoPortfolio {
  @JsonKey(name: 'photoPortfolioId')
  final int photoPortfolioId;

  @JsonKey(name: 'userId')
  final int userId;

  @JsonKey(name: 'photoUrl')
  final String photoUrl;

  const PhotoPortfolio({
    required this.photoPortfolioId,
    required this.userId,
    required this.photoUrl,
  });

  factory PhotoPortfolio.fromJson(Map<String, dynamic> json) =>
      _$PhotoPortfolioFromJson(json);

  Map<String, dynamic> toJson() => _$PhotoPortfolioToJson(this);
}
