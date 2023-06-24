import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lemmy/lemmy.dart';
import 'package:thunder/inbox/bloc/inbox_bloc.dart';

class InboxMentionsView extends StatelessWidget {
  const InboxMentionsView({super.key});

  @override
  Widget build(BuildContext context) {
    List<PersonMentionView> mentions = context.read<InboxBloc>().state.mentions;

    if (mentions.isEmpty) {
      return const Center(child: Text('No mentions'));
    }

    return Container();
  }
}
