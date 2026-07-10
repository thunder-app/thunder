import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:thunder/src/core/config/global_context.dart';
import 'package:thunder/packages/ui/ui.dart';
import 'package:thunder/src/features/settings/api.dart';
import 'package:thunder/src/core/domain/domain.dart';

/// Footer shown when a paginated feed has no more items to load.
class FeedReachedEnd extends StatelessWidget {
  const FeedReachedEnd({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = GlobalContext.l10n;
    final theme = Theme.of(context);

    final metadataFontSizeScale = context.select<ThemePreferencesCubit, FontScale>((cubit) => cubit.state.metadataFontSizeScale);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          color: theme.dividerColor.withValues(alpha: 0.1),
          padding: const EdgeInsets.symmetric(vertical: 32.0),
          child: ThunderScalableText(
            l10n.reachedTheBottom,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleSmall,
            textScaleFactor: metadataFontSizeScale.textScaleFactor,
          ),
        ),
        const SizedBox(height: 160.0),
      ],
    );
  }
}
