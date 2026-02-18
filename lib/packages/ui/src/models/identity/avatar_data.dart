class AvatarData {
  const AvatarData({
    required this.fallbackLabel,
    this.imageUrl,
    this.radius = 16.0,
    this.semanticLabel,
  });

  final String fallbackLabel;
  final String? imageUrl;
  final double radius;
  final String? semanticLabel;
}
