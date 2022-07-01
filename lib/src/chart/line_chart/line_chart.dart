import 'package:fl_chart/fl_chart.dart';
import 'package:fl_chart/src/chart/base/axis_chart/axis_chart_scaffold_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'line_chart_renderer.dart';

/// Renders a line chart as a widget, using provided [LineChartData].
class LineChart extends ImplicitlyAnimatedWidget {
  /// Determines how the [LineChart] should be look like.
  final LineChartData data;

  /// We pass this key to our renderers which are supposed to
  /// render the chart itself (without anything around the chart).
  final Key? chartRendererKey;

  /// [data] determines how the [LineChart] should be look like,
  /// when you make any change in the [LineChartData], it updates
  /// new values with animation, and duration is [swapAnimationDuration].
  /// also you can change the [swapAnimationCurve]
  /// which default is [Curves.linear].
  const LineChart(
    this.data, {
    this.chartRendererKey,
    Key? key,
    Duration swapAnimationDuration = const Duration(milliseconds: 150),
    Curve swapAnimationCurve = Curves.linear,
  }) : super(
            key: key,
            duration: swapAnimationDuration,
            curve: swapAnimationCurve);

  /// Creates a [_LineChartState]
  @override
  _LineChartState createState() => _LineChartState();
}

class _LineChartState extends AnimatedWidgetBaseState<LineChart> {
  /// we handle under the hood animations (implicit animations) via this tween,
  /// it lerps between the old [LineChartData] to the new one.
  LineChartDataTween? _lineChartDataTween;

  /// If [LineTouchData.handleBuiltInTouches] is true, we override the callback to handle touches internally,
  /// but we need to keep the provided callback to notify it too.
  BaseTouchCallback<LineTouchResponse>? _providedLineTouchCallback;

  final Map<int, List<int>> _showingBarGroupTouchedTooltips = {};

  final List<ShowingTooltipIndicators> _showingSpotTouchedTooltips = [];

  final Map<int, List<int>> _showingTouchedIndicators = {};

  @override
  Widget build(BuildContext context) {
    final showingData = _getData();

    return AxisChartScaffoldWidget(
      chart: LineChartLeaf(
        data: _withTouchedIndicators(_lineChartDataTween!.evaluate(animation)),
        targetData: _withTouchedIndicators(showingData),
        key: widget.chartRendererKey,
      ),
      data: showingData,
    );
  }

  LineChartData _withTouchedIndicators(LineChartData lineChartData) {
    LineChartData newLineChartData = lineChartData;

    if (lineChartData.lineTouchData.enabled ||
        lineChartData.lineTouchData.handleBuiltInTouches) {
      newLineChartData = newLineChartData.copyWith(
          showingTooltipIndicators: _showingSpotTouchedTooltips,
          lineBarsData: lineChartData.lineBarsData.map((barData) {
            final index = lineChartData.lineBarsData.indexOf(barData);

            return barData.copyWith(
              showingIndicators: _showingTouchedIndicators[index] ?? [],
            );
          }).toList());
    }

    if (lineChartData.barTouchData.enabled ||
        lineChartData.barTouchData.handleBuiltInTouches) {
      final newGroups = <BarChartGroupData>[];
      for (var i = 0; i < lineChartData.barGroups.length; i++) {
        final group = lineChartData.barGroups[i];

        newGroups.add(
          group.copyWith(
            showingTooltipIndicators: _showingBarGroupTouchedTooltips[i],
          ),
        );
      }

      newLineChartData = newLineChartData.copyWith(
        barGroups: newGroups,
      );
    }

    return newLineChartData;
  }

  LineChartData _getData() {
    final lineTouchData = widget.data.lineTouchData;
    if (lineTouchData.enabled && lineTouchData.handleBuiltInTouches) {
      _providedLineTouchCallback = lineTouchData.touchCallback;
      return widget.data.copyWith(
        lineTouchData: widget.data.lineTouchData
            .copyWith(touchCallback: _handleBuiltInTouch),
      );
    }
    return widget.data;
  }

  void _handleBuiltInTouch(
      FlTouchEvent event, LineTouchResponse? touchResponse) {
    _providedLineTouchCallback?.call(event, touchResponse);

    if (!event.isInterestedForInteractions) {
      setState(() {
        _showingSpotTouchedTooltips.clear();
        _showingBarGroupTouchedTooltips.clear();
        _showingTouchedIndicators.clear();
      });
      return;
    }

    setState(() {
      List<LineBarSpot> sortedLineSpots = [];
      if (touchResponse?.lineBarSpots != null &&
          touchResponse!.lineBarSpots!.isNotEmpty) {
        sortedLineSpots = List.of(touchResponse.lineBarSpots!);
        sortedLineSpots.sort((spot1, spot2) => spot2.y.compareTo(spot1.y));

        _showingTouchedIndicators.clear();
        for (var i = 0; i < touchResponse.lineBarSpots!.length; i++) {
          final touchedBarSpot = touchResponse.lineBarSpots![i];
          final barPos = touchedBarSpot.barIndex;
          _showingTouchedIndicators[barPos] = [touchedBarSpot.spotIndex];
        }
      }

      List<int> showingBarGroups = [];

      if (touchResponse?.barTouchedSpot != null) {
        final groupIndex = touchResponse!.barTouchedSpot!.touchedBarGroupIndex;
        final rodIndex = touchResponse.barTouchedSpot!.touchedRodDataIndex;

        _showingBarGroupTouchedTooltips.clear();
        _showingBarGroupTouchedTooltips[groupIndex] = [rodIndex];
        showingBarGroups = _showingBarGroupTouchedTooltips[groupIndex]!;
      }

      _showingBarGroupTouchedTooltips.clear();

      _showingSpotTouchedTooltips.clear();

      _showingSpotTouchedTooltips
          .add(ShowingTooltipIndicators(sortedLineSpots, showingBarGroups));
    });
  }

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    _lineChartDataTween = visitor(
      _lineChartDataTween,
      _getData(),
      (dynamic value) => LineChartDataTween(begin: value, end: widget.data),
    ) as LineChartDataTween;
  }
}
