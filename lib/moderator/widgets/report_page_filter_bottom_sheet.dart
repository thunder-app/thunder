import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:thunder/core/models/community/models.dart';

import 'package:thunder/utils/global_context.dart';
import 'package:thunder/community/pages/create_post_page.dart';

enum ReportResolveStatus { unresolved, all }

/// A [BottomSheet] that allows the user to filter reports by status and community
/// When the submit button is pressed, the [onSubmit] function is called with the selected [ReportResolveStatus] and [CommunityView] if any.
class ReportFilterBottomSheet extends StatefulWidget {
  const ReportFilterBottomSheet({super.key, required this.status, required this.onSubmit});

  /// The status to filter by
  final ReportResolveStatus status;

  /// The function to call when the submit button is pressed
  final void Function(ReportResolveStatus reportResolveStatus, CommunityView? communityView) onSubmit;

  @override
  State<ReportFilterBottomSheet> createState() => _ReportFilterBottomSheetState();
}

class _ReportFilterBottomSheetState extends State<ReportFilterBottomSheet> {
  /// The status to filter by
  ReportResolveStatus status = ReportResolveStatus.all;

  /// The community to filter by
  CommunityView? communityView;

  @override
  void initState() {
    super.initState();
    status = widget.status;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(GlobalContext.context)!;

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
              communityId: communityView?.community.id,
              communityView: communityView,
              onCommunitySelected: (CommunityView cv) {
                setState(() => communityView = cv);
              },
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: TextButton(
                onPressed: () => widget.onSubmit(status, communityView),
                child: Text(l10n.apply),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
