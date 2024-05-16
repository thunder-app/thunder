import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:thunder/account/bloc/account_bloc.dart';
import 'package:thunder/core/auth/bloc/auth_bloc.dart';
import 'package:thunder/core/enums/local_settings.dart';
import 'package:thunder/shared/snackbar.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';
import 'package:thunder/utils/constants.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void navigateToSetting(BuildContext context, LocalSettings setting) {
  String pageToNav = {
        LocalSettingsCategories.posts: SETTINGS_APPEARANCE_POSTS_PAGE,
        LocalSettingsCategories.comments: SETTINGS_APPEARANCE_COMMENTS_PAGE,
        LocalSettingsCategories.general: SETTINGS_GENERAL_PAGE,
        LocalSettingsCategories.gestures: SETTINGS_GESTURES_PAGE,
        LocalSettingsCategories.floatingActionButton: SETTINGS_FAB_PAGE,
        LocalSettingsCategories.filters: SETTINGS_FILTERS_PAGE,
        LocalSettingsCategories.accessibility: SETTINGS_ACCESSIBILITY_PAGE,
        LocalSettingsCategories.account: SETTINGS_ACCOUNT_PAGE,
        LocalSettingsCategories.theming: SETTINGS_APPEARANCE_THEMES_PAGE,
        LocalSettingsCategories.debug: SETTINGS_DEBUG_PAGE,
        LocalSettingsCategories.about: SETTINGS_ABOUT_PAGE,
        LocalSettingsCategories.videoPlayer: SETTINGS_VIDEO_PAGE,
      }[setting.category] ??
      SETTINGS_GENERAL_PAGE;

  GoRouter.of(context).push(
    pageToNav,
    extra: pageToNav == SETTINGS_ABOUT_PAGE
        ? [
            context.read<ThunderBloc>(),
            context.read<AccountBloc>(),
            context.read<AuthBloc>(),
            setting,
          ]
        : [
            context.read<ThunderBloc>(),
            setting,
          ],
  );
}

void shareSetting(BuildContext context, LocalSettings? setting, String description) {
  if (setting == null) return;

  final AppLocalizations l10n = AppLocalizations.of(context)!;
  final String settingPath = '${l10n.getLocalSettingLocalization(setting.category!.toString())} > ${l10n.getLocalSettingLocalization(setting.subCategory.toString())} > $description';

  Clipboard.setData(ClipboardData(text: '[Thunder Setting: $settingPath](thunder://setting-${setting.name})'));
  showSnackbar('Setting link copied to clipboard!');
}
