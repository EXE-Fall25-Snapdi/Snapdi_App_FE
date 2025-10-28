class Style {
  final int styleId;
  final String styleName;

  Style({
    required this.styleId,
    required this.styleName,
  });

  factory Style.fromJson(Map<String, dynamic> json) {
    return Style(
      styleId: json['styleId'] ?? 0,
      styleName: json['styleName'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'styleId': styleId,
      'styleName': styleName,
    };
  }
}
