import 'package:equatable/equatable.dart';

/// A page of items returned by a Thunder service.
class ThunderPage<T> extends Equatable {
  /// Items returned for this page.
  final List<T> items;

  /// Bookmark for the next page, when there is one.
  final String? nextPage;

  /// Bookmark for the previous page, when there is one.
  final String? previousPage;

  const ThunderPage({required this.items, this.nextPage, this.previousPage});

  @override
  List<Object?> get props => [items, nextPage, previousPage];
}
