import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:thunder/packages/ui/ui.dart';

import '../../helpers/ui_test_harness.dart';

void main() {
  test('ThunderAvatarData preserves configuration', () {
    const data = ThunderAvatarData(
      imageUrl: 'https://example.com/avatar.png',
      radius: 24,
      fallbackLabel: 'alice',
      semanticLabel: 'Alice avatar',
    );

    expect(data.imageUrl, 'https://example.com/avatar.png');
    expect(data.radius, 24);
    expect(data.fallbackLabel, 'alice');
    expect(data.semanticLabel, 'Alice avatar');
  });

  testWidgets('ThunderAvatar renders uppercase fallback when url is absent', (tester) async {
    await pumpUiWidget(
      tester,
      const ThunderAvatar(
        data: ThunderAvatarData(fallbackLabel: 'alice', semanticLabel: 'Alice avatar'),
      ),
    );

    expect(find.byType(CircleAvatar), findsOneWidget);
    expect(find.text('A'), findsOneWidget);
    expect(find.bySemanticsLabel('Alice avatar'), findsOneWidget);
  });

  testWidgets('ThunderAvatar renders empty fallback for blank labels', (tester) async {
    await pumpUiWidget(
      tester,
      const ThunderAvatar(data: ThunderAvatarData(fallbackLabel: '')),
    );

    expect(find.byType(CircleAvatar), findsOneWidget);
    expect(find.text(''), findsOneWidget);
  });

  testWidgets('ThunderScalableText applies scale, overflow, maxLines, and semantics', (tester) async {
    await pumpUiWidget(
      tester,
      const ThunderScalableText(
        'Scaled text',
        textScaleFactor: 1.5,
        semanticsLabel: 'scaled semantics',
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
    );

    final text = tester.widget<Text>(find.text('Scaled text'));
    expect(text.maxLines, 1);
    expect(text.overflow, TextOverflow.ellipsis);
    expect(text.textScaler, TextScaler.noScaling);
    expect(find.bySemanticsLabel('scaled semantics'), findsOneWidget);
  });

  testWidgets('ThunderIconLabel returns only icon when label is null or empty', (tester) async {
    await pumpUiWidget(
      tester,
      const Column(
        children: [
          ThunderIconLabel(icon: Icon(Icons.star), label: ''),
          ThunderIconLabel(icon: Icon(Icons.favorite)),
        ],
      ),
    );

    expect(find.byIcon(Icons.star), findsOneWidget);
    expect(find.byIcon(Icons.favorite), findsOneWidget);
    expect(find.byType(Row), findsNothing);
  });

  testWidgets('ThunderIconLabel renders scaled label with custom gap', (tester) async {
    await pumpUiWidget(
      tester,
      const ThunderIconLabel(
        icon: Icon(Icons.shield),
        label: 'Moderator',
        gap: 12,
        semanticsLabel: 'moderator label',
      ),
    );

    expect(find.byType(Row), findsOneWidget);
    expect(find.text('Moderator'), findsOneWidget);
    expect(find.bySemanticsLabel('moderator label'), findsOneWidget);
  });

  test('ThunderIcon constants use the Thunder icon font', () {
    expect(ThunderIcon.shield.fontFamily, 'Thunder');
    expect(ThunderIcon.robot.codePoint, 0xf544);
  });
}
