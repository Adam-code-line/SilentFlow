import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../providers/enhanced_workflow_provider.dart';

/// 连接线绘制器 - 专门处理任务节点之间的连接线绘制
class ConnectionPainter extends CustomPainter {
  final List<EnhancedTaskNode> tasks;
  final double scale;
  final String? highlightedConnectionId;
  final Color? connectionColor;

  ConnectionPainter({
    required this.tasks,
    required this.scale,
    this.highlightedConnectionId,
    this.connectionColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final defaultPaint = Paint()
      ..color = connectionColor ?? Colors.blue[400]!
      ..strokeWidth = 2.0 / scale
      ..style = PaintingStyle.stroke;

    final highlightPaint = Paint()
      ..color = Colors.orange
      ..strokeWidth = 3.0 / scale
      ..style = PaintingStyle.stroke;

    final arrowPaint = Paint()
      ..color = connectionColor ?? Colors.blue[600]!
      ..style = PaintingStyle.fill;

    final highlightArrowPaint = Paint()
      ..color = Colors.orange[700]!
      ..style = PaintingStyle.fill;

    // 绘制任务之间的连接线
    for (final task in tasks) {
      if (task.dependencies.isNotEmpty) {
        for (final depId in task.dependencies) {
          final depTask = tasks.firstWhere(
            (t) => t.id == depId,
            orElse: () => EnhancedTaskNode(
              id: '',
              title: '',
              description: '',
              status: EnhancedTaskStatus.pending,
              priority: EnhancedTaskPriority.medium,
              progress: 0,
              dependencies: [],
            ),
          );

          if (depTask.id.isNotEmpty) {
            final connectionId = '${depTask.id}_${task.id}';
            final isHighlighted = highlightedConnectionId == connectionId;

            _drawConnection(
              canvas,
              _getTaskPosition(depTask.id),
              _getTaskPosition(task.id),
              isHighlighted ? highlightPaint : defaultPaint,
              isHighlighted ? highlightArrowPaint : arrowPaint,
            );
          }
        }
      }
    }
  }

  Offset _getTaskPosition(String taskId) {
    final taskIndex = tasks.indexWhere((t) => t.id == taskId);
    if (taskIndex == -1) return const Offset(100, 100);

    final row = taskIndex ~/ 3;
    final col = taskIndex % 3;
    return Offset(100 + col * 250.0, 100 + row * 150.0);
  }

  void _drawConnection(
    Canvas canvas,
    Offset from,
    Offset to,
    Paint linePaint,
    Paint arrowPaint,
  ) {
    // 计算节点中心点（假设节点大小为200x120）
    final fromCenter = from + const Offset(100, 60);
    final toCenter = to + const Offset(100, 60);

    // 计算连接点（节点边缘）
    final connectionPoints = _calculateConnectionPoints(
      fromCenter,
      toCenter,
      const Size(200, 120),
    );

    // 绘制贝塞尔曲线连接线
    _drawBezierConnection(
      canvas,
      connectionPoints.from,
      connectionPoints.to,
      linePaint,
    );

    // 绘制箭头
    _drawArrow(canvas, connectionPoints.from, connectionPoints.to, arrowPaint);
  }

  ConnectionPoints _calculateConnectionPoints(
    Offset fromCenter,
    Offset toCenter,
    Size nodeSize,
  ) {
    final direction = toCenter - fromCenter;
    final distance = direction.distance;
    final normalizedDirection = direction / distance;

    // 计算节点边缘的连接点
    final halfWidth = nodeSize.width / 2;
    final halfHeight = nodeSize.height / 2;

    // 从起始节点的右边缘出发
    final fromEdge = fromCenter + Offset(halfWidth, 0);
    // 到达目标节点的左边缘
    final toEdge = toCenter - Offset(halfWidth, 0);

    return ConnectionPoints(from: fromEdge, to: toEdge);
  }

  void _drawBezierConnection(
    Canvas canvas,
    Offset from,
    Offset to,
    Paint paint,
  ) {
    final path = Path();
    path.moveTo(from.dx, from.dy);

    // 计算控制点，创建平滑的贝塞尔曲线
    final distance = (to - from).distance;
    final controlOffset = distance * 0.3;

    final control1 = from + Offset(controlOffset, 0);
    final control2 = to - Offset(controlOffset, 0);

    path.cubicTo(
      control1.dx,
      control1.dy,
      control2.dx,
      control2.dy,
      to.dx,
      to.dy,
    );

    canvas.drawPath(path, paint);
  }

  void _drawArrow(Canvas canvas, Offset from, Offset to, Paint paint) {
    const arrowLength = 12.0;
    const arrowAngle = 0.5;

    final direction = (to - from).direction;

    // 箭头指向目标点稍微偏移一点，避免箭头被节点遮挡
    final arrowTip = to - Offset(15, 0);

    final arrowPoint1 = arrowTip +
        Offset(
          arrowLength * math.cos(direction + arrowAngle + math.pi),
          arrowLength * math.sin(direction + arrowAngle + math.pi),
        );
    final arrowPoint2 = arrowTip +
        Offset(
          arrowLength * math.cos(direction - arrowAngle + math.pi),
          arrowLength * math.sin(direction - arrowAngle + math.pi),
        );

    final arrowPath = Path()
      ..moveTo(arrowTip.dx, arrowTip.dy)
      ..lineTo(arrowPoint1.dx, arrowPoint1.dy)
      ..lineTo(arrowPoint2.dx, arrowPoint2.dy)
      ..close();

    canvas.drawPath(arrowPath, paint);
  }

  @override
  bool shouldRepaint(covariant ConnectionPainter oldDelegate) {
    return oldDelegate.tasks != tasks ||
        oldDelegate.scale != scale ||
        oldDelegate.highlightedConnectionId != highlightedConnectionId ||
        oldDelegate.connectionColor != connectionColor;
  }
}

/// 连接点数据类
class ConnectionPoints {
  final Offset from;
  final Offset to;

