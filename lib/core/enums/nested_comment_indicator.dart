enum NestedCommentIndicatorStyle {
  thick('Thick'),
  thin('Thin');

  final String value;
  const NestedCommentIndicatorStyle(this.value);

  factory NestedCommentIndicatorStyle.fromJson(String value) => values.firstWhere((e) => e.value == value);

  String toJson() => value;

  @override
  String toString() => value;
}

enum NestedCommentIndicatorColor {
  colorful('Colorful'),
  monochrome('Monochrome');

  final String value;
  const NestedCommentIndicatorColor(this.value);

  factory NestedCommentIndicatorColor.fromJson(String value) => values.firstWhere((e) => e.value == value);

  String toJson() => value;

  @override
  String toString() => value;
}
