import 'package:collection/collection.dart';

List<String> decodePiefedComposerTags(String? value) {
  if (value == null || value.trim().isEmpty) {
    return const [];
  }

  return _normalizePiefedTags(value.split(','));
}

List<String> parsePiefedTags(dynamic value) {
  return switch (value) {
    String() => decodePiefedComposerTags(value),
    Iterable() => _normalizePiefedTags(
      value.map(
        (tag) => switch (tag) {
          String() => tag,
          Map() => (tag['name'] ?? tag['tag'] ?? tag['title'] ?? '').toString(),
          _ => '',
        },
      ),
    ),
    _ => const [],
  };
}

List<String> normalizePiefedTags(Iterable<String>? tags) {
  if (tags == null) {
    return const [];
  }

  return _normalizePiefedTags(tags);
}

String encodePiefedTags(Iterable<String>? tags) => normalizePiefedTags(tags).join(', ');

List<int> normalizePiefedFlairIds(Iterable<int>? flairIds) {
  if (flairIds == null) {
    return const [];
  }

  return flairIds.toSet().toList();
}

List<String>? resolveSubmittedPiefedTags(String? composerText, {Iterable<String>? originalTags}) {
  final normalizedTags = decodePiefedComposerTags(composerText);
  if (originalTags == null) {
    return normalizedTags.isEmpty ? null : normalizedTags;
  }

  return const ListEquality<String>().equals(normalizedTags, normalizePiefedTags(originalTags)) ? null : normalizedTags;
}

List<int>? resolveSubmittedPiefedFlairIds(Iterable<int>? selectedFlairIds, {Iterable<int>? originalFlairIds}) {
  final normalizedFlairIds = normalizePiefedFlairIds(selectedFlairIds);
  if (originalFlairIds == null) {
    return normalizedFlairIds.isEmpty ? null : normalizedFlairIds;
  }

  return const SetEquality<int>().equals(normalizedFlairIds.toSet(), normalizePiefedFlairIds(originalFlairIds).toSet()) ? null : normalizedFlairIds;
}

List<int> retainValidPiefedFlairSelection({required List<int> selectedFlairIds, required Iterable<int> availableFlairIds, required bool clearWhenUnavailable}) {
  final normalizedSelection = normalizePiefedFlairIds(selectedFlairIds);
  final validFlairIds = availableFlairIds.toSet();

  if (validFlairIds.isEmpty) {
    return clearWhenUnavailable ? const [] : normalizedSelection;
  }

  return normalizedSelection.where(validFlairIds.contains).toList();
}

List<String> _normalizePiefedTags(Iterable<String> tags) {
  final normalized = <String>[];

  for (final tag in tags) {
    final trimmed = tag.trim().replaceFirst(RegExp(r'^#+'), '');
    if (trimmed.isEmpty || normalized.contains(trimmed)) {
      continue;
    }

    normalized.add(trimmed);
  }

  return normalized;
}
