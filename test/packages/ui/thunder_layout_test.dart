import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:thunder/packages/ui/ui.dart';

import '../../helpers/ui_test_harness.dart';

void main() {
  testWidgets('ThunderBottomSheetHeader renders title, subtitle, and slots', (tester) async {
    await pumpUiWidget(
      tester,
      const ThunderBottomSheetHeader(
        title: 'Header',
        subtitle: 'Subtitle',
        leading: Icon(Icons.arrow_back),
        trailing: Icon(Icons.close),
      ),
    );

    expect(find.text('Header'), findsOneWidget);
    expect(find.text('Subtitle'), findsOneWidget);
    expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    expect(find.byIcon(Icons.close), findsOneWidget);
  });

  testWidgets('ThunderBottomSheetNavigator navigates forward, back, and close', (tester) async {
    var closed = false;

    await pumpUiWidget(
      tester,
      ThunderBottomSheetNavigator<int>(
        initialPage: 1,
        titleBuilder: (_, page) => 'Page $page',
        onClose: () => closed = true,
        pageBuilder: (_, page, goTo, goBack) {
          return Column(
            children: [
              Text('Body $page'),
              TextButton(onPressed: () => goTo(page + 1), child: const Text('Next')),
              TextButton(onPressed: goBack, child: const Text('Back from body')),
            ],
          );
        },
      ),
    );

    expect(find.text('Page 1'), findsOneWidget);
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.text('Page 2'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.arrow_back_rounded));
    await tester.pumpAndSettle();
    expect(find.text('Page 1'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pumpAndSettle();
    expect(closed, isTrue);
  });

  testWidgets('ThunderConditionalParent applies true, false, and null builders', (tester) async {
    await pumpUiWidget(
      tester,
      Column(
        children: [
          ThunderConditionalParent(
            condition: true,
            parentBuilder: (child) => DecoratedBox(decoration: const BoxDecoration(color: Colors.red), child: child),
            child: const Text('True child'),
          ),
          ThunderConditionalParent(
            condition: false,
            parentBuilder: (child) => DecoratedBox(decoration: const BoxDecoration(color: Colors.red), child: child),
            parentBuilderElse: (child) => Padding(padding: const EdgeInsets.all(4), child: child),
            child: const Text('False child'),
          ),
          ThunderConditionalParent(
            condition: true,
            parentBuilder: (child) => child,
            child: const Text('Plain child'),
          ),
        ],
      ),
    );

    expect(find.byType(DecoratedBox), findsOneWidget);
    expect(find.byType(Padding), findsWidgets);
    expect(find.text('Plain child'), findsOneWidget);
  });

  testWidgets('ThunderDivider renders box and sliver variants', (tester) async {
    await pumpUiWidget(
      tester,
      const Column(
        children: [
          ThunderDivider(sliver: false, padding: false, thickness: 3),
          Expanded(
            child: CustomScrollView(
              slivers: [
                ThunderDivider(sliver: true),
              ],
            ),
          ),
        ],
      ),
    );

    expect(find.byType(Divider), findsNWidgets(2));
    expect(find.byType(SliverToBoxAdapter), findsOneWidget);
  });

  testWidgets('ThunderMarquee renders child in requested scroll direction', (tester) async {
    await pumpUiWidget(
      tester,
      const SizedBox(
        height: 40,
        child: ThunderMarquee(
          autoRepeat: false,
          direction: Axis.vertical,
          pauseDuration: Duration.zero,
          animationDuration: Duration(milliseconds: 1),
          backDuration: Duration(milliseconds: 1),
          child: Text('Scrolling child'),
        ),
      ),
    );

    expect(find.text('Scrolling child'), findsOneWidget);
    final scroll = tester.widget<SingleChildScrollView>(find.byType(SingleChildScrollView));
    expect(scroll.scrollDirection, Axis.vertical);

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1));
  });

  testWidgets('ThunderMetadataRow animates optional secondary segment', (tester) async {
    await pumpUiWidget(tester, const ThunderMetadataRow(primary: 'Primary', secondary: 'Secondary'));

    expect(find.text('Primary'), findsOneWidget);
    expect(find.text('Secondary'), findsOneWidget);
    expect(find.text('•'), findsOneWidget);
  });

  testWidgets('ThunderSectionTitle, divider, and sidebar stat render configured text', (tester) async {
    await pumpUiWidget(
      tester,
      const Column(
        children: [
          ThunderSectionTitle(title: 'Section', description: 'Description'),
          Row(children: [ThunderSectionDivider(indent: 7)]),
          ThunderSidebarStat(icon: Icons.people, label: '12 users'),
        ],
      ),
    );

    expect(find.text('Section'), findsOneWidget);
    expect(find.text('Description'), findsOneWidget);
    expect(find.text('12 users'), findsOneWidget);
    expect(find.byIcon(Icons.people), findsOneWidget);
  });

  testWidgets('ThunderSelectableTileShell reflects selection and tap behavior', (tester) async {
    var tapped = false;

    await pumpUiWidget(
      tester,
      ThunderSelectableTileShell(
        selected: true,
        reordering: true,
        onTap: () => tapped = true,
        child: const Text('Selectable'),
      ),
    );

    await tester.tap(find.text('Selectable'));
    await tester.pump();

    expect(tapped, isTrue);
    expect(find.text('Selectable'), findsOneWidget);
  });

  testWidgets('ThunderSliverAdapter wraps child only in sliver mode', (tester) async {
    await pumpUiWidget(
      tester,
      const Column(
        children: [
          ThunderSliverAdapter(sliver: false, child: Text('Box child')),
          Expanded(
            child: CustomScrollView(
              slivers: [
                ThunderSliverAdapter(sliver: true, fillRemaining: true, child: Text('Sliver child')),
              ],
            ),
          ),
        ],
      ),
    );

    expect(find.text('Box child'), findsOneWidget);
    expect(find.text('Sliver child'), findsOneWidget);
    expect(find.byType(SliverFillRemaining), findsOneWidget);
  });

  testWidgets('ThunderTopBarScrim hides when not visible and positions when visible', (tester) async {
    await pumpUiWidget(
      tester,
      const Stack(
        children: [
          ThunderTopBarScrim(visible: false),
          ThunderTopBarScrim(visible: true, color: Colors.purple),
        ],
      ),
    );

    expect(find.byType(Positioned), findsOneWidget);
    expect(find.byType(SizedBox), findsWidgets);
  });
}
