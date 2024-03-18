import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';

enum FullNameSeparator {
  dot, // name · instance.tld
  at, // name@instance.tld
  lemmy; // '@name@instance.tld or !name@instance.tld'
}

String generateUserFullName(BuildContext? context, name, instance, {FullNameSeparator? userSeparator}) {
  assert(context != null || userSeparator != null);
  userSeparator ??= context!.read<ThunderBloc>().state.userSeparator;
  return switch (userSeparator) {
    FullNameSeparator.dot => '$name · $instance',
    FullNameSeparator.at => '$name@$instance',
    FullNameSeparator.lemmy => '@$name@$instance',
  };
}

String generateUserFullNameSuffix(BuildContext? context, instance, {FullNameSeparator? userSeparator}) {
  assert(context != null || userSeparator != null);
  userSeparator ??= context!.read<ThunderBloc>().state.userSeparator;
  return switch (userSeparator) {
    FullNameSeparator.dot => ' · $instance',
    FullNameSeparator.at => '@$instance',
    FullNameSeparator.lemmy => '@$instance',
  };
}

String generateCommunityFullName(BuildContext? context, name, instance, {FullNameSeparator? communitySeparator}) {
  assert(context != null || communitySeparator != null);
  communitySeparator ??= context!.read<ThunderBloc>().state.communitySeparator;
  return switch (communitySeparator) {
    FullNameSeparator.dot => '$name · $instance',
    FullNameSeparator.at => '$name@$instance',
    FullNameSeparator.lemmy => '!$name@$instance',
  };
}
