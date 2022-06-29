import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

Color primary =
    HSLColor.fromColor(Color(0xff233c7b)).withLightness(0.75).toColor();

class LineChartSample11 extends StatefulWidget {
  const LineChartSample11({Key? key}) : super(key: key);

  @override
  _LineChartSample11State createState() => _LineChartSample11State();
}

class _LineChartSample11State extends State<LineChartSample11> {
  List<Color> gradientColors = [
    const Color(0xff23b6e6),
    const Color(0xff02d39a),
  ];

  BarChartGroupData generateGroup(
    double x,
    double value1,
    double value2,
    double value3,
    double value4,
  ) {
    bool isTop = value1 > 0;
    final sum = value1 + value2 + value3 + value4;
    final isTouched = touchedIndex == x;
    return BarChartGroupData(
      x: x,
      groupVertically: true,
      showingTooltipIndicators: isTouched ? [0] : [],
      barRods: [
        BarChartRodData(
          color: const Color(0xff4fbba9),
          toY: sum,
          width: 7.5,
          borderRadius: isTop
              ? const BorderRadius.only(
                  topLeft: Radius.circular(6),
                  topRight: Radius.circular(6),
                )
              : const BorderRadius.only(
                  bottomLeft: Radius.circular(6),
                  bottomRight: Radius.circular(6),
                ),
          borderSide: BorderSide(
            color: Colors.white,
            width: isTouched ? 2 : 0,
          ),
          // rodStackItems: [
          //   BarChartRodStackItem(
          //     0,
          //     value1,
          //     const Color(0xff2bdb90),
          //     BorderSide(
          //       color: Colors.white,
          //       width: isTouched ? 2 : 0,
          //     ),
          //   ),
          //   BarChartRodStackItem(
          //     value1,
          //     value1 + value2,
          //     const Color(0xffffdd80),
          //     BorderSide(
          //       color: Colors.white,
          //       width: isTouched ? 2 : 0,
          //     ),
          //   ),
          //   BarChartRodStackItem(
          //     value1 + value2,
          //     value1 + value2 + value3,
          //     const Color(0xffff4d94),
          //     BorderSide(
          //       color: Colors.white,
          //       width: isTouched ? 2 : 0,
          //     ),
          //   ),
          //   BarChartRodStackItem(
          //     value1 + value2 + value3,
          //     value1 + value2 + value3 + value4,
          //     const Color(0xff19bfff),
          //     BorderSide(
          //       color: Colors.white,
          //       width: isTouched ? 2 : 0,
          //     ),
          //   ),
          // ],
        ),
      ],
    );
  }

  double touchedIndex = -1;

  bool showAvg = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        AspectRatio(
          aspectRatio: 1.70,
          child: Container(
            decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(
                  Radius.circular(18),
                ),
                color: Color(0xff232d37)),
            child: Padding(
              padding: const EdgeInsets.only(
                  right: 18.0, left: 12.0, top: 24, bottom: 12),
              child: LineChart(
                mainData(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      color: Color(0xff68737d),
      fontWeight: FontWeight.bold,
      fontSize: 16,
    );

    String text = value % 2 ==0 ? value.toInt().toString(): '';

    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 8.0,
      child: Text(text),
    );
  }

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      color: Color(0xff67727d),
      fontWeight: FontWeight.bold,
      fontSize: 15,
    );

    String text = value % 2 == 0 ? value.toInt().toString() : '';

