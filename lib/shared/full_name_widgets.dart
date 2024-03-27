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
  final NameThickness? userNameThickness;
  final NameColor? userNameColor;
  final NameThickness? instanceNameThickness;
  final NameColor? instanceNameColor;
  final TextStyle? textStyle;
  final bool includeInstance;
  final FontScale? fontScale;
  final Color? Function(Color?)? transformColor;

  const UserFullNameWidget(
    this.outerContext,
    this.name,
    this.instance, {
    super.key,
    this.userSeparator,
    this.userNameThickness,
    this.userNameColor,
    this.instanceNameThickness,
    this.instanceNameColor,
    this.textStyle,
    this.includeInstance = true,
    this.fontScale,
    this.transformColor,
  })  : assert(outerContext != null || (userSeparator != null && userNameThickness != null && userNameColor != null && instanceNameThickness != null && instanceNameColor != null)),
        assert(outerContext != null || textStyle != null);

  @override
  Widget build(BuildContext context) {
    String prefix = generateUserFullNamePrefix(outerContext, name, userSeparator: userSeparator);
    String suffix = generateUserFullNameSuffix(outerContext, instance, userSeparator: userSeparator);
    NameThickness userNameThickness = this.userNameThickness ?? outerContext!.read<ThunderBloc>().state.userFullNameUserNameThickness;
    NameColor userNameColor = this.userNameColor ?? outerContext!.read<ThunderBloc>().state.userFullNameUserNameColor;
    NameThickness instanceNameThickness = this.instanceNameThickness ?? outerContext!.read<ThunderBloc>().state.userFullNameInstanceNameThickness;
    NameColor instanceNameColor = this.instanceNameColor ?? outerContext!.read<ThunderBloc>().state.userFullNameInstanceNameColor;
    TextStyle? textStyle = this.textStyle ?? Theme.of(outerContext!).textTheme.bodyMedium;
    Color? Function(Color?) transformColor = this.transformColor ?? (color) => color;

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
              fontWeight: userNameThickness.toWeight(),
              color: transformColor(userNameColor.color == NameColor.defaultColor ? textStyle.color : userNameColor.toColor(context)),
              fontSize:
                  outerContext == null ? null : MediaQuery.textScalerOf(context).scale((textStyle.fontSize ?? textStyle.fontSize!) * (fontScale?.textScaleFactor ?? FontScale.base.textScaleFactor)),
            ),
          ),
          if (includeInstance == true)
            TextSpan(
              text: suffix,
              style: textStyle.copyWith(
                fontWeight: instanceNameThickness.toWeight(),
                color: transformColor(instanceNameColor.color == NameColor.defaultColor ? textStyle.color : instanceNameColor.toColor(context)),
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
  final NameThickness? communityNameThickness;
  final NameColor? communityNameColor;
  final NameThickness? instanceNameThickness;
  final NameColor? instanceNameColor;
  final TextStyle? textStyle;
  final bool includeInstance;
  final FontScale? fontScale;
  final Color? Function(Color?)? transformColor;

  const CommunityFullNameWidget(
    this.outerContext,
    this.name,
    this.instance, {
    super.key,
    this.communitySeparator,
    this.communityNameThickness,
    this.communityNameColor,
    this.instanceNameThickness,
    this.instanceNameColor,
    this.textStyle,
    this.includeInstance = true,
    this.fontScale,
    this.transformColor,
  })  : assert(outerContext != null || (communitySeparator != null && communityNameThickness != null && communityNameColor != null && instanceNameThickness != null && instanceNameColor != null)),
        assert(outerContext != null || textStyle != null);

  @override
  Widget build(BuildContext context) {
    String prefix = generateCommunityFullNamePrefix(outerContext, name, communitySeparator: communitySeparator);
    String suffix = generateCommunityFullNameSuffix(outerContext, instance, communitySeparator: communitySeparator);
    NameThickness communityNameThickness = this.communityNameThickness ?? outerContext!.read<ThunderBloc>().state.communityFullNameCommunityNameThickness;
    NameColor communityNameColor = this.communityNameColor ?? outerContext!.read<ThunderBloc>().state.communityFullNameCommunityNameColor;
    NameThickness instanceNameThickness = this.instanceNameThickness ?? outerContext!.read<ThunderBloc>().state.communityFullNameInstanceNameThickness;
    NameColor instanceNameColor = this.instanceNameColor ?? outerContext!.read<ThunderBloc>().state.communityFullNameInstanceNameColor;
    TextStyle? textStyle = this.textStyle ?? Theme.of(outerContext!).textTheme.bodyMedium;
    Color? Function(Color?) transformColor = this.transformColor ?? (color) => color;

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
              fontWeight: communityNameThickness.toWeight(),
              color: transformColor(communityNameColor.color == NameColor.defaultColor ? textStyle.color : communityNameColor.toColor(context)),
              fontSize:
                  outerContext == null ? null : MediaQuery.textScalerOf(context).scale((textStyle.fontSize ?? textStyle.fontSize!) * (fontScale?.textScaleFactor ?? FontScale.base.textScaleFactor)),
            ),
          ),
          if (includeInstance == true)
            TextSpan(
              text: suffix,
              style: textStyle.copyWith(
                fontWeight: instanceNameThickness.toWeight(),
                color: transformColor(instanceNameColor.color == NameColor.defaultColor ? textStyle.color : instanceNameColor.toColor(context)),
                fontSize:
                    outerContext == null ? null : MediaQuery.textScalerOf(context).scale((textStyle.fontSize ?? textStyle.fontSize!) * (fontScale?.textScaleFactor ?? FontScale.base.textScaleFactor)),
              ),
            ),
        ],
      ),
    );
  }
}
