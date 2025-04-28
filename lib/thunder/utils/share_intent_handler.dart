import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_sharing_intent/flutter_sharing_intent.dart';
import 'package:flutter_sharing_intent/model/sharing_file.dart';

import 'package:thunder/shared/snackbar.dart';
import 'package:thunder/utils/navigation.dart';

/// Handles share intents (external content shared to Thunder) from the OS.
///
/// This class is responsible for processing shared images, URLs, and text.
class ShareIntentHandler {
  final BuildContext context;
  StreamSubscription? mediaIntentDataStreamSubscription;

  ShareIntentHandler(this.context);

  void dispose() {
    mediaIntentDataStreamSubscription?.cancel();
  }

  /// Processes any pending shared content and sets up listeners for new shares.
  Future<void> handleSharedFilesAndText(String? currentIntent) async {
    try {
      // For sharing files from outside the app while the app is closed
      List<SharedFile> sharedFiles = await FlutterSharingIntent.instance.getInitialSharing();
      if (sharedFiles.isNotEmpty && currentIntent != 'android.intent.action.VIEW') {
        handleSharedItems(sharedFiles.first);
      }

      // For sharing files while the app is in the memory
      mediaIntentDataStreamSubscription = FlutterSharingIntent.instance.getMediaStream().listen((List<SharedFile> sharedFiles) {
        if (!context.mounted || sharedFiles.isEmpty || currentIntent == 'android.intent.action.VIEW') return;
        handleSharedItems(sharedFiles.first);
      });
    } catch (e) {
      if (context.mounted) {
        showSnackbar(AppLocalizations.of(context)!.unexpectedError);
      }
    }
  }

  /// Navigates to the post creation page with the shared content based on its type.
  void handleSharedItems(SharedFile sharedFile) {
    switch (sharedFile.type) {
      case SharedMediaType.IMAGE:
        navigateToCreatePostPage(context, image: File(sharedFile.value!), prePopulated: true);
        break;
      case SharedMediaType.URL:
        navigateToCreatePostPage(context, url: sharedFile.value!, prePopulated: true);
        break;
      case SharedMediaType.TEXT:
        navigateToCreatePostPage(context, text: sharedFile.value, prePopulated: true);
        break;
      default:
        break;
    }
  }
}
