import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:thunder/src/features/settings/api.dart';
import 'package:thunder/src/core/services/services.dart';
import 'package:thunder/src/core/domain/domain.dart';
import 'package:thunder/src/shared/share/advanced_share_sheet/advanced_share_sheet_content.dart';
import 'package:thunder/src/shared/share/advanced_share_sheet/advanced_share_sheet_options.dart';
export 'package:thunder/src/shared/share/advanced_share_sheet/advanced_share_sheet_image.dart';
export 'package:thunder/src/shared/share/advanced_share_sheet/advanced_share_sheet_options.dart';

/// Shows the advanced share sheet for a post.
void showAdvancedShareSheet(BuildContext context, ThunderPost post) {
  final options = _loadSavedOptions();

  if (context.mounted) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => BlocProvider(
        create: (context) => ThemePreferencesCubit(preferencesStore: const UserPreferencesStore()),
        child: AdvancedShareSheetContent(post: post, initialOptions: options),
      ),
    );
  }
}

AdvancedShareSheetOptions _loadSavedOptions() {
  final options = const UserPreferencesStore().getLocalSetting<String>(LocalSettings.advancedShareOptions);
  if (options == null) return AdvancedShareSheetOptions();

  try {
    final decoded = jsonDecode(options);
    if (decoded is Map<String, dynamic>) return AdvancedShareSheetOptions.fromJson(decoded);
    if (decoded is Map) return AdvancedShareSheetOptions.fromJson(Map<String, dynamic>.from(decoded));
  } catch (_) {
    return AdvancedShareSheetOptions();
  }

  return AdvancedShareSheetOptions();
}
