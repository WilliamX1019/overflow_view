import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:overflow_view/src/widgets/overflow_view.dart';
import 'package:overflow_view/src/rendering/overflow_view.dart';
import 'package:flutter/rendering.dart';

void main() {
  testWidgets('OverflowView Collapsed Gap Repro', (WidgetTester tester) async {
    // We want to force overflow on the last line.
    // 3 lines limit.
    // Line 1: 'Item 1'
    // Line 2: 'Item 2'
    // Line 3: 'Item 3', 'Item Overflow' -> overflow

    final List<String> tags = [
      'Line 1 Item',
      'Line 2 Item',
      'Line 3 Item',
      'Overflow Trigger',
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 100, // Narrow width to force 1 item per line roughly
              child: OverflowView.wrap(
                maxRun: 3, // Limit to 3 lines
                spacing: 10,
                runSpacing: 10,
                overflowWidget:
                    SizedBox(width: 20, height: 20, child: Text('More')),
                children: tags
                    .map((t) => SizedBox(width: 80, height: 20, child: Text(t)))
                    .toList(),
              ),
            ),
          ),
        ),
      ),
    );

    // Verify layout
    final RenderOverflowView renderBox =
        tester.renderObject(find.byType(OverflowView));
    print('OverflowView Size: ${renderBox.size}');

    // Check children positions
    // We expect:
    // Child 0: Line 1
    // Child 1: Line 2
    // Child 2: Line 3 (or replaced by overflow?)
    // OverflowIndicator: Line 3

    renderBox.visitChildren((child) {
      final pd = child.parentData as OverflowViewParentData;
      if (!pd.offstage) {
        print('Visible Child: $child, Offset: ${pd.offset}');
      }
    });
  });
}
