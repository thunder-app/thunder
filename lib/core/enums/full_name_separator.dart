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
  return switch (thunderState.userSeparator) {
    FullNameSeparator.dot => '$name · $instance',
    FullNameSeparator.at => '$name@$instance',
  };
}

String generateUserFullNameSuffix(BuildContext context, instance) {
  final ThunderState thunderState = context.read<ThunderBloc>().state;
  return switch (thunderState.userSeparator) {
    FullNameSeparator.dot => ' · $instance',
    FullNameSeparator.at => '@$instance',
  };
}

String generateCommunityFullName(BuildContext context, name, instance) {
  final ThunderState thunderState = context.read<ThunderBloc>().state;
  return switch (thunderState.communitySeparator) {
    FullNameSeparator.dot => '$name · $instance',
    FullNameSeparator.at => '$name@$instance',
  };
}
