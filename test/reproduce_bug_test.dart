import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:overflow_view/overflow_view.dart';

void main() {
  testWidgets('OverflowView.wrap wraps correctly when 2nd child overflows',
      (tester) async {
    // 1. Setup screen width to 500
    tester.view.physicalSize = const Size(500, 500);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    // 2. Pump widget
    // Child 1: 100 width
    // Child 2: 450 width (Total 550 > 500, should wrap)
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: OverflowView.wrap(
          spacing: 0, // Simplified to isolate spacing issue
          children: const [
            SizedBox(width: 100, height: 50, key: Key('child1')),
            SizedBox(width: 450, height: 50, key: Key('child2')),
          ],
          builder: (context, remaining) => const SizedBox(),
        ),
      ),
    );

    // 3. Check positions
    final box1 =
        tester.renderObject(find.byKey(const Key('child1'))) as RenderBox;
    final box2 =
        tester.renderObject(find.byKey(const Key('child2'))) as RenderBox;

    final pos1 = box1.localToGlobal(Offset.zero);
    final pos2 = box2.localToGlobal(Offset.zero);

    print('Child 1 Pos: $pos1');
    print('Child 2 Pos: $pos2');

    // Expect child 2 to be below child 1 (y > child1.y)
    expect(pos2.dy, greaterThan(pos1.dy),
        reason: 'Child 2 should wrap to next line');

    // Also check verify spacing issue if spacing > 0
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: OverflowView.wrap(
          spacing: 12,
          children: const [
            SizedBox(width: 100, height: 50, key: Key('child1')),
            // 100 + 12 = 112.
            // Remaining 388.
            // If Child 2 is 390, it should wrap.
            SizedBox(width: 390, height: 50, key: Key('child2')),
          ],
          builder: (context, remaining) => const SizedBox(),
        ),
      ),
    );

    final box1b =
        tester.renderObject(find.byKey(const Key('child1'))) as RenderBox;
    final box2b =
        tester.renderObject(find.byKey(const Key('child2'))) as RenderBox;

    final pos1b = box1b.localToGlobal(Offset.zero);
    final pos2b = box2b.localToGlobal(Offset.zero);

    print('With Spacing - Child 1 Pos: $pos1b');
    print('With Spacing - Child 2 Pos: $pos2b');

    expect(pos2b.dy, greaterThan(pos1b.dy),
        reason: 'Child 2 should wrap due to spacing');
  });
}
