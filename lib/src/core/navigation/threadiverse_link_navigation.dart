import 'package:flutter/material.dart';

import 'package:thunder/src/features/instance/data/constants/known_instances.dart';
import 'package:thunder/src/features/session/api.dart';
import 'package:thunder/src/core/navigation/loading_page.dart';
import 'package:thunder/src/core/app/repository_factories.dart';

/// Checks whether a link refers to a valid Lemmy/PieFed community.
Future<bool> testValidCommunity(BuildContext context, String link, String communityName, String instance) async {
  Uri? uri = Uri.tryParse(link);
  if (uri == null || !uri.hasScheme) {
    return true;
  }

  if (knownInstances.keys.contains(instance)) {
    return true;
  }

  try {
    // Since this may take a while, show a loading page.
    showLoadingPage(context);

    final account = resolveEffectiveAccount(context);
    await createCommunityRepository(account).getCommunity(name: communityName);
    return true;
  } catch (_) {
    // Ignore and return false below.
  }

  return false;
}

/// Checks whether a link refers to a valid Lemmy/PieFed user.
Future<bool> testValidUser(BuildContext context, String link, String userName, String instance) async {
  Uri? uri = Uri.tryParse(link);
  if (uri == null || !uri.hasScheme) {
    return true;
  }

  if (knownInstances.keys.contains(instance)) {
    return true;
  }

  try {
    // Since this may take a while, show a loading page.
    showLoadingPage(context);

    final account = resolveEffectiveAccount(context);
    await createUserRepository(account).getUser(username: userName);
    return true;
  } catch (_) {
    // Ignore and return false below.
  }

  return false;
}
