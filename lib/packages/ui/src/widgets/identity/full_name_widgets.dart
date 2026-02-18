import 'package:flutter/material.dart';

import 'package:auto_size_text/auto_size_text.dart';

import 'package:thunder/packages/ui/src/models/identity/name_style.dart';
import 'package:thunder/packages/ui/src/utils/identity/name_formatting.dart';

/// Package-generic full-name widget for users.
class UserFullNameWidget extends StatelessWidget {
  const UserFullNameWidget({
    super.key,
    this.name,
    this.displayName,
    this.instance,
    required this.separator,
    required this.useDisplayName,
    required this.userNameThickness,
    required this.userNameColor,
    required this.instanceNameThickness,
    required this.instanceNameColor,
    this.textStyle,
    this.includeInstance = true,
    this.textScaleFactor = 1.0,
    this.autoSize = false,
    this.transformColor,
  });

  final String? name;
  final String? displayName;
  final String? instance;
  final FullNameSeparator separator;
  final NameThickness userNameThickness;
  final NameColor userNameColor;
  final NameThickness instanceNameThickness;
  final NameColor instanceNameColor;
  final TextStyle? textStyle;
  final bool includeInstance;
  final bool useDisplayName;
  final double textScaleFactor;
  final bool autoSize;
  final Color? Function(Color?)? transformColor;

  @override
  Widget build(BuildContext context) {
    final prefix = formatUserFullNamePrefix(
      name,
      displayName,
      separator: separator,
      useDisplayName: useDisplayName,
    );
    final suffix = formatUserFullNameSuffix(instance, separator: separator);

    final resolvedTextStyle = textStyle ?? Theme.of(context).textTheme.bodyMedium!;
    final applyColor = transformColor ?? (color) => color;
    final textScaler = MediaQuery.textScalerOf(context);
    final baseFontSize = resolvedTextStyle.fontSize ?? Theme.of(context).textTheme.bodyMedium?.fontSize ?? 14;
    final scaledFontSize = textScaler.scale(baseFontSize * textScaleFactor);

    final textSpan = TextSpan(
      children: [
        TextSpan(
          text: prefix,
          style: resolvedTextStyle.copyWith(
            fontWeight: userNameThickness.toWeight(),
            color: applyColor(userNameColor.toColor(context)),
            fontSize: scaledFontSize,
          ),
        ),
        if (includeInstance)
          TextSpan(
            text: suffix,
            style: resolvedTextStyle.copyWith(
              fontWeight: instanceNameThickness.toWeight(),
              color: applyColor(instanceNameColor.toColor(context)),
              fontSize: scaledFontSize,
            ),
          ),
      ],
    );

    return autoSize
        ? AutoSizeText.rich(
            softWrap: false,
            maxLines: 1,
            overflow: TextOverflow.fade,
            style: resolvedTextStyle,
            textSpan,
          )
        : Text.rich(
            softWrap: false,
            overflow: TextOverflow.fade,
            style: resolvedTextStyle,
            textScaler: TextScaler.noScaling,
            textSpan,
          );
  }
}

/// Package-generic full-name widget for communities.
class CommunityFullNameWidget extends StatelessWidget {
  const CommunityFullNameWidget({
    super.key,
    this.name,
    this.displayName,
    this.instance,
    required this.separator,
    required this.useDisplayName,
    required this.communityNameThickness,
    required this.communityNameColor,
    required this.instanceNameThickness,
    required this.instanceNameColor,
    this.textStyle,
    this.includeInstance = true,
    this.textScaleFactor = 1.0,
    this.autoSize = false,
    this.transformColor,
  });

  final String? name;
  final String? displayName;
  final String? instance;
  final FullNameSeparator separator;
  final NameThickness communityNameThickness;
  final NameColor communityNameColor;
  final NameThickness instanceNameThickness;
  final NameColor instanceNameColor;
  final TextStyle? textStyle;
  final bool includeInstance;
  final bool useDisplayName;
  final double textScaleFactor;
  final bool autoSize;
  final Color? Function(Color?)? transformColor;

  @override
  Widget build(BuildContext context) {
    final prefix = formatCommunityFullNamePrefix(
      name,
      displayName,
      separator: separator,
      useDisplayName: useDisplayName,
    );
    final suffix = formatCommunityFullNameSuffix(instance, separator: separator);

    final resolvedTextStyle = textStyle ?? Theme.of(context).textTheme.bodyMedium!;
    final applyColor = transformColor ?? (color) => color;
    final textScaler = MediaQuery.textScalerOf(context);
    final baseFontSize = resolvedTextStyle.fontSize ?? Theme.of(context).textTheme.bodyMedium?.fontSize ?? 14;
    final scaledFontSize = textScaler.scale(baseFontSize * textScaleFactor);

    final textSpan = TextSpan(
      children: [
        TextSpan(
          text: prefix,
          style: resolvedTextStyle.copyWith(
            fontWeight: communityNameThickness.toWeight(),
            color: applyColor(communityNameColor.toColor(context)),
            fontSize: scaledFontSize,
          ),
        ),
        if (includeInstance)
          TextSpan(
            text: suffix,
            style: resolvedTextStyle.copyWith(
              fontWeight: instanceNameThickness.toWeight(),
              color: applyColor(instanceNameColor.toColor(context)),
              fontSize: scaledFontSize,
            ),
          ),
      ],
    );

    return autoSize
        ? AutoSizeText.rich(
            softWrap: false,
            maxLines: 1,
            overflow: TextOverflow.fade,
            style: resolvedTextStyle,
            textSpan,
          )
        : Text.rich(
            softWrap: false,
            overflow: TextOverflow.fade,
            style: resolvedTextStyle,
            textScaler: TextScaler.noScaling,
            textSpan,
          );
  }
}
