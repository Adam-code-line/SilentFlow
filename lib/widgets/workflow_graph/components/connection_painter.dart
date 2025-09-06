import 'package:flutter/material.dart';
import '../../../providers/enhanced_workflow_provider.dart';

/// 连线绘制器
class ConnectionPainter extends CustomPainter {
  final List<EnhancedTaskNode> tasks;
  final Offset Function(String taskId) getTaskPosition;
  final double animationValue;

  ConnectionPainter({
    required this.tasks,
    required this.getTaskPosition,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = const Color(0xFF4C51BF).withOpacity(0.7)
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;

    final arrowPaint = Paint()
      ..color = const Color(0xFF4C51BF)
      ..style = PaintingStyle.fill;

    final shadowPaint = Paint()
      ..color = Colors.black26
      ..strokeWidth = 4.0
      ..style = PaintingStyle.stroke;

    // 绘制所有连线
    for (final task in tasks) {
      for (final dependencyId in task.dependencies) {
        final dependentTask = tasks.firstWhere(
          (t) => t.id == dependencyId,
          orElse: () => task, // 如果找不到依赖任务，跳过
        );

        if (dependentTask.id == task.id) continue; // 跳过自依赖

        final fromPosition = getTaskPosition(dependencyId);
        final toPosition = getTaskPosition(task.id);

        // 计算连线的起点和终点（从卡片边缘开始）
        const cardWidth = 180.0;
        const cardHeight = 100.0;

        final fromCenter = Offset(
            fromPosition.dx + cardWidth / 2, fromPosition.dy + cardHeight / 2);
        final toCenter = Offset(
            toPosition.dx + cardWidth / 2, toPosition.dy + cardHeight / 2);

        // 计算连线起点和终点
        final fromOffset = _getConnectionPoint(
            fromCenter, toCenter, cardWidth, cardHeight, true);
        final toOffset = _getConnectionPoint(
            toCenter, fromCenter, cardWidth, cardHeight, false);

        // 绘制阴影效果
        canvas.drawLine(
          Offset(fromOffset.dx + 2, fromOffset.dy + 2),
          Offset(toOffset.dx + 2, toOffset.dy + 2),
          shadowPaint,
        );

        // 绘制连线
        _drawBezierConnection(
            canvas, fromOffset, toOffset, linePaint, arrowPaint);
      }
    }
  }

  // 计算连线与卡片边缘的交点
  Offset _getConnectionPoint(
      Offset center, Offset target, double width, double height, bool isFrom) {
    final dx = target.dx - center.dx;
    final dy = target.dy - center.dy;

    if (dx.abs() > dy.abs()) {
      // 水平连接
      final x = center.dx + (dx > 0 ? width / 2 : -width / 2);
      final y = center.dy + (dy / dx.abs()) * (width / 2);
      return Offset(x, y.clamp(center.dy - height / 2, center.dy + height / 2));
    } else {
      // 垂直连接
      final x = center.dx + (dx / dy.abs()) * (height / 2);
      final y = center.dy + (dy > 0 ? height / 2 : -height / 2);
      return Offset(x.clamp(center.dx - width / 2, center.dx + width / 2), y);
    }
  }

  // 绘制贝塞尔曲线连接
  void _drawBezierConnection(Canvas canvas, Offset start, Offset end,
      Paint linePaint, Paint arrowPaint) {
    final path = Path();

    // 计算控制点，创建平滑的曲线
    final controlPointOffset = (end - start).distance * 0.3;
    final controlPoint1 = Offset(start.dx + controlPointOffset, start.dy);
    final controlPoint2 = Offset(end.dx - controlPointOffset, end.dy);

    path.moveTo(start.dx, start.dy);
    path.cubicTo(
      controlPoint1.dx,
      controlPoint1.dy,
      controlPoint2.dx,
      controlPoint2.dy,
      end.dx,
      end.dy,
    );

    // 绘制路径
    canvas.drawPath(path, linePaint);

    // 绘制箭头
    _drawArrowHead(canvas, start, end, arrowPaint);
  }

  // 绘制箭头头部
  void _drawArrowHead(
      Canvas canvas, Offset start, Offset end, Paint arrowPaint) {
    const arrowSize = 12.0;
    final direction = (end - start).direction;

    final arrowP1 = end + Offset.fromDirection(direction + 2.618, arrowSize);
    final arrowP2 = end + Offset.fromDirection(direction - 2.618, arrowSize);

    final arrowPath = Path()
      ..moveTo(end.dx, end.dy)
      ..lineTo(arrowP1.dx, arrowP1.dy)
      ..lineTo(arrowP2.dx, arrowP2.dy)
      ..close();

    canvas.drawPath(arrowPath, arrowPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
