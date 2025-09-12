import 'package:flutter/rendering.dart';
import 'package:value_layout_builder/value_layout_builder.dart';

import 'dart:math' as math;

/// Parent data for use with [RenderOverflowView].
class OverflowViewParentData extends ContainerBoxParentData<RenderBox> {
  int _runIndex = 0;
  bool? offstage;
}

class _RunMetrics {
  _RunMetrics({
    required this.mainAxisExtent,
    required this.crossAxisExtent,
    required this.childCount,
  });

  final double mainAxisExtent;
  final double crossAxisExtent;
  final int childCount;

  bool get isSingleChild => childCount == 1;
  bool get hasNoChild => childCount == 0;

  _RunMetrics copyWith({
    double? mainAxisExtent,
    double? crossAxisExtent,
    int? childCount,
  }) =>
      _RunMetrics(
        mainAxisExtent: mainAxisExtent ?? this.mainAxisExtent,
        crossAxisExtent: crossAxisExtent ?? this.crossAxisExtent,
        childCount: childCount ?? this.childCount,
      );
}

/// Used with [OverflowView] to define how it should constrain all children and
/// displays them.
enum OverflowViewLayoutBehavior {
  /// All the children will be constrained to have the same size
  /// as the first one.
  ///
  /// Places the children in one line.
  ///
  /// This can be used for an avatar list for example.
  fixed,

  /// Let all children to determine their own size.
  ///
  /// Places the children in one line.
  ///
  /// This can be used for a menu bar for example.
  flexible,

  /// Let all children to determine their own size.
  ///
  /// Displays its children in multiple horizontal or vertical runs.
  wrap,
}

class RenderOverflowView extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, OverflowViewParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, OverflowViewParentData> {
  RenderOverflowView({
    List<RenderBox>? children,
    required Axis direction,
    required WrapAlignment alignment,
    required double spacing,
    required WrapAlignment runAlignment,
    required double runSpacing,
    required WrapCrossAlignment crossAxisAlignment,
    required int? maxRun,
    required int? maxItemPerRun,
    TextDirection? textDirection,
    required VerticalDirection verticalDirection,
    required OverflowViewLayoutBehavior layoutBehavior,
  })  : assert(spacing > double.negativeInfinity && spacing < double.infinity),
        assert(maxRun == null || maxRun > 0),
        assert(maxItemPerRun == null || maxItemPerRun > 0),
        _direction = direction,
        _alignment = alignment,
        _spacing = spacing,
        _runAlignment = runAlignment,
        _runSpacing = runSpacing,
        _crossAxisAlignment = crossAxisAlignment,
        _maxRun = maxRun,
        _maxItemPerRun = maxItemPerRun,
        _textDirection = textDirection,
        _verticalDirection = verticalDirection,
        _layoutBehavior = layoutBehavior {
    addAll(children);
  }

  /// The direction to use as the main axis.
  ///
  /// For example, if [direction] is [Axis.horizontal], the default, the
  /// children are placed adjacent to one another in a horizontal run until the
  /// available horizontal space is consumed, at which point a subsequent
  /// children are placed in a new run vertically adjacent to the previous run.
  Axis get direction => _direction;
  Axis _direction;
  set direction(Axis value) {
    if (_direction != value) {
      _direction = value;
      markNeedsLayout();
    }
  }

  bool get _isHorizontal => direction == Axis.horizontal;

  /// How the children within a run should be placed in the main axis.
  ///
  /// For example, if [alignment] is [WrapAlignment.center], the children in
  /// each run are grouped together in the center of their run in the main axis.
  ///
  /// Defaults to [WrapAlignment.start].
  ///
  /// See also:
  ///
  ///  * [runAlignment], which controls how the runs are placed relative to each
  ///    other in the cross axis.
  ///  * [crossAxisAlignment], which controls how the children within each run
  ///    are placed relative to each other in the cross axis.
  WrapAlignment get alignment => _alignment;
  WrapAlignment _alignment;
  set alignment(WrapAlignment value) {
    if (_alignment == value) return;

    _alignment = value;
    markNeedsLayout();
  }

  /// How much space to place between children in a run in the main axis.
  ///
  /// For example, if [spacing] is 10.0, the children will be spaced at least
  /// 10.0 logical pixels apart in the main axis.
  ///
  /// If there is additional free space in a run (e.g., because the wrap has a
  /// minimum size that is not filled or because some runs are longer than
  /// others), the additional free space will be allocated according to the
  /// [alignment].
  ///
  /// Defaults to 0.0.
  double get spacing => _spacing;
  double _spacing;
  set spacing(double value) {
    assert(value > double.negativeInfinity && value < double.infinity);
    if (_spacing != value) {
      _spacing = value;
      markNeedsLayout();
    }
  }

  /// How the runs themselves should be placed in the cross axis.
  ///
  /// For example, if [runAlignment] is [WrapAlignment.center], the runs are
  /// grouped together in the center of the overall [RenderOverflowView] in the cross
  /// axis.
  ///
  /// Defaults to [WrapAlignment.start].
  ///
  /// See also:
  ///
  ///  * [alignment], which controls how the children within each run are placed
  ///    relative to each other in the main axis.
  ///  * [crossAxisAlignment], which controls how the children within each run
  ///    are placed relative to each other in the cross axis.
  WrapAlignment get runAlignment => _runAlignment;
  WrapAlignment _runAlignment;
  set runAlignment(WrapAlignment value) {
    if (_runAlignment == value) return;

    _runAlignment = value;
    markNeedsLayout();
  }

