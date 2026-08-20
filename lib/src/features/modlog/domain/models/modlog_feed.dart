import 'package:thunder/src/features/modlog/data/models/modlog_event_item.dart';

/// A page of modlog events returned by [ModlogRepository].
class ModlogFeed {
  final List<ModlogEventItem> items;
  final bool hasReachedEnd;
  final int currentPage;

  ModlogFeed({required this.items, required this.hasReachedEnd, required this.currentPage});
}
