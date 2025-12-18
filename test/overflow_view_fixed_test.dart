import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:overflow_view/overflow_view.dart';

void main() {
  testWidgets('OverflowView.wrap handles overflow without LayoutBuilder error',
      (tester) async {
    // This test reproduces the scenario that previously caused _debugRelayoutBoundaryAlreadyMarkedNeedsLayout
    // by triggering a layout pass where an overflow is needed.

    await tester.pumpWidget(
      MaterialApp(
        home: Center(
          child: SizedBox(
            width: 200, // Constrained width to force wrapping and overflow
            child: OverflowView.wrap(
              maxRun: 2, // Limit runs to force overflow
              spacing: 10,
              runSpacing: 10,
              overflowWidget: Container(
                width: 30,
                height: 30,
                color: Colors.red,
                child: const Center(child: Text('+')),
              ),
              children: List.generate(20, (index) {
                return Container(
                  width: 40,
                  height: 40,
                  color: Colors.blue,
                  child: Center(child: Text('$index')),
                );
              }),
            ),
          ),
        ),
      ),
    );

    // Initial pump
    await tester.pumpAndSettle();

    // Verification:
    // 1. We should see some blue boxes (children)
    expect(find.text('0'), findsOneWidget);
    // 2. We should see the red overflow indicator
    expect(find.text('+'), findsOneWidget);
    // 3. We should NOT see all children (e.g., '19' should be hidden)
    expect(find.text('19'), findsNothing);

    // Verify no errors (implicit by reaching here without crash)
  });
}