  /// How much space to place between the runs themselves in the cross axis.
  ///
  /// For example, if [runSpacing] is 10.0, the runs will be spaced at least
  /// 10.0 logical pixels apart in the cross axis.
  ///
  /// If there is additional free space in the overall [RenderOverflowView] (e.g.,
  /// because the wrap has a minimum size that is not filled), the additional
  /// free space will be allocated according to the [runAlignment].
  ///
  /// Defaults to 0.0.
  double get runSpacing => _runSpacing;
  double _runSpacing;
  set runSpacing(double value) {
    assert(value >= 0 && value < double.infinity);

    if (_runSpacing == value) return;

    _runSpacing = value;
    markNeedsLayout();
  }

  /// How the children within a run should be aligned relative to each other in
  /// the cross axis.
  ///
  /// For example, if this is set to [WrapCrossAlignment.end], and the
  /// [direction] is [Axis.horizontal], then the children within each
  /// run will have their bottom edges aligned to the bottom edge of the run.
  ///
  /// Defaults to [WrapCrossAlignment.start].
  ///
  /// See also:
  ///
  ///  * [alignment], which controls how the children within each run are placed
  ///    relative to each other in the main axis.
  ///  * [runAlignment], which controls how the runs are placed relative to each
  ///    other in the cross axis.
  WrapCrossAlignment get crossAxisAlignment => _crossAxisAlignment;
  WrapCrossAlignment _crossAxisAlignment;
  set crossAxisAlignment(WrapCrossAlignment value) {
    if (_crossAxisAlignment == value) return;

    _crossAxisAlignment = value;
    markNeedsLayout();
  }

  /// A maximum number of rows (the runs).
  int? get maxRun => _maxRun;
  int? _maxRun;
  set maxRun(int? value) {
    assert(value == null || value > 0);

    if (_maxRun == value) return;

    _maxRun = value;
    markNeedsLayout();
  }

  /// A maximum number of columns (the item in each run).
  int? get maxItemPerRun => _maxItemPerRun;
  int? _maxItemPerRun;
  set maxItemPerRun(int? value) {
    assert(value == null || value > 0);

    if (_maxItemPerRun == value) return;

    _maxItemPerRun = value;
    markNeedsLayout();
  }

  /// Determines the order to lay children out horizontally and how to interpret
  /// `start` and `end` in the horizontal direction.
  ///
  /// If the [direction] is [Axis.horizontal], this controls the order in which
  /// children are positioned (left-to-right or right-to-left), and the meaning
  /// of the [alignment] property's [WrapAlignment.start] and
  /// [WrapAlignment.end] values.
  ///
  /// If the [direction] is [Axis.horizontal], and either the
  /// [alignment] is either [WrapAlignment.start] or [WrapAlignment.end], or
  /// there's more than one child, then the [textDirection] must not be null.
  ///
  /// If the [direction] is [Axis.vertical], this controls the order in
  /// which runs are positioned, the meaning of the [runAlignment] property's
  /// [WrapAlignment.start] and [WrapAlignment.end] values, as well as the
  /// [crossAxisAlignment] property's [WrapCrossAlignment.start] and
  /// [WrapCrossAlignment.end] values.
  ///
  /// If the [direction] is [Axis.vertical], and either the
  /// [runAlignment] is either [WrapAlignment.start] or [WrapAlignment.end], the
  /// [crossAxisAlignment] is either [WrapCrossAlignment.start] or
  /// [WrapCrossAlignment.end], or there's more than one child, then the
  /// [textDirection] must not be null.
  TextDirection? get textDirection => _textDirection;
  TextDirection? _textDirection;
  set textDirection(TextDirection? value) {
    if (_textDirection == value) return;

    _textDirection = value;
    markNeedsLayout();
  }

  /// Determines the order to lay children out vertically and how to interpret
  /// `start` and `end` in the vertical direction.
  ///
  /// If the [direction] is [Axis.vertical], this controls which order children
  /// are painted in (down or up), the meaning of the [alignment] property's
  /// [WrapAlignment.start] and [WrapAlignment.end] values.
  ///
  /// If the [direction] is [Axis.vertical], and either the [alignment]
  /// is either [WrapAlignment.start] or [WrapAlignment.end], or there's
  /// more than one child, then the [verticalDirection] must not be null.
  ///
  /// If the [direction] is [Axis.horizontal], this controls the order in which
  /// runs are positioned, the meaning of the [runAlignment] property's
  /// [WrapAlignment.start] and [WrapAlignment.end] values, as well as the
  /// [crossAxisAlignment] property's [WrapCrossAlignment.start] and
  /// [WrapCrossAlignment.end] values.
  ///
  /// If the [direction] is [Axis.horizontal], and either the
  /// [runAlignment] is either [WrapAlignment.start] or [WrapAlignment.end], the
  /// [crossAxisAlignment] is either [WrapCrossAlignment.start] or
  /// [WrapCrossAlignment.end], or there's more than one child, then the
  /// [verticalDirection] must not be null.
  VerticalDirection get verticalDirection => _verticalDirection;
  VerticalDirection _verticalDirection;
  set verticalDirection(VerticalDirection value) {
    if (_verticalDirection != value) {
      _verticalDirection = value;
      markNeedsLayout();
    }
  }

