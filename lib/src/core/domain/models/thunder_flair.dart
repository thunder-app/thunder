import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class ThunderFlair extends Equatable {
  /// The flair's ID.
  final int id;

  /// The community this flair belongs to.
  final int communityId;

  /// The label shown for the flair.
  final String title;

  /// Hex color code for the flair text.
  final String textColor;

  /// Hex color code for the flair background.
  final String backgroundColor;

  const ThunderFlair({
    required this.id,
    required this.communityId,
    required this.title,
    required this.textColor,
    required this.backgroundColor,
  });

  /// Parsed text color for display, if the hex value is valid.
  Color? get parsedTextColor => _parseHexColor(textColor);

  /// Parsed background color for display, if the hex value is valid.
  Color? get parsedBackgroundColor => _parseHexColor(backgroundColor);

  @override
  List<Object?> get props => [id, communityId, title, textColor, backgroundColor];

  factory ThunderFlair.fromPiefedFlair(Map<String, dynamic> flair) {
    return ThunderFlair(
      id: flair['id'],
      communityId: flair['community_id'],
      title: flair['flair_title'],
      textColor: flair['text_color'],
      backgroundColor: flair['background_color'],
    );
  }

  static List<ThunderFlair> parsePiefedList(dynamic flairs) {
    return (flairs as List?)?.whereType<Map>().map((flair) => ThunderFlair.fromPiefedFlair(Map<String, dynamic>.from(flair))).toList() ?? const [];
  }

  static Color? _parseHexColor(String? value) {
    if (value == null) return null;

    final normalized = value.trim().replaceFirst('#', '');
    if (normalized.isEmpty) return null;

    final hex = switch (normalized.length) {
      6 => 'FF$normalized',
      8 => normalized,
      _ => null,
    };

    if (hex == null) return null;

    try {
      return Color(int.parse(hex, radix: 16));
    } catch (_) {
      return null;
    }
  }
}
