import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';

enum FullNameSeparator {
  dot('name · instance.tld'),
  at('name@instance.tld');

  final String label;

  const FullNameSeparator(this.label);
}

String generateUserFullName(BuildContext context, name, instance) {
  final ThunderState thunderState = context.read<ThunderBloc>().state;
  if (thunderState.userSeparator == FullNameSeparator.dot) {
    return '$name · $instance';
  } else if (thunderState.userSeparator == FullNameSeparator.at) {
    return '$name@$instance';
  }

  // Default format in case the setting isn't set
  return '$name@$instance';
}

String generateUserFullNameSuffix(BuildContext context, instance) {
  final ThunderState thunderState = context.read<ThunderBloc>().state;
  if (thunderState.userSeparator == FullNameSeparator.dot) {
    return ' · $instance';
  } else if (thunderState.userSeparator == FullNameSeparator.at) {
    return '@$instance';
  }

  // Default format in case the setting isn't set
  return '@$instance';
}

String generateCommunityFullName(BuildContext context, name, instance) {
  final ThunderState thunderState = context.read<ThunderBloc>().state;
  if (thunderState.communitySeparator == FullNameSeparator.dot) {
    return '$name · $instance';
  } else if (thunderState.communitySeparator == FullNameSeparator.at) {
    return '$name@$instance';
  }

  // Default format in case the setting isn't set
  return '$name · $instance';
}
