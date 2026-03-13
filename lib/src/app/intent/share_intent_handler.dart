import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';

import 'package:flutter_sharing_intent/flutter_sharing_intent.dart';
import 'package:flutter_sharing_intent/model/sharing_file.dart';

import 'package:thunder/src/foundation/config/global_context.dart';
import 'package:thunder/src/app/shell/navigation/navigation_utils.dart';
import 'package:thunder/packages/ui/ui.dart' show showSnackbar;

/// Handles share intents (external content shared to Thunder) from the OS.
///
/// This class is responsible for processing shared images, URLs, and text.
class ShareIntentHandler {
  /// The context of the current build.
  final BuildContext context;

  /// The stream subscription for the media intent data.
  StreamSubscription? mediaIntentDataStreamSubscription;

  ShareIntentHandler(this.context);

  void dispose() {
    mediaIntentDataStreamSubscription?.cancel();
  }

  /// Processes any pending shared content and sets up listeners for new shares.
  Future<void> handleSharedFilesAndText(String? currentIntent) async {
    final l10n = GlobalContext.l10n;

    try {
      // For sharing files from outside the app while the app is closed
      final files = await FlutterSharingIntent.instance.getInitialSharing();
      if (files.isNotEmpty && currentIntent != 'android.intent.action.VIEW') {
        handleFile(files.first);
      }

      // For sharing files while the app is in the memory
      mediaIntentDataStreamSubscription = FlutterSharingIntent.instance.getMediaStream().listen((List<SharedFile> files) {
        if (!context.mounted || files.isEmpty || currentIntent == 'android.intent.action.VIEW') {
          return;
        }
        handleFile(files.first);
      });
    } catch (e) {
      if (context.mounted) {
        showSnackbar(l10n.unexpectedError);
      }
    }
  }

  /// Navigates to the post creation page with the shared content based on its type.
  void handleFile(SharedFile file) {
    switch (file.type) {
      case SharedMediaType.IMAGE:
        navigateToCreatePostPage(context, image: File(file.value!), prePopulated: true);
        break;
      case SharedMediaType.URL:
        navigateToCreatePostPage(context, url: file.value!, prePopulated: true);
        break;
      case SharedMediaType.TEXT:
        navigateToCreatePostPage(context, text: file.value, prePopulated: true);
        break;
      default:
        break;
    }
  }
}