  const ConnectionPoints({
    required this.from,
    required this.to,
  });
}

/// 高级连接线绘制器 - 支持动画和交互效果
class AnimatedConnectionPainter extends CustomPainter {
  final List<EnhancedTaskNode> tasks;
  final double scale;
  final double animationValue;
  final Set<String> highlightedTaskIds;

  AnimatedConnectionPainter({
    required this.tasks,
    required this.scale,
    required this.animationValue,
    this.highlightedTaskIds = const {},
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final task in tasks) {
      if (task.dependencies.isNotEmpty) {
        for (final depId in task.dependencies) {
          final depTask = tasks.firstWhere(
            (t) => t.id == depId,
            orElse: () => EnhancedTaskNode(
              id: '',
              title: '',
              description: '',
              status: EnhancedTaskStatus.pending,
              priority: EnhancedTaskPriority.medium,
              progress: 0,
              dependencies: [],
            ),
          );

          if (depTask.id.isNotEmpty) {
            final isHighlighted = highlightedTaskIds.contains(task.id) ||
                highlightedTaskIds.contains(depTask.id);

            _drawAnimatedConnection(
              canvas,
              _getTaskPosition(depTask.id),
              _getTaskPosition(task.id),
              isHighlighted,
            );
          }
        }
      }
    }
  }

  Offset _getTaskPosition(String taskId) {
    final taskIndex = tasks.indexWhere((t) => t.id == taskId);
    if (taskIndex == -1) return const Offset(100, 100);

    final row = taskIndex ~/ 3;
    final col = taskIndex % 3;
    return Offset(100 + col * 250.0, 100 + row * 150.0);
  }

  void _drawAnimatedConnection(
    Canvas canvas,
    Offset from,
    Offset to,
    bool isHighlighted,
  ) {
    final fromCenter = from + const Offset(100, 60);
    final toCenter = to + const Offset(100, 60);

    // 基础连接线
    final basePaint = Paint()
      ..color = isHighlighted ? Colors.orange : Colors.blue[400]!
      ..strokeWidth = (isHighlighted ? 3.0 : 2.0) / scale
      ..style = PaintingStyle.stroke;

    // 流动效果
    if (isHighlighted) {
      _drawFlowingEffect(canvas, fromCenter, toCenter);
    }

    // 绘制主连接线
    final path = Path();
    path.moveTo(fromCenter.dx, fromCenter.dy);
    path.lineTo(toCenter.dx, toCenter.dy);
    canvas.drawPath(path, basePaint);

    // 绘制箭头
    _drawArrow(canvas, fromCenter, toCenter, basePaint);
  }

  void _drawFlowingEffect(Canvas canvas, Offset from, Offset to) {
    final direction = to - from;
    final distance = direction.distance;

    // 流动点的位置
    final flowPosition = animationValue % 1.0;
    final currentPos = from + direction * flowPosition;

    // 绘制流动的光点
    final glowPaint = Paint()
      ..color = Colors.orange.withOpacity(0.8)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(currentPos, 4.0 / scale, glowPaint);

    // 添加光晕效果
    final haloPaint = Paint()
      ..color = Colors.orange.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(currentPos, 8.0 / scale, haloPaint);
  }

  void _drawArrow(Canvas canvas, Offset from, Offset to, Paint paint) {
    const arrowLength = 12.0;
    const arrowAngle = 0.5;

    final direction = (to - from).direction;
    final arrowTip = to - Offset(15, 0);

    final arrowPoint1 = arrowTip +
        Offset(
          arrowLength * math.cos(direction + arrowAngle + math.pi),
          arrowLength * math.sin(direction + arrowAngle + math.pi),
        );
    final arrowPoint2 = arrowTip +
        Offset(
          arrowLength * math.cos(direction - arrowAngle + math.pi),
          arrowLength * math.sin(direction - arrowAngle + math.pi),
        );

    final arrowPath = Path()
      ..moveTo(arrowTip.dx, arrowTip.dy)
      ..lineTo(arrowPoint1.dx, arrowPoint1.dy)
      ..lineTo(arrowPoint2.dx, arrowPoint2.dy)
      ..close();

    canvas.drawPath(arrowPath, paint);
  }

  @override
  bool shouldRepaint(covariant AnimatedConnectionPainter oldDelegate) {
    return oldDelegate.tasks != tasks ||
        oldDelegate.scale != scale ||
        oldDelegate.animationValue != animationValue ||
        oldDelegate.highlightedTaskIds != highlightedTaskIds;
  }
}
