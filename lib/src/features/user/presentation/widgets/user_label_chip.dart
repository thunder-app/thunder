import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:thunder/src/features/user/user.dart';
import 'package:thunder/src/features/settings/api.dart';
import 'package:thunder/src/foundation/primitives/primitives.dart';
import 'package:thunder/src/shared/theme/color_utils.dart';
import 'package:thunder/packages/ui/ui.dart';

/// A widget that displays a user's label in a chip format.
class UserLabelChip extends StatelessWidget {
  /// The username for which to fetch and display the label.
  ///
  /// If there is no label for the user, an empty widget will be displayed.
  final String username;

  const UserLabelChip({super.key, required this.username});

  Future<UserLabel?> fetchUserLabel() async {
    return await UserLabel.fetchUserLabel(username);
  }

  @override
  Widget build(BuildContext context) {
    final metadataFontSizeScale = context.select<ThemePreferencesCubit, FontScale>((cubit) => cubit.state.metadataFontSizeScale);
    final color = getBackgroundColor(context);

    return FutureBuilder<UserLabel?>(
      future: fetchUserLabel(),
      builder: (context, AsyncSnapshot<UserLabel?> snapshot) {
        if (snapshot.hasError) return const SizedBox.shrink();

        final label = snapshot.data?.label;
        if (label == null || label.isEmpty) return const SizedBox.shrink();

        return Container(
          margin: const EdgeInsets.only(top: 6.0),
          decoration: BoxDecoration(
            color: color,
            borderRadius: const BorderRadius.all(Radius.circular(5.0)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5.0),
            child: ThunderScalableText(
              label,
              textScaleFactor: metadataFontSizeScale.textScaleFactor,
            ),
          ),
        );
      },
    );
  }
}