    return Text(text,
        style: style, textAlign: TextAlign.left);
  }

  LineChartData mainData() {
    var mainItems = <double, List<double>>{
      0.5: [2, 3, 1, 2],
      1.5: [1.5, 2, 1, 2],
      2.5: [1.5, 1.5, 1, 1],
      3.5: [1.2, 1, 1, 1],
      4.5: [1.2, 1, 1, 1],
      5.5: [1.2, 1, 1, 1],
      7.5: [0.2, 0.2, 0.2, 1],
      12.5: [0.2, 0.2, 0.2, 0],
    };
    return LineChartData(
      gridData: FlGridData(
        show: false,
        drawVerticalLine: true,
        horizontalInterval: 1,
        verticalInterval: 1,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: const Color(0xff37434d),
            strokeWidth: 1,
          );
        },
        getDrawingVerticalLine: (value) {
          return FlLine(
            color: const Color(0xff37434d),
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: 1,
            getTitlesWidget: bottomTitleWidgets,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 1,
            getTitlesWidget: leftTitleWidgets,
            reservedSize: 42,
          ),
        ),
      ),
      minY: 0,
      maxY: 10,
      borderData: FlBorderData(
          show: true,
          border: Border.all(color: const Color(0xff37434d), width: 1)),
      lineTouchData: LineTouchData(
        enabled: true,
        handleBuiltInTouches: true,
        getTouchLineStart: (LineChartBarData barData, int spotIndex) {
          return barData.spots[spotIndex].y;
        },
      distanceCalculator: (Offset touchPoint, Offset spotPixelCoordinates) {
          return math.sqrt(((touchPoint.dx - spotPixelCoordinates.dx) ).abs() + ((touchPoint.dy - spotPixelCoordinates.dy)).abs());
        },
        touchSpotThreshold: 5,
        touchTooltipData: LineTouchTooltipData(
          getTooltipItems: (touchedSpots) {
            return touchedSpots
                .map((e) =>
                    LineTooltipItem('${e.y} at ${e.x}', const TextStyle()))
                .toList();
          },
        ),
        getTouchedSpotIndicator:
            (LineChartBarData barData, List<int> indicators) {
          return indicators.map((int index) {
            /// Indicator Line
            var lineColor = Colors.transparent;

            const lineStrokeWidth = 4.0;
            final flLine =
                FlLine(color: lineColor, strokeWidth: lineStrokeWidth);

            final dotData =
                FlDotData(getDotPainter: (spot, percent, bar, index) {
              return FlDotCirclePainter(
                  radius: 6, color: primary, strokeWidth: 0);
            });

            return TouchedSpotIndicatorData(flLine, dotData);
          }).toList();
        },
        touchCallback: (FlTouchEvent event, LineTouchResponse? touchResponse) {
          if (!event.isInterestedForInteractions ||
              touchResponse == null ||
              touchResponse.barTouchedSpot == null) {
            setState(() {
              touchedIndex = -1;
            });
            return;
          }
          setState(() {
            touchedIndex = touchResponse.barTouchedSpot!.spot.x;
          });
        },
      ),
      barGroups: mainItems.entries
          .map((e) => generateGroup(
              e.key, e.value[0], e.value[1], e.value[2], e.value[3]))
          .toList(),
      lineBarsData: [
        LineChartBarData(
          color: primary,
          isStepLineChart: true,
          spots: const [
            FlSpot(0, 9),
            FlSpot(1, 9),
            FlSpot(2, 9),
            FlSpot(3, 9),
            FlSpot(4, 6),
            FlSpot(5, 6),
            FlSpot(6, 6),
            FlSpot(7, 6),
            FlSpot(8, 6),
            FlSpot(9, 6),
            FlSpot(10, 6),
            FlSpot(11, 6),
            FlSpot(12, 6),
            FlSpot(13, 6),
            FlSpot(14, 9),
            FlSpot(15, 9),
            FlSpot(16, 9),
            FlSpot(17, 9),
            FlSpot(18, 6),
            FlSpot(19, 6),
            FlSpot(20, 6),
            FlSpot(21, 6),
            FlSpot(22, 6),
            FlSpot(23, 6),
            FlSpot(24, 6)
          ],
          isCurved: true,
          barWidth: 2,
          isStrokeCapRound: true,
          dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, bar, index) {
                return FlDotCirclePainter(
                    radius: 3, color: primary, strokeWidth: 0);
              }),
        ),
      ],
    );
  }
}
