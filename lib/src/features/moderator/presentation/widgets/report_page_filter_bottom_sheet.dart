import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:thunder/src/features/account/account.dart';
import 'package:thunder/src/features/community/community.dart';
import 'package:thunder/l10n/generated/app_localizations.dart';
import 'package:thunder/src/features/post/post.dart';

enum ReportResolveStatus { unresolved, all }

/// A [BottomSheet] that allows the user to filter reports by status and community
/// When the submit button is pressed, the [onSubmit] function is called with the selected [ReportResolveStatus] and [ThunderCommunity] if any.
class ReportFilterBottomSheet extends StatefulWidget {
  const ReportFilterBottomSheet({super.key, required this.status, required this.onSubmit});

  /// The status to filter by
  final ReportResolveStatus status;

  /// The function to call when the submit button is pressed
  final void Function(ReportResolveStatus reportResolveStatus, ThunderCommunity? community) onSubmit;

  @override
  State<ReportFilterBottomSheet> createState() => _ReportFilterBottomSheetState();
}

class _ReportFilterBottomSheetState extends State<ReportFilterBottomSheet> {
  /// The status to filter by
  ReportResolveStatus status = ReportResolveStatus.all;

  /// The community to filter by
  ThunderCommunity? community;

  @override
  void initState() {
    super.initState();
    status = widget.status;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.filters, style: theme.textTheme.titleLarge),
            const SizedBox(height: 16.0),
            Text(l10n.status, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8.0),
            SegmentedButton<ReportResolveStatus>(
              showSelectedIcon: false,
              style: SegmentedButton.styleFrom(visualDensity: VisualDensity.compact, minimumSize: Size.zero),
              segments: <ButtonSegment<ReportResolveStatus>>[
                ButtonSegment<ReportResolveStatus>(
                  value: ReportResolveStatus.unresolved,
                  label: Text(l10n.unresolved),
                  icon: const Icon(Icons.remove_done_rounded),
                ),
                ButtonSegment<ReportResolveStatus>(
                  value: ReportResolveStatus.all,
                  label: Text(l10n.all),
                  icon: const Icon(Icons.list_alt_rounded),
                ),
              ],
              selected: <ReportResolveStatus>{status},
              onSelectionChanged: (Set<ReportResolveStatus> newSelection) {
                HapticFeedback.mediumImpact();
                setState(() => status = newSelection.first);
              },
            ),
            const SizedBox(height: 16.0),
            Text(l10n.community, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8.0),
            CommunitySelector(
              account: context.read<ProfileBloc>().state.account,
              community: community,
              onCommunitySelected: (ThunderCommunity c) {
                setState(() => community = c);
              },
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: TextButton(
                onPressed: () => widget.onSubmit(status, community),
                child: Text(l10n.apply),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
