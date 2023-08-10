import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../thunder/bloc/thunder_bloc.dart';

class UserSidebarStats extends StatelessWidget {
  final IconData icon;
  final String label;
  final String metric;
  final String scoreLabel;
  final String scoreMetric;

  const UserSidebarStats({
    Key? key,
    required this.icon,
    required this.label,
    required this.metric,
    required this.scoreLabel,
    required this.scoreMetric,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ThunderState state = context.read<ThunderBloc>().state;
    bool scoreCounters = state.scoreCounters;

    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2),
          child: Icon(
            icon,
            size: 18,
            color: theme.colorScheme.onBackground.withOpacity(0.65),
          ),
        ),
        Text(
          '$metric $label',
          style: TextStyle(color: theme.textTheme.titleSmall?.color?.withOpacity(0.65)),
        ),
        Visibility(
          visible: !scoreCounters,
          child: Text(
            ' · $scoreMetric $scoreLabel',
            style: TextStyle(color: theme.textTheme.titleSmall?.color?.withOpacity(0.65)),
          ),
        ),
      ],
    );
  }
}
