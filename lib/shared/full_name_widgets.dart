import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thunder/core/enums/font_scale.dart';
import 'package:thunder/core/enums/full_name.dart';
import 'package:thunder/thunder/bloc/thunder_bloc.dart';

class UserFullNameWidget extends StatelessWidget {
  final BuildContext? outerContext;
  final String? name;
  final String? instance;
  final FullNameSeparator? userSeparator;
  final bool? weightUserName;
  final bool? weightInstanceName;
  final bool? colorizeUserName;
  final bool? colorizeInstanceName;
  final TextStyle? textStyle;
  final ColorScheme? colorScheme;
  final bool includeInstance;
  final FontScale? fontScale;

  const UserFullNameWidget(
    this.outerContext,
    this.name,
    this.instance, {
    super.key,
    this.userSeparator,
    this.weightUserName,
    this.weightInstanceName,
    this.colorizeUserName,
    this.colorizeInstanceName,
    this.textStyle,
    this.colorScheme,
    this.includeInstance = true,
    this.fontScale,
  })  : assert(outerContext != null || (userSeparator != null && weightUserName != null && weightInstanceName != null && colorizeUserName != null && colorizeInstanceName != null)),
        assert(outerContext != null || (textStyle != null && colorScheme != null));

  @override
  Widget build(BuildContext context) {
    String prefix = generateUserFullNamePrefix(outerContext, name, userSeparator: userSeparator);
    String suffix = generateUserFullNameSuffix(outerContext, instance, userSeparator: userSeparator);
    bool weightUserName = this.weightUserName ?? outerContext!.read<ThunderBloc>().state.userFullNameWeightUserName;
    bool weightInstanceName = this.weightInstanceName ?? outerContext!.read<ThunderBloc>().state.userFullNameWeightInstanceName;
    bool colorizeUserName = this.colorizeUserName ?? outerContext!.read<ThunderBloc>().state.userFullNameColorizeUserName;
    bool colorizeInstanceName = this.colorizeInstanceName ?? outerContext!.read<ThunderBloc>().state.userFullNameColorizeInstanceName;
    TextStyle? textStyle = this.textStyle ?? Theme.of(outerContext!).textTheme.bodyMedium;
    ColorScheme colorScheme = this.colorScheme ?? Theme.of(outerContext!).colorScheme;

    return Text.rich(
      softWrap: false,
      overflow: TextOverflow.fade,
      style: textStyle,
      textScaler: TextScaler.noScaling,
      TextSpan(
        children: [
          TextSpan(
            text: prefix,
            style: textStyle!.copyWith(
              fontWeight: weightUserName
                  ? FontWeight.w500
                  : weightInstanceName
                      ? FontWeight.w300
                      : null,
              color: colorizeUserName ? colorScheme.primary : null,
              fontSize:
                  outerContext == null ? null : MediaQuery.textScalerOf(context).scale((textStyle.fontSize ?? textStyle.fontSize!) * (fontScale?.textScaleFactor ?? FontScale.base.textScaleFactor)),
            ),
          ),
          if (includeInstance == true)
            TextSpan(
              text: suffix,
              style: textStyle.copyWith(
                fontWeight: weightInstanceName
                    ? FontWeight.w500
                    : weightUserName
                        ? FontWeight.w300
                        : null,
                color: colorizeInstanceName ? colorScheme.primary : null,
                fontSize:
                    outerContext == null ? null : MediaQuery.textScalerOf(context).scale((textStyle.fontSize ?? textStyle.fontSize!) * (fontScale?.textScaleFactor ?? FontScale.base.textScaleFactor)),
              ),
            ),
        ],
      ),
    );
  }
}

class CommunityFullNameWidget extends StatelessWidget {
  final BuildContext? outerContext;
  final String? name;
  final String? instance;
  final FullNameSeparator? communitySeparator;
  final bool? weightCommunityName;
  final bool? weightInstanceName;
  final bool? colorizeCommunityName;
  final bool? colorizeInstanceName;
  final TextStyle? textStyle;
  final ColorScheme? colorScheme;
  final bool includeInstance;
  final FontScale? fontScale;

  const CommunityFullNameWidget(
    this.outerContext,
    this.name,
    this.instance, {
    super.key,
    this.communitySeparator,
    this.weightCommunityName,
    this.weightInstanceName,
    this.colorizeCommunityName,
    this.colorizeInstanceName,
    this.textStyle,
    this.colorScheme,
    this.includeInstance = true,
    this.fontScale,
  })  : assert(outerContext != null || (communitySeparator != null && weightCommunityName != null && weightInstanceName != null && colorizeCommunityName != null && colorizeInstanceName != null)),
        assert(outerContext != null || (textStyle != null && colorScheme != null));

  @override
  Widget build(BuildContext context) {
    String prefix = generateCommunityFullNamePrefix(outerContext, name, communitySeparator: communitySeparator);
    String suffix = generateCommunityFullNameSuffix(outerContext, instance, communitySeparator: communitySeparator);
    bool weightCommunityName = this.weightCommunityName ?? outerContext!.read<ThunderBloc>().state.communityFullNameWeightCommunityName;
    bool weightInstanceName = this.weightInstanceName ?? outerContext!.read<ThunderBloc>().state.communityFullNameWeightInstanceName;
    bool colorizeCommunityName = this.colorizeCommunityName ?? outerContext!.read<ThunderBloc>().state.communityFullNameColorizeCommunityName;
    bool colorizeInstanceName = this.colorizeInstanceName ?? outerContext!.read<ThunderBloc>().state.communityFullNameColorizeInstanceName;
    TextStyle? textStyle = this.textStyle ?? Theme.of(outerContext!).textTheme.bodyMedium;
    ColorScheme colorScheme = this.colorScheme ?? Theme.of(outerContext!).colorScheme;

    return Text.rich(
      softWrap: false,
      overflow: TextOverflow.fade,
      style: textStyle,
      textScaler: TextScaler.noScaling,
      TextSpan(
        children: [
          TextSpan(
            text: prefix,
            style: textStyle!.copyWith(
              fontWeight: weightCommunityName
                  ? FontWeight.w500
                  : weightInstanceName
                      ? FontWeight.w300
                      : null,
              color: colorizeCommunityName ? colorScheme.primary : null,
              fontSize:
                  outerContext == null ? null : MediaQuery.textScalerOf(context).scale((textStyle.fontSize ?? textStyle.fontSize!) * (fontScale?.textScaleFactor ?? FontScale.base.textScaleFactor)),
            ),
          ),
          if (includeInstance == true)
            TextSpan(
              text: suffix,
              style: textStyle.copyWith(
                fontWeight: weightInstanceName
                    ? FontWeight.w500
                    : weightCommunityName
                        ? FontWeight.w300
                        : null,
                color: colorizeInstanceName ? colorScheme.primary : null,
                fontSize:
                    outerContext == null ? null : MediaQuery.textScalerOf(context).scale((textStyle.fontSize ?? textStyle.fontSize!) * (fontScale?.textScaleFactor ?? FontScale.base.textScaleFactor)),
              ),
            ),
        ],
      ),
    );
  }
}
