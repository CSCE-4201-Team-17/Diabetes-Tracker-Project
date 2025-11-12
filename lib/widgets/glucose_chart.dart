import 'package:flutter/material.dart';
import '../models/glucose_reading.dart';

class GlucoseChart extends StatelessWidget {
  final List<BloodSugarReading> readings;
  
  const GlucoseChart({super.key, required this.readings});
  
  @override
  Widget build(BuildContext context) {
    if (readings.length < 2) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('Not enough data to show chart. Add more readings.'),
        ),
      );
    }

    // Sort readings by timestamp
    readings.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Blood Sugar Trends',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Container(
              height: 200,
              padding: const EdgeInsets.all(8.0),
              child: CustomPaint(
                size: const Size(double.infinity, 200),
                painter: _GlucoseChartPainter(readings: readings),
              ),
            ),
            const SizedBox(height: 8),
            _buildLegend(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildLegendItem('Low (<70)', Colors.orange),
        _buildLegendItem('Normal (70-140)', Colors.green),
        _buildLegendItem('High (>140)', Colors.red),
      ],
    );
  }
  
  Widget _buildLegendItem(String text, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          color: color,
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }
}

class _GlucoseChartPainter extends CustomPainter {
  final List<BloodSugarReading> readings;
  
  _GlucoseChartPainter({required this.readings});
  
  @override
  void paint(Canvas canvas, Size size) {
    if (readings.length < 2) return;
    
    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    
    final points = _calculatePoints(size);
    
    // Draw the line
    final path = Path();
    path.moveTo(points.first.dx, points.first.dy);
    
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }
    
    canvas.drawPath(path, paint);
    
    // Draw points
    final pointPaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;
    
    for (final point in points) {
      canvas.drawCircle(point, 3, pointPaint);
    }
    
    // Draw target range
    final targetPaint = Paint()
      ..color = Colors.green.withOpacity(0.2)
      ..style = PaintingStyle.fill;
    
    final targetRect = Rect.fromPoints(
      const Offset(0, 0),
      Offset(size.width, size.height),
    );
    canvas.drawRect(targetRect, targetPaint);
  }
  
  List<Offset> _calculatePoints(Size size) {
    final values = readings.map((r) => r.value).toList();
    final minValue = values.reduce((a, b) => a < b ? a : b);
    final maxValue = values.reduce((a, b) => a > b ? a : b);
    
    final range = (maxValue - minValue) * 1.1; // Add 10% padding
    final xStep = size.width / (readings.length - 1);
    
    return readings.asMap().entries.map((entry) {
      final index = entry.key;
      final reading = entry.value;
      
      final x = index * xStep;
      final normalizedY = (reading.value - minValue) / range;
      final y = size.height - (normalizedY * size.height);
      
      return Offset(x, y);
    }).toList();
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}