  OverflowViewLayoutBehavior get layoutBehavior => _layoutBehavior;
  OverflowViewLayoutBehavior _layoutBehavior;
  set layoutBehavior(OverflowViewLayoutBehavior value) {
    if (_layoutBehavior != value) {
      _layoutBehavior = value;
      markNeedsLayout();
    }
  }

  bool get _debugHasNecessaryDirections {
    if (firstChild != null && lastChild != firstChild) {
      // i.e. there's more than one child
      if (direction == Axis.horizontal) {
        assert(textDirection != null,
            'Horizontal $runtimeType with multiple children has a null textDirection, so the layout order is undefined.');
      }
    }
    if (alignment == WrapAlignment.start || alignment == WrapAlignment.end) {
      if (direction == Axis.horizontal) {
        assert(textDirection != null,
            'Horizontal $runtimeType with alignment $alignment has a null textDirection, so the alignment cannot be resolved.');
      }
    }
    if (runAlignment == WrapAlignment.start ||
        runAlignment == WrapAlignment.end) {
      if (direction == Axis.vertical) {
        assert(textDirection != null,
            'Vertical $runtimeType with runAlignment $runAlignment has a null textDirection, so the alignment cannot be resolved.');
      }
    }
    if (crossAxisAlignment == WrapCrossAlignment.start ||
        crossAxisAlignment == WrapCrossAlignment.end) {
      if (direction == Axis.vertical) {
        assert(textDirection != null,
            'Vertical $runtimeType with crossAxisAlignment $crossAxisAlignment has a null textDirection, so the alignment cannot be resolved.');
      }
    }
    return true;
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! OverflowViewParentData)
      child.parentData = OverflowViewParentData();
  }

  @override
  double computeMinIntrinsicWidth(double height) {
    switch (direction) {
      case Axis.horizontal:
        double width = 0.0;
        RenderBox? child = firstChild;
        while (child != null) {
          width = math.max(width, child.getMinIntrinsicWidth(double.infinity));
          child = childAfter(child);
        }
        return width;
      case Axis.vertical:
        return computeDryLayout(BoxConstraints(maxHeight: height)).width;
    }
  }

  @override
  double computeMaxIntrinsicWidth(double height) {
    switch (direction) {
      case Axis.horizontal:
        double width = 0.0;
        RenderBox? child = firstChild;
        while (child != null) {
          width += child.getMaxIntrinsicWidth(double.infinity);
          child = childAfter(child);
        }
        return width;
      case Axis.vertical:
        return computeDryLayout(BoxConstraints(maxHeight: height)).width;
    }
  }

  @override
  double computeMinIntrinsicHeight(double width) {
    switch (direction) {
      case Axis.horizontal:
        return computeDryLayout(BoxConstraints(maxWidth: width)).height;
      case Axis.vertical:
        double height = 0.0;
        RenderBox? child = firstChild;
        while (child != null) {
          height =
              math.max(height, child.getMinIntrinsicHeight(double.infinity));
          child = childAfter(child);
        }
        return height;
    }
  }

  @override
  double computeMaxIntrinsicHeight(double width) {
    switch (direction) {
      case Axis.horizontal:
        return computeDryLayout(BoxConstraints(maxWidth: width)).height;
      case Axis.vertical:
        double height = 0.0;
        RenderBox? child = firstChild;
        while (child != null) {
          height += child.getMaxIntrinsicHeight(double.infinity);
          child = childAfter(child);
        }
        return height;
    }
  }

  @override
  double? computeDistanceToActualBaseline(TextBaseline baseline) {
    return defaultComputeDistanceToHighestActualBaseline(baseline);
  }

  bool _hasVisualOverflow = false;

  @override
  void performLayout() {
    assert(_debugHasNecessaryDirections);
    _hasVisualOverflow = false;

    final BoxConstraints constraints = this.constraints;

    if (childCount == 1) {
      size = constraints.smallest;
      return;
    }

    resetOffstage();
    switch (layoutBehavior) {
      case OverflowViewLayoutBehavior.fixed:
        performFixedLayout();
        break;
      case OverflowViewLayoutBehavior.flexible:
        performFlexibleLayout();
        break;
      case OverflowViewLayoutBehavior.wrap:
        performWrapLayout();
        break;
    }
  }

  void resetOffstage() {
    visitChildren((child) {
      final OverflowViewParentData childParentData =
          child.parentData as OverflowViewParentData;
      childParentData.offstage = null;
    });
  }

  void performFixedLayout() {
    final BoxConstraints childConstraints = constraints.loosen();
    final double maxExtent =
        _isHorizontal ? constraints.maxWidth : constraints.maxHeight;

    RenderBox child = firstChild!;
    OverflowViewParentData childParentData =
        child.parentData as OverflowViewParentData;
    child.layout(childConstraints, parentUsesSize: true);
    final double childExtent = _getMainAxisExtent(child.size);
    final double crossExtent = _getCrossAxisExtent(child.size);
    final BoxConstraints otherChildConstraints = _isHorizontal
        ? childConstraints.tighten(width: childExtent, height: crossExtent)
        : childConstraints.tighten(height: childExtent, width: crossExtent);

    final double childStride = childExtent + spacing;
    Offset getChildOffset(int index) {
      final double mainAxisOffset = index * childStride;
      final double crossAxisOffset = 0;
      if (_isHorizontal) {
        return Offset(mainAxisOffset, crossAxisOffset);
      } else {
        return Offset(crossAxisOffset, mainAxisOffset);
      }
    }

    int onstageCount = 0;
    final int count = childCount - 1;
    final double requestedExtent =
        childExtent * (childCount - 1) + spacing * (childCount - 2);
    final int renderedChildCount = requestedExtent <= maxExtent
        ? count
        : (maxExtent + spacing) ~/ childStride - 1;
    final int unRenderedChildCount = count - renderedChildCount;
    if (renderedChildCount > 0) {
      childParentData.offstage = false;
      onstageCount++;
    }

    for (int i = 1; i < renderedChildCount; i++) {
      child = childParentData.nextSibling!;
      childParentData = child.parentData as OverflowViewParentData;
      child.layout(otherChildConstraints);
      childParentData.offset = getChildOffset(i);
      childParentData.offstage = false;
      onstageCount++;
    }

    while (child != lastChild) {
      child = childParentData.nextSibling!;
      childParentData = child.parentData as OverflowViewParentData;
      childParentData.offstage = true;
    }

    if (unRenderedChildCount > 0) {
      // We have to layout the overflow indicator.
      final RenderBox overflowIndicator = lastChild!;

      final BoxValueConstraints<int> overflowIndicatorConstraints =
          BoxValueConstraints<int>(
        value: unRenderedChildCount,
        constraints: otherChildConstraints,
      );
      overflowIndicator.layout(overflowIndicatorConstraints);
      final OverflowViewParentData overflowIndicatorParentData =
          overflowIndicator.parentData as OverflowViewParentData;
      overflowIndicatorParentData.offset = getChildOffset(renderedChildCount);
      overflowIndicatorParentData.offstage = false;
      onstageCount++;
    }

    final double mainAxisExtent = onstageCount * childStride - spacing;
    final requestedSize = _isHorizontal
        ? Size(mainAxisExtent, crossExtent)
        : Size(crossExtent, mainAxisExtent);

    size = constraints.constrain(requestedSize);
  }

  void performFlexibleLayout() {
    RenderBox child = firstChild!;
    List<RenderBox> renderBoxes = <RenderBox>[];
    int unRenderedChildCount = childCount - 1;
    double availableExtent =
        _isHorizontal ? constraints.maxWidth : constraints.maxHeight;
    double offset = 0;
    final double maxCrossExtent =
        _isHorizontal ? constraints.maxHeight : constraints.maxWidth;

    final BoxConstraints childConstraints = _isHorizontal
        ? BoxConstraints.loose(Size(double.infinity, maxCrossExtent))
        : BoxConstraints.loose(Size(maxCrossExtent, double.infinity));

    bool showOverflowIndicator = false;
    while (child != lastChild) {
      final OverflowViewParentData childParentData =
          child.parentData as OverflowViewParentData;

      child.layout(childConstraints, parentUsesSize: true);

      final double childMainSize = _getMainAxisExtent(child.size);

      if (childMainSize <= availableExtent) {
        // We have room to paint this child.
        renderBoxes.add(child);
        childParentData.offstage = false;
        childParentData.offset =
            _isHorizontal ? Offset(offset, 0) : Offset(0, offset);

        final double childStride = spacing + childMainSize;
        offset += childStride;
        availableExtent -= childStride;
        unRenderedChildCount--;
        child = childParentData.nextSibling!;
      } else {
        // We have no room to paint any further child.
        showOverflowIndicator = true;
        break;
      }
    }

    if (showOverflowIndicator) {
      // We didn't layout all the children.
      final RenderBox overflowIndicator = lastChild!;
      final BoxValueConstraints<int> overflowIndicatorConstraints =
          BoxValueConstraints<int>(
        value: unRenderedChildCount,
        constraints: childConstraints,
      );
      overflowIndicator.layout(
        overflowIndicatorConstraints,
        parentUsesSize: true,
      );

      final double childMainSize = _getMainAxisExtent(overflowIndicator.size);

      // We need to remove the children that prevent the overflowIndicator
      // to paint.
      while (childMainSize > availableExtent && renderBoxes.isNotEmpty) {
        final RenderBox child = renderBoxes.removeLast();
        final OverflowViewParentData childParentData =
            child.parentData as OverflowViewParentData;
        childParentData.offstage = true;
        final double childStride = _getMainAxisExtent(child.size) + spacing;

        availableExtent += childStride;
        unRenderedChildCount++;
        offset -= childStride;
      }

      if (childMainSize > availableExtent) {
        // We cannot paint any child because there is not enough space.
        _hasVisualOverflow = true;
      }

      if (overflowIndicatorConstraints.value != unRenderedChildCount) {
        // The number of unrendered child changed, we have to layout the
        // indicator another time.
        overflowIndicator.layout(
          BoxValueConstraints<int>(
            value: unRenderedChildCount,
            constraints: childConstraints,
          ),
          parentUsesSize: true,
        );
      }

      renderBoxes.add(overflowIndicator);

      final OverflowViewParentData overflowIndicatorParentData =
          overflowIndicator.parentData as OverflowViewParentData;
      overflowIndicatorParentData.offset =
          _isHorizontal ? Offset(offset, 0) : Offset(0, offset);
      overflowIndicatorParentData.offstage = false;
      offset += childMainSize;
    } else {
      // We layout all children. We need to adjust the offset used to compute
      // the final size.
      offset -= spacing;

      // We need to layout the overflowIndicator because we may have already
      // laid it out with parentUsesSize: true before.
      // When unmounting a _LayoutBuilderElement, it calls markNeedsLayout
      // a last time, and can cause error.
      lastChild?.layout(BoxValueConstraints<int>(
        value: unRenderedChildCount,
        constraints: childConstraints,
      ));

      // Because the overflow indicator will be paint outside of the screen,
      // we need to say that there is an overflow.
      _hasVisualOverflow = true;
    }

    final double crossSize = renderBoxes.fold(
      0,
      (previousValue, element) => math.max(
        previousValue,
        _getCrossAxisExtent(element.size),
      ),
    );

    // By default we center all children in the cross-axis.
    for (final child in renderBoxes) {
      final double childCrossPosition =
          crossSize / 2.0 - _getCrossAxisExtent(child.size) / 2.0;
      final OverflowViewParentData childParentData =
          child.parentData as OverflowViewParentData;
      childParentData.offset = _isHorizontal
          ? Offset(childParentData.offset.dx, childCrossPosition)
          : Offset(childCrossPosition, childParentData.offset.dy);
    }

    Size idealSize;
    if (_isHorizontal) {
      idealSize = Size(offset, crossSize);
    } else {
      idealSize = Size(crossSize, offset);
    }

    size = constraints.constrain(idealSize);
  }

  void performWrapLayout() {
    final BoxConstraints childConstraints;
    double mainAxisLimit = 0.0;
    double crossAxisLimit = 0.0;
    bool flipMainAxis = false;
    bool flipCrossAxis = false;

    switch (direction) {
      case Axis.horizontal:
        childConstraints = BoxConstraints(maxWidth: constraints.maxWidth);
        mainAxisLimit = constraints.maxWidth;
        crossAxisLimit = constraints.maxHeight;
        if (textDirection == TextDirection.rtl) flipMainAxis = true;
        if (verticalDirection == VerticalDirection.up) flipCrossAxis = true;
        break;
      case Axis.vertical:
        childConstraints = BoxConstraints(maxHeight: constraints.maxHeight);
        mainAxisLimit = constraints.maxHeight;
        crossAxisLimit = constraints.maxWidth;
        if (verticalDirection == VerticalDirection.up) flipMainAxis = true;
        if (textDirection == TextDirection.rtl) flipCrossAxis = true;
        break;
    }

    List<RenderBox> renderBoxes = <RenderBox>[];
    int unRenderedChildCount = this.childCount - 1;

    final double spacing = this.spacing;
    final double runSpacing = this.runSpacing;
    final int? maxItemPerRun = this.maxItemPerRun;
    final List<_RunMetrics> runMetrics = <_RunMetrics>[];
    double mainAxisExtent = 0.0;
    double crossAxisExtent = 0.0;
    double currentRunMainAxisExtent = 0.0;
    double currentRunCrossAxisExtent = 0.0;
    int currentRunChildCount = 0;
    int runIndex = 0;

    bool showOverflowIndicator = false;
    Offset currentChildOffset = Offset.zero;

    RenderBox? child = firstChild;
    child?.layout(childConstraints, parentUsesSize: true);

    while (child != lastChild) { // the last child is the Overflow indicator, which will be laid out later
      final OverflowViewParentData childParentData = child!.parentData as OverflowViewParentData;
      childParentData.offset = currentChildOffset;
      // mark the child is not hidden, which means visible
      childParentData.offstage = false;
      childParentData._runIndex = runIndex;

      currentRunChildCount++;
      unRenderedChildCount--;

      renderBoxes.add(child);

      // Calculate the extent of the current run (row) in main axis and cross axis

      final double childMainAxisExtent = _getMainAxisExtent(child.size);
      final double childCrossAxisExtent = _getCrossAxisExtent(child.size);

      if (currentRunChildCount > 1) {
        currentRunMainAxisExtent += spacing;
      }
      currentRunMainAxisExtent += childMainAxisExtent;

      currentRunCrossAxisExtent = math.max(
        currentRunCrossAxisExtent,
        childCrossAxisExtent,
      );

      // Prepare [Offset.dy] of the next child
      double nextSiblingVerticalDistance = currentChildOffset.dy;

      // Layout next child to get its extent in main axis,
      // to prepare for the next run (row)

      final RenderBox? nextSibling = childParentData.nextSibling;
      double nextSiblingMainAxisExtent = 0.0;
      if (nextSibling != null && nextSibling != lastChild) {
        // The next child isn't the overflow indicator,
        // which (as the last child) will be laid out later.
        nextSibling.layout(childConstraints, parentUsesSize: true);
        nextSiblingMainAxisExtent = _getMainAxisExtent(nextSibling.size);
      }

      if ((maxItemPerRun != null && currentRunChildCount + 1 > maxItemPerRun) ||
          currentRunMainAxisExtent + nextSiblingMainAxisExtent > mainAxisLimit) {
        // Save information of current run
        runMetrics.add(_RunMetrics(
          mainAxisExtent: currentRunMainAxisExtent,
          crossAxisExtent: currentRunCrossAxisExtent,
          childCount: currentRunChildCount,
        ));

        // Update the extent of this widget in main axis and cross axis
        mainAxisExtent = math.max(mainAxisExtent, currentRunMainAxisExtent);

        if (runMetrics.length > 1) {
          crossAxisExtent += runSpacing;
        }

        crossAxisExtent += currentRunCrossAxisExtent;

        // Update [Offset.dy] of the next child
        nextSiblingVerticalDistance = crossAxisExtent + runSpacing;

        // If we reach the maximum number of runs
        // or the maximum extent in the cross axis,
        // we need to stop laying out the remaining children
        // and prepare to layout the Overflow indicator.

        if (runMetrics.length == maxRun) {
          // When the maxRun == 1 and maxItemPerRun == 1,
          // we don't need to show the Overflow indicator
          showOverflowIndicator = nextSibling != lastChild;
          break;
        }

        if (nextSibling != null && nextSibling != lastChild) {
          // The next child isn't the overflow indicator,
          // which (as the last child) will be laid out later.
          final double nextSiblingCrossAxisExtent = _getCrossAxisExtent(nextSibling.size);

          if (crossAxisExtent + runSpacing + nextSiblingCrossAxisExtent > crossAxisLimit) {
            // We have no room to paint any further child.
            showOverflowIndicator = true;
            break;
          }
        }

        runIndex += 1;

        // Reset current run information for the next run calculation

        currentRunMainAxisExtent = 0.0;
        currentRunCrossAxisExtent = 0.0;
        currentRunChildCount = 0;
      }

      // Go to the next child

      final double nextSiblingHorizontalDistance = spacing + currentRunMainAxisExtent;
      final nextChildOffset = Offset(nextSiblingHorizontalDistance, nextSiblingVerticalDistance);
      currentChildOffset = nextChildOffset;

      child = nextSibling;
    }

    if (runMetrics.isEmpty && childCount > 1) { // why > 1, because one for the Overflow indicator
      assert(!showOverflowIndicator);

      // This is when the maxRun == 1

      mainAxisExtent = currentRunMainAxisExtent;
      crossAxisExtent = currentRunCrossAxisExtent;

      runMetrics.add(_RunMetrics(
        mainAxisExtent: currentRunMainAxisExtent,
        crossAxisExtent: currentRunCrossAxisExtent,
        childCount: currentRunChildCount,
      ));
    }

    // Now, if showOverflowIndicator == true,
    // - runIndex is the last index of all the runs
    assert(!showOverflowIndicator || runIndex == runMetrics.length - 1);
    // - currentChildOffset is the offset of the last visible child,
    //   so when we need to show the Overflow indicator,
    //   we can use this offset to replace that child
    //   (the last visible child will be mark as invisible).
    assert(() {
      if (!showOverflowIndicator) return true;

      if (renderBoxes.isEmpty) return false;

      final lastVisibleChild = renderBoxes.last;
      final OverflowViewParentData childParentData = lastVisibleChild.parentData as OverflowViewParentData;

      return childParentData.offset == currentChildOffset;
    }());

    if (showOverflowIndicator) {
      // About to remove the last visible child
      unRenderedChildCount++;
      // to replace it with the Overflow indicator.

      final RenderBox overflowIndicator = lastChild!; // this is the Overflow indicator.
      final BoxValueConstraints<int> overflowIndicatorConstraints = BoxValueConstraints<int>(
        value: unRenderedChildCount,
        constraints: childConstraints,
      );

      overflowIndicator.layout(overflowIndicatorConstraints, parentUsesSize: true);

      double overflowIndicatorMainAxisExtent = _getMainAxisExtent(overflowIndicator.size);
      double overflowIndicatorCrossAxisExtent = _getCrossAxisExtent(overflowIndicator.size);

      Offset overflowIndicatorOffset = currentChildOffset;

      // Remove the last run metrics to make changes,
      // because the metrics are immutable.
      _RunMetrics lastMetrics = runMetrics.removeLast();
      double lastRunMainAxisExtent = lastMetrics.mainAxisExtent;
      int lastMetricsChildCount = lastMetrics.childCount;

      while(lastMetricsChildCount > 0) {
        // Remove the last visible child
        final RenderBox removedChild = renderBoxes.removeLast();
        final OverflowViewParentData removedChildParentData = removedChild.parentData as OverflowViewParentData;
        removedChildParentData.offstage = true;
        lastMetricsChildCount--;

        // Re-calculate the extent in the main axis of the last run
        final double removedChildMainAxisExtent = _getMainAxisExtent(removedChild.size);

        lastRunMainAxisExtent -= removedChildMainAxisExtent;
        if (lastMetricsChildCount > 0) {
          lastRunMainAxisExtent -= spacing;
        }

        // Use the [Offset.dx] of removed child as the [Offset.dx] of the indicator
        final double removedChildHorizontalDistance = removedChildParentData.offset.dx;

        // Save offset of the indicator
        overflowIndicatorOffset = Offset(
          removedChildHorizontalDistance,
          removedChildParentData.offset.dy,
        );

        final double overflowIndicatorMainAxisLimit = mainAxisExtent - lastRunMainAxisExtent;

        if (overflowIndicatorMainAxisLimit >= overflowIndicatorMainAxisExtent) {
          break;
        }

        // The indicator need more space to show...

        if (lastMetrics.hasNoChild) {
          // but there are no child.
          break;
        }

        // Prepare to remove the next child
        unRenderedChildCount++;

        // Relayout the indicator with the new number of hidden children
        final BoxValueConstraints<int> overflowIndicatorConstraints = BoxValueConstraints<int>(
          value: unRenderedChildCount,
          constraints: childConstraints,
        );

        overflowIndicator.layout(overflowIndicatorConstraints, parentUsesSize: true);

        overflowIndicatorMainAxisExtent = _getMainAxisExtent(overflowIndicator.size);
        overflowIndicatorCrossAxisExtent = _getCrossAxisExtent(overflowIndicator.size);
      }

      if (lastMetricsChildCount > 0) {
        lastRunMainAxisExtent += spacing;
      } 
      lastRunMainAxisExtent += overflowIndicatorMainAxisExtent;

      lastMetrics = lastMetrics.copyWith(
        mainAxisExtent: lastRunMainAxisExtent,
        crossAxisExtent: math.max(
          lastMetrics.crossAxisExtent,
          overflowIndicatorCrossAxisExtent,
        ),
        childCount: lastMetricsChildCount + 1, // 1 is for the indicator
      );

      runMetrics.add(lastMetrics);

      final OverflowViewParentData overflowIndicatorParentData = overflowIndicator.parentData as OverflowViewParentData;
      overflowIndicatorParentData.offset = overflowIndicatorOffset;
      overflowIndicatorParentData.offstage = false;
      overflowIndicatorParentData._runIndex = runMetrics.length - 1;

      mainAxisExtent = math.max(mainAxisExtent, lastMetrics.mainAxisExtent);
      crossAxisExtent = math.max(crossAxisExtent, lastMetrics.crossAxisExtent);
    }

    _positionChildrenInWrapLayout(
      flipMainAxis: flipMainAxis,
      flipCrossAxis: flipCrossAxis,
      mainAxisExtent: mainAxisExtent,
      crossAxisExtent: crossAxisExtent,
      runMetrics: runMetrics,
    );
  }

  void _positionChildrenInWrapLayout({
    required bool flipMainAxis,
    required bool flipCrossAxis,
    required double mainAxisExtent,
    required double crossAxisExtent,
    required List<_RunMetrics> runMetrics,
  }) {
    final int runCount = runMetrics.length;
    assert(runCount > 0);

    double containerMainAxisExtent = 0.0;
    double containerCrossAxisExtent = 0.0;

    switch (direction) {
      case Axis.horizontal:
        size = constraints.constrain(Size(mainAxisExtent, crossAxisExtent));
        containerMainAxisExtent = size.width;
        containerCrossAxisExtent = size.height;
        break;
      case Axis.vertical:
        size = constraints.constrain(Size(crossAxisExtent, mainAxisExtent));
        containerMainAxisExtent = size.height;
        containerCrossAxisExtent = size.width;
        break;
    }

    _hasVisualOverflow = containerMainAxisExtent < mainAxisExtent ||
        containerCrossAxisExtent < crossAxisExtent;

    final double crossAxisFreeSpace = math.max(0.0, containerCrossAxisExtent - crossAxisExtent);
    double runLeadingSpace = 0.0;
    double runBetweenSpace = 0.0;
    switch (runAlignment) {
      case WrapAlignment.start:
        break;
      case WrapAlignment.end:
        runLeadingSpace = crossAxisFreeSpace;
        break;
      case WrapAlignment.center:
        runLeadingSpace = crossAxisFreeSpace / 2.0;
        break;
      case WrapAlignment.spaceBetween:
        runBetweenSpace = runCount > 1 ? crossAxisFreeSpace / (runCount - 1) : 0.0;
        break;
      case WrapAlignment.spaceAround:
        runBetweenSpace = crossAxisFreeSpace / runCount;
        runLeadingSpace = runBetweenSpace / 2.0;
        break;
      case WrapAlignment.spaceEvenly:
        runBetweenSpace = crossAxisFreeSpace / (runCount + 1);
        runLeadingSpace = runBetweenSpace;
        break;
    }

    runBetweenSpace += runSpacing;
    double crossAxisOffset = flipCrossAxis
        ? containerCrossAxisExtent - runLeadingSpace
        : runLeadingSpace;

    RenderBox? child = firstChild;
    for (int i = 0; i < runCount; ++i) {
      final _RunMetrics metrics = runMetrics[i];
      final double runMainAxisExtent = metrics.mainAxisExtent;
      final double runCrossAxisExtent = metrics.crossAxisExtent;
      final int childCount = metrics.childCount;

      final double mainAxisFreeSpace = math.max(0.0, containerMainAxisExtent - runMainAxisExtent);
      double childLeadingSpace = 0.0;
      double childBetweenSpace = 0.0;

      switch (alignment) {
        case WrapAlignment.start:
          break;
        case WrapAlignment.end:
          childLeadingSpace = mainAxisFreeSpace;
          break;
        case WrapAlignment.center:
          childLeadingSpace = mainAxisFreeSpace / 2.0;
          break;
        case WrapAlignment.spaceBetween:
          childBetweenSpace = childCount > 1 ? mainAxisFreeSpace / (childCount - 1) : 0.0;
          break;
        case WrapAlignment.spaceAround:
          childBetweenSpace = mainAxisFreeSpace / childCount;
          childLeadingSpace = childBetweenSpace / 2.0;
          break;
        case WrapAlignment.spaceEvenly:
          childBetweenSpace = mainAxisFreeSpace / (childCount + 1);
          childLeadingSpace = childBetweenSpace;
          break;
      }

      childBetweenSpace += spacing;
      double childMainPosition = flipMainAxis
          ? containerMainAxisExtent - childLeadingSpace
          : childLeadingSpace;

      if (flipCrossAxis) crossAxisOffset -= runCrossAxisExtent;

      while (child != null) {
        final OverflowViewParentData childParentData = child.parentData! as OverflowViewParentData;

        if (childParentData._runIndex != i && childParentData.offstage != null) {
          break;
        }

        if (childParentData.offstage != false) {
          child = childParentData.nextSibling;
          continue;
        }

        final double childMainAxisExtent = _getMainAxisExtent(child.size);
        final double childCrossAxisExtent = _getCrossAxisExtent(child.size);
        final double childCrossAxisOffset = _getChildCrossAxisOffset(
          flipCrossAxis,
          runCrossAxisExtent,
          childCrossAxisExtent,
        );
        if (flipMainAxis) childMainPosition -= childMainAxisExtent;
        childParentData.offstage = false;
        childParentData.offset = _getOffset(
          childMainPosition,
          crossAxisOffset + childCrossAxisOffset,
        );
        if (flipMainAxis) {
          childMainPosition -= childBetweenSpace;
        } else {
          childMainPosition += childMainAxisExtent + childBetweenSpace;
        }
        child = childParentData.nextSibling;
      }

      if (flipCrossAxis) {
        crossAxisOffset -= runBetweenSpace;
      } else {
        crossAxisOffset += runCrossAxisExtent + runBetweenSpace;
      }
    }
  }

  double _getMainAxisExtent(Size childSize) {
    switch (direction) {
      case Axis.horizontal:
        return childSize.width;
      case Axis.vertical:
        return childSize.height;
    }
  }

  double _getCrossAxisExtent(Size childSize) {
    switch (direction) {
      case Axis.horizontal:
        return childSize.height;
      case Axis.vertical:
        return childSize.width;
    }
  }

  Offset _getOffset(double mainAxisOffset, double crossAxisOffset) {
    switch (direction) {
      case Axis.horizontal:
        return Offset(mainAxisOffset, crossAxisOffset);
      case Axis.vertical:
        return Offset(crossAxisOffset, mainAxisOffset);
    }
  }

  double _getChildCrossAxisOffset(bool flipCrossAxis, double runCrossAxisExtent,
      double childCrossAxisExtent) {
    final double freeSpace = runCrossAxisExtent - childCrossAxisExtent;
    switch (crossAxisAlignment) {
      case WrapCrossAlignment.start:
        return flipCrossAxis ? freeSpace : 0.0;
      case WrapCrossAlignment.end:
        return flipCrossAxis ? 0.0 : freeSpace;
      case WrapCrossAlignment.center:
        return freeSpace / 2.0;
    }
  }

  void visitOnlyOnStageChildren(RenderObjectVisitor visitor) {
    visitChildren((child) {
      if (child.isOnstage) {
        visitor(child);
      }
    });
  }

  @override
  void visitChildrenForSemantics(RenderObjectVisitor visitor) {
    visitOnlyOnStageChildren(visitor);
  }

  final LayerHandle<ClipRectLayer> _clipRectLayer = LayerHandle<ClipRectLayer>();

  @override
  void paint(PaintingContext context, Offset offset) {
    if (_hasVisualOverflow) {
      _clipRectLayer.layer = context.pushClipRect(
        needsCompositing,
        offset,
        Offset.zero & size,
        defaultPaint,
        clipBehavior: Clip.hardEdge,
        oldLayer: _clipRectLayer.layer,
      );
    } else {
      _clipRectLayer.layer = null;
      defaultPaint(context, offset);
    }
  }

  @override
  void defaultPaint(PaintingContext context, Offset offset) {
    visitOnlyOnStageChildren((RenderObject child) {
      // Paint the child
      final OverflowViewParentData childParentData =
          child.parentData as OverflowViewParentData;
      if (childParentData.offstage == false) {
        context.paintChild(child, childParentData.offset + offset);
      }
    });
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    // The x, y parameters have the top left of the node's box as the origin.
    visitOnlyOnStageChildren((renderObject) {
      final RenderBox child = renderObject as RenderBox;
      final OverflowViewParentData childParentData =
          child.parentData as OverflowViewParentData;
      if (child.hasSize && childParentData.offstage == false) {
        result.addWithPaintOffset(
          offset: childParentData.offset,
          position: position,
          hitTest: (BoxHitTestResult result, Offset transformed) {
            assert(transformed == position - childParentData.offset);
            return child.hitTest(result, position: transformed);
          },
        );
      }
    });

    return false;
  }

  @override
  void dispose() {
    _clipRectLayer.layer = null;
    super.dispose();
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(EnumProperty<Axis>('direction', direction));
    properties.add(EnumProperty<WrapAlignment>('alignment', alignment));
    properties.add(DoubleProperty('spacing', spacing));
    properties.add(EnumProperty<WrapAlignment>('runAlignment', runAlignment));
    properties.add(DoubleProperty('runSpacing', runSpacing));
    properties.add(DoubleProperty('crossAxisAlignment', runSpacing));
    properties.add(IntProperty('maxRun', maxRun));
    properties.add(IntProperty(
      'maxItemPerRun',
      maxItemPerRun,
      defaultValue: null,
    ));
    properties.add(EnumProperty<TextDirection>(
      'textDirection',
      textDirection,
      defaultValue: null,
    ));
    properties.add(EnumProperty<VerticalDirection>(
      'verticalDirection',
      verticalDirection,
    ));
    properties.add(EnumProperty<OverflowViewLayoutBehavior>(
      'layoutBehavior',
      layoutBehavior,
    ));
  }
}

extension RenderObjectExtensions on RenderObject {
  bool get isOnstage =>
      (parentData as OverflowViewParentData).offstage == false;
}
