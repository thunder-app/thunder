class AccountMedia {
  /// The images uploaded by the user.
  final List<Map<String, dynamic>> images;

  const AccountMedia({required this.images});

  bool get isEmpty => images.isEmpty;
}
