import 'package:flutter/material.dart';
import '../../../providers/enhanced_workflow_provider.dart';
import 'connection_painter.dart';

/// 工作流画布组件 - 提供可缩放、可拖拽的画布容器
class WorkflowCanvas extends StatefulWidget {
  final List<EnhancedTaskNode> tasks;
  final Function(String taskId) onTaskTap;
  final Function(String taskId, Offset position)? onTaskMoved;
  final Widget Function(EnhancedTaskNode task) taskBuilder;
  final bool isEditable;

  const WorkflowCanvas({
    super.key,
    required this.tasks,
    required this.onTaskTap,
    required this.taskBuilder,
    this.onTaskMoved,
    this.isEditable = false,
  });

  @override
  State<WorkflowCanvas> createState() => _WorkflowCanvasState();
}

class _WorkflowCanvasState extends State<WorkflowCanvas> {
  late TransformationController _transformationController;
  double _currentScale = 1.0;
  final double _minScale = 0.5;
  final double _maxScale = 3.0;

  @override
  void initState() {
    super.initState();
    _transformationController = TransformationController();
  }

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: InteractiveViewer(
          transformationController: _transformationController,
          minScale: _minScale,
          maxScale: _maxScale,
          onInteractionUpdate: (details) {
            setState(() {
              _currentScale = details.scale;
            });
          },
          child: Container(
            width: 2000,
            height: 1500,
            child: CustomPaint(
              painter: GridPainter(),
              child: Stack(
                children: [
                  // 连接线层
                  CustomPaint(
                    size: const Size(2000, 1500),
                    painter: ConnectionPainter(
                      tasks: widget.tasks,
                      scale: _currentScale,
                    ),
                  ),
                  // 任务节点层
                  ...widget.tasks.map((task) => _buildTaskNode(task)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTaskNode(EnhancedTaskNode task) {
    final position = _getTaskPosition(task.id);

    return Positioned(
      left: position.dx,
      top: position.dy,
      child: GestureDetector(
        onTap: () => widget.onTaskTap(task.id),
        onPanUpdate: widget.isEditable
            ? (details) {
                if (widget.onTaskMoved != null) {
                  final newPosition = position + details.delta;
                  widget.onTaskMoved!(task.id, newPosition);
                }
              }
            : null,
        child: widget.taskBuilder(task),
      ),
    );
  }

  Offset _getTaskPosition(String taskId) {
    // 简单的布局算法：按依赖关系排列
    final taskIndex = widget.tasks.indexWhere((t) => t.id == taskId);
    if (taskIndex == -1) return const Offset(100, 100);

    final row = taskIndex ~/ 3;
    final col = taskIndex % 3;
    return Offset(100 + col * 250.0, 100 + row * 150.0);
  }
}

/// 网格背景绘制器
class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey[200]!
      ..strokeWidth = 0.5;

    const gridSize = 20.0;

    // 绘制垂直线
    for (double x = 0; x < size.width; x += gridSize) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }

    // 绘制水平线
    for (double y = 0; y < size.height; y += gridSize) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
