import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:thunder/core/enums/user_type.dart';
import 'package:thunder/core/theme/bloc/theme_bloc.dart';
import 'package:thunder/user/utils/user_groups.dart';

import '../widgets/base_widget.dart';

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  group('Test user group logic', () {
    testWidgets('fetchUsernameDescriptor returns empty string if user is in no groups', (tester) async {
      await tester.pumpWidget(const BaseWidget());

      String result = fetchUserGroupDescriptor([], null);
      expect(result, '');
    });

    testWidgets('fetchUsernameDescriptor returns correct string for a single group', (tester) async {
      await tester.pumpWidget(const BaseWidget());

      String result = fetchUserGroupDescriptor([UserType.admin], null);
      expect(result, ' (Admin)');
    });

    testWidgets('fetchUsernameDescriptor returns correct string for multiple groups', (tester) async {
      await tester.pumpWidget(const BaseWidget());

      String result = fetchUserGroupDescriptor([UserType.admin, UserType.moderator], null);
      expect(result, ' (Admin, Moderator)');
    });

    testWidgets('fetchUsernameColor returns no color if user is in no groups', (tester) async {
      await tester.pumpWidget(BaseWidget(
        child: BlocProvider(
          create: (context) => ThemeBloc(),
          child: Builder(builder: (context) {
            Color? color = fetchUserGroupColor(context, []);

            expect(color, isNull);
            return Container();
          }),
        ),
      ));
    });

    testWidgets('fetchUsernameColor returns correct color if user is in a single group', (tester) async {
      await tester.pumpWidget(BaseWidget(
        child: BlocProvider(
          create: (context) => ThemeBloc(),
          child: Builder(builder: (context) {
            final theme = Theme.of(context);

            Color? color = fetchUserGroupColor(context, [UserType.moderator]);
            Color? expectedColor = HSLColor.fromColor(
              Color.alphaBlend(theme.colorScheme.primaryContainer.withOpacity(0.35), UserType.moderator.color),
            ).withLightness(0.85).toColor();

            expect(color, expectedColor);
            return Container();
          }),
        ),
      ));
    });

    testWidgets('fetchUsernameColor returns correct color if user is in multiple groups', (tester) async {
      await tester.pumpWidget(BaseWidget(
        child: BlocProvider(
          create: (context) => ThemeBloc(),
          child: Builder(builder: (context) {
            final theme = Theme.of(context);

            // The order of precedence is op -> self -> admin -> moderator -> bot
            Color? color = fetchUserGroupColor(context, [UserType.moderator, UserType.admin, UserType.self]);
            Color? expectedColor = HSLColor.fromColor(
              Color.alphaBlend(theme.colorScheme.primaryContainer.withOpacity(0.35), UserType.self.color),
            ).withLightness(0.85).toColor();

            expect(color, expectedColor);
            return Container();
          }),
        ),
      ));
    });
  });
}
