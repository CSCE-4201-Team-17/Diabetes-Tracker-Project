import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/glucose_reading.dart';

class GlucoseTrendChart extends StatelessWidget {
  final List<BloodSugarReading> readings;

  const GlucoseTrendChart({
    super.key,
    required this.readings,
  });

  @override
  Widget build(BuildContext context) {
    if (readings.length < 2) {
      return const Center(
        child: Text(
          "Not enough data for a trend yet.\nLog a few more readings.",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12),
        ),
      );
    }

    return CustomPaint(
      painter: _GlucoseTrendPainter(readings),
      // a bit shorter by default to help reduce vertical space
      size: const Size(double.infinity, 190),
    );
  }
}

class _GlucoseTrendPainter extends CustomPainter {
  final List<BloodSugarReading> readings;

  _GlucoseTrendPainter(this.readings);

  @override
  void paint(Canvas canvas, Size size) {
    if (readings.length < 2) return;

    // ---- SORT BY TIME ----
    final sorted = [...readings]
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    final times = sorted.map((r) => r.timestamp).toList();
    final values = sorted.map((r) => r.value).toList();
    final n = sorted.length;

    // X axis = minutes since first reading
    final firstTime = times.first;
    final xs = times
        .map((t) => t.difference(firstTime).inMinutes.toDouble())
        .toList();

    double minX = xs.first;
    double maxX = xs.last == minX ? minX + 1 : xs.last;

    // Base Y range from past readings
    double minY = values.reduce((a, b) => a < b ? a : b);
    double maxY = values.reduce((a, b) => a > b ? a : b);

    // ---- 3-week future window ----
    const int minutesPerDay = 24 * 60;
    const int futureDays = 21;
    final double futureDeltaMinutes = futureDays * minutesPerDay.toDouble();
    final double futureMaxX = maxX + futureDeltaMinutes;

    // ===== SIMPLE LINEAR REGRESSION (past) =====
    final xsDouble = xs;
    final ysDouble = values;

    final meanX = xsDouble.reduce((a, b) => a + b) / n;
    final meanY = ysDouble.reduce((a, b) => a + b) / n;

    double num = 0, den = 0;
    for (int i = 0; i < n; i++) {
      num += (xsDouble[i] - meanX) * (ysDouble[i] - meanY);
      den += (xsDouble[i] - meanX) * (xsDouble[i] - meanX);
    }
    if (den == 0) den = 1e-6;

    final slope = num / den;
    final intercept = meanY - slope * meanX;

    // Future points at +1w, +2w, +3w from last reading
    final double lastX = xsDouble.last;
    final List<double> futureXs = [
      lastX + 7 * minutesPerDay,
      lastX + 14 * minutesPerDay,
      lastX + 21 * minutesPerDay,
    ];
    final List<double> futureYs =
        futureXs.map((fx) => slope * fx + intercept).toList();

    // Extend Y range to include forecast so trend stays inside chart
    for (final fy in futureYs) {
      if (fy < minY) minY = fy;
      if (fy > maxY) maxY = fy;
    }
    final yRange = (maxY - minY).abs() < 1 ? 1.0 : (maxY - minY);

    // ---- Layout / paddings ----
    const double paddingLeft = 48;
    const double paddingRight = 16;
    const double paddingTop = 28;
    const double paddingBottom = 48;

    final chartWidth = size.width - paddingLeft - paddingRight;
    final chartHeight = size.height - paddingTop - paddingBottom;

    Offset toPoint(double xVal, double yVal) {
      final dx = paddingLeft +
          ((xVal - minX) / (futureMaxX - minX)) * chartWidth;
      final dy =
          paddingTop + (1 - ((yVal - minY) / yRange)) * chartHeight;
      return Offset(dx, dy);
    }

    // Past points
    final dataPoints = <Offset>[
      for (int i = 0; i < n; i++) toPoint(xsDouble[i], ysDouble[i])
    ];

    final trendPoints = <Offset>[
      for (int i = 0; i < n; i++)
        toPoint(xsDouble[i], slope * xsDouble[i] + intercept)
    ];

    // Future week points & final forecast
    final futureWeekPoints = <Offset>[
      for (int i = 0; i < futureXs.length; i++)
        toPoint(futureXs[i], futureYs[i]),
    ];
    final Offset futureEndPoint = futureWeekPoints.last;

    TextPainter _tp(
      String text, {
      double fontSize = 10,
      Color color = Colors.black,
      FontWeight fontWeight = FontWeight.normal,
      TextAlign align = TextAlign.center,
    }) {
      final painter = TextPainter(
        text: TextSpan(
          text: text,
          style: TextStyle(
            fontSize: fontSize,
            color: color,
            fontWeight: fontWeight,
          ),
        ),
        textAlign: align,
        textDirection: TextDirection.ltr,
      )..layout();
      return painter;
    }

    // Background
    final bgPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawRect(Offset.zero & size, bgPaint);

    // ---- Zones: low / target / high ----
    double zoneToDy(double yVal) {
      return paddingTop +
          (1 - ((yVal - minY) / yRange)) * chartHeight;
    }

    const double lowLimit = 70.0;
    const double highLimit = 140.0;

    final zonePaintLow = Paint()
      ..color = Colors.orange.withOpacity(0.08)
      ..style = PaintingStyle.fill;
    final zonePaintMid = Paint()
      ..color = Colors.green.withOpacity(0.08)
      ..style = PaintingStyle.fill;
    final zonePaintHigh = Paint()
      ..color = Colors.red.withOpacity(0.06)
      ..style = PaintingStyle.fill;

    double clamp(double v, double a, double b) =>
        v < a ? a : (v > b ? b : v);

    // low zone: minY .. lowLimit
    if (minY < lowLimit) {
      final top = zoneToDy(clamp(lowLimit, minY, maxY));
      final bottom = zoneToDy(minY);
      canvas.drawRect(
        Rect.fromLTRB(
          paddingLeft,
          top,
          size.width - paddingRight,
          bottom,
        ),
        zonePaintLow,
      );
    }

    // in-range zone: lowLimit .. highLimit
    if (lowLimit < maxY && highLimit > minY) {
      final top = zoneToDy(clamp(highLimit, minY, maxY));
      final bottom = zoneToDy(clamp(lowLimit, minY, maxY));
      canvas.drawRect(
        Rect.fromLTRB(
          paddingLeft,
          top,
          size.width - paddingRight,
          bottom,
        ),
        zonePaintMid,
      );
    }

    // high zone: highLimit .. maxY
    if (maxY > highLimit) {
      final top = zoneToDy(maxY);
      final bottom = zoneToDy(clamp(highLimit, minY, maxY));
      canvas.drawRect(
        Rect.fromLTRB(
          paddingLeft,
          top,
          size.width - paddingRight,
          bottom,
        ),
        zonePaintHigh,
      );
    }

    // Gridlines
    final gridPaint = Paint()
      ..color = Colors.grey.withOpacity(0.15)
      ..strokeWidth = 1;

    for (int i = 0; i <= 3; i++) {
      final y = paddingTop + chartHeight * (i / 3);
      canvas.drawLine(
        Offset(paddingLeft, y),
        Offset(size.width - paddingRight, y),
        gridPaint,
      );
    }

    // Axes
    final axisPaint = Paint()
      ..color = Colors.grey.shade600
      ..strokeWidth = 1.2;

    // Y-axis
    canvas.drawLine(
      Offset(paddingLeft, paddingTop),
      Offset(paddingLeft, size.height - paddingBottom),
      axisPaint,
    );

    // X-axis
    final xAxisY = size.height - paddingBottom;
    canvas.drawLine(
      Offset(paddingLeft, xAxisY),
      Offset(size.width - paddingRight, xAxisY),
      axisPaint,
    );

    // Y labels: min / mid / max
    final midYVal = (minY + maxY) / 2;
    final yLabels = {
      maxY.toStringAsFixed(0): paddingTop,
      midYVal.toStringAsFixed(0): paddingTop + chartHeight / 2,
      minY.toStringAsFixed(0): paddingTop + chartHeight,
    };

    yLabels.forEach((text, y) {
      final tp = _tp(text);
      tp.paint(
        canvas,
        Offset(paddingLeft - tp.width - 6, y - tp.height / 2),
      );
    });

    final yTitle = _tp(
      "mg/dL",
      fontSize: 11,
      fontWeight: FontWeight.bold,
    );
    yTitle.paint(
      canvas,
      Offset(
        paddingLeft - yTitle.width - 10,
        paddingTop - 18,
      ),
    );

    // X-axis date labels (real dates, not just +1w)
    String fmtDate(DateTime t) => "${t.month}/${t.day}";
    final startDate = times.first;
    final lastDate = times.last;
    final futureEndDate = lastDate.add(const Duration(days: futureDays));

    final startX = toPoint(minX, minY).dx;
    final nowX = toPoint(maxX, minY).dx;
    final endX = toPoint(futureMaxX, minY).dx;
    final midX = (startX + endX) / 2;

    final startTp = _tp(fmtDate(startDate));
    startTp.paint(
      canvas,
      Offset(startX - startTp.width / 2, xAxisY + 4),
    );

    final nowTp = _tp("Now\n${fmtDate(lastDate)}");
    nowTp.paint(
      canvas,
      Offset(nowX - nowTp.width / 2, xAxisY + 4),
    );

    final midDate = startDate.add(
      Duration(
        milliseconds: (futureEndDate
                    .difference(startDate)
                    .inMilliseconds ~/
                2),
      ),
    );
    final midTp = _tp(fmtDate(midDate));
    midTp.paint(
      canvas,
      Offset(midX - midTp.width / 2, xAxisY + 4),
    );

    final endTp = _tp("+3w\n${fmtDate(futureEndDate)}");
    endTp.paint(
      canvas,
      Offset(endX - endTp.width / 2, xAxisY + 4),
    );

    final xTitle = _tp(
      "Time (past -> ~3 weeks ahead)",
      fontSize: 11,
      fontWeight: FontWeight.bold,
    );
    xTitle.paint(
      canvas,
      Offset(
        paddingLeft + chartWidth / 2 - xTitle.width / 2,
        xAxisY + 24,
      ),
    );

    // Data line (past readings)
    final dataPaint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final dataPath = Path()..moveTo(dataPoints[0].dx, dataPoints[0].dy);
    for (int i = 1; i < dataPoints.length; i++) {
      dataPath.lineTo(dataPoints[i].dx, dataPoints[i].dy);
    }
    canvas.drawPath(dataPath, dataPaint);

    final dotPaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;
    for (final p in dataPoints) {
      canvas.drawCircle(p, 3, dotPaint);
    }

    // Trend line (solid red) over past window
    final trendPaint = Paint()
      ..color = Colors.red
      ..strokeWidth = 2.4
      ..style = PaintingStyle.stroke;

    final trendPath = Path()
      ..moveTo(trendPoints[0].dx, trendPoints[0].dy);
    for (int i = 1; i < trendPoints.length; i++) {
      trendPath.lineTo(trendPoints[i].dx, trendPoints[i].dy);
    }
    canvas.drawPath(trendPath, trendPaint);

    // Dashed line for future forecast (red)
    final dashedPaint = Paint()
      ..color = Colors.red
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    _drawDashedLine(
      canvas,
      dashedPaint,
      trendPoints.last,
      futureEndPoint,
      dashWidth: 6,
      gapWidth: 4,
    );

    // Future dots with labels: date + ~value
    final futureDotPaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;

    for (int i = 0; i < futureWeekPoints.length; i++) {
      final p = futureWeekPoints[i];
      final yVal = futureYs[i];
      final date = lastDate.add(Duration(days: (i + 1) * 7));
      final label =
          "${date.month}/${date.day}\n~${yVal.round()} mg/dL";

      canvas.drawCircle(p, 3, futureDotPaint);

      final tp = _tp(label, fontSize: 9);
      tp.paint(
        canvas,
        Offset(p.dx - tp.width / 2, p.dy - tp.height - 4),
      );
    }

    // ========= LEGEND (ONE ROW: readings | trend | 3-week forecast) =========
    final legendBgPaint = Paint()
      ..color = Colors.white.withOpacity(0.9)
      ..style = PaintingStyle.fill;
    final legendBorder = Paint()
      ..color = Colors.grey.shade400
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;

    const legendWidth = 300.0;
    const legendHeight = 32.0;

    final double legendLeft = paddingLeft + 4;
    final double legendTop = paddingTop - legendHeight - 4;

    final legendRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        legendLeft,
        legendTop,
        legendWidth,
        legendHeight,
      ),
      const Radius.circular(8),
    );

    canvas.drawRRect(legendRect, legendBgPaint);
    canvas.drawRRect(legendRect, legendBorder);

    // vertical center of legend contents
    final double legendCenterY = legendTop + legendHeight / 2;

    // Blue: readings
    final double readingsDotX = legendLeft + 14;
    canvas.drawCircle(
      Offset(readingsDotX, legendCenterY),
      4,
      Paint()..color = Colors.blue,
    );
    final legendBlue = _tp("Readings", fontSize: 10);
    legendBlue.paint(
      canvas,
      Offset(
        readingsDotX + 8,
        legendCenterY - legendBlue.height / 2,
      ),
    );

    // Red solid: trend
    final double trendLineStartX = legendLeft + 110;
    final double trendLineEndX = trendLineStartX + 14;
    canvas.drawLine(
      Offset(trendLineStartX, legendCenterY),
      Offset(trendLineEndX, legendCenterY),
      Paint()
        ..color = Colors.red
        ..strokeWidth = 2,
    );
    final legendTrend = _tp("Trend", fontSize: 10);
    legendTrend.paint(
      canvas,
      Offset(
        trendLineEndX + 4,
        legendCenterY - legendTrend.height / 2,
      ),
    );

    // Red dashed: 3-week forecast (to the right of Trend, not under)
    final double forecastLineStartX = legendLeft + 185;
    final double forecastLineEndX = forecastLineStartX + 14;
    _drawDashedLine(
      canvas,
      Paint()
        ..color = Colors.red
        ..strokeWidth = 2,
      Offset(forecastLineStartX, legendCenterY),
      Offset(forecastLineEndX, legendCenterY),
      dashWidth: 4,
      gapWidth: 3,
    );
    final legendPred = _tp("3-week forecast", fontSize: 10);
    legendPred.paint(
      canvas,
      Offset(
        forecastLineEndX + 4,
        legendCenterY - legendPred.height / 2,
      ),
    );
  }

  void _drawDashedLine(
    Canvas canvas,
    Paint paint,
    Offset start,
    Offset end, {
    required double dashWidth,
    required double gapWidth,
  }) {
    final dx = end.dx - start.dx;
    final dy = end.dy - start.dy;
    final distance = math.sqrt(dx * dx + dy * dy);
    if (distance == 0) return;

    final direction = Offset(dx / distance, dy / distance);
    double traveled = 0;

    while (traveled < distance) {
      final currentStart = start + direction * traveled;
      final currentEnd = start +
          direction * math.min(traveled + dashWidth, distance);
      canvas.drawLine(currentStart, currentEnd, paint);
      traveled += dashWidth + gapWidth;
    }
  }

  @override
  bool shouldRepaint(covariant _GlucoseTrendPainter oldDelegate) {
    return oldDelegate.readings != readings;
  }
}
