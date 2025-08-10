enum ViewMode {
  compact(75.0),
  comfortable(150.0);

  /// The height of media previews for the given view mode
  final double height;

  const ViewMode(this.height);
}
