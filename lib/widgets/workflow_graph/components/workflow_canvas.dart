import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';
import '../../../providers/enhanced_workflow_provider.dart';

/// 工作流画布组件 - 支持缩放和平移
class WorkflowCanvas extends StatefulWidget {
  final List<EnhancedTaskNode> tasks;
  final Widget Function(EnhancedTaskNode, int) taskBuilder;
  final CustomPainter connectionPainter;
  final Function(String taskId, Offset constrainedPosition)?
      onTaskPositionUpdate;

  const WorkflowCanvas({
    super.key,
    required this.tasks,
    required this.taskBuilder,
    required this.connectionPainter,
    this.onTaskPositionUpdate,
  });

  @override
  State<WorkflowCanvas> createState() => _WorkflowCanvasState();
}

class _WorkflowCanvasState extends State<WorkflowCanvas> {
  late TransformationController _transformationController;
  late FocusNode _focusNode;
  double _scale = 1.0;
  bool _isCtrlPressed = false;
  Size? _canvasSize;

  @override
  void initState() {
    super.initState();
    _transformationController = TransformationController();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _transformationController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final screenHeight = constraints.maxHeight;

        // 保存画布尺寸用于边界检查
        _canvasSize = Size(screenWidth, screenHeight);

        return RawKeyboardListener(
          focusNode: _focusNode,
          autofocus: true,
          onKey: _handleKeyEvent,
          child: Listener(
            onPointerSignal: _handlePointerSignal,
            child: InteractiveViewer(
              transformationController: _transformationController,
              boundaryMargin: const EdgeInsets.all(50), // 减小边界，防止拖出太远
              minScale: 0.3,
              maxScale: 3.0,
              constrained: false,
              onInteractionUpdate: _handleInteractionUpdate,
              child: Container(
                width: screenWidth * 2, // 适度扩大画布范围
                height: screenHeight * 2,
                child: Stack(
                  children: [
                    // 背景网格
                    CustomPaint(
                      size: Size(screenWidth * 2, screenHeight * 2),
                      painter: GridPainter(scale: _scale),
                    ),
                    // 连线层
                    CustomPaint(
                      size: Size(screenWidth * 2, screenHeight * 2),
                      painter: widget.connectionPainter,
                    ),
                    // 任务节点层
                    ...widget.tasks.asMap().entries.map((entry) {
                      final index = entry.key;
                      final task = entry.value;
                      return _buildConstrainedTaskNode(task, index);
                    }).toList(),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// 构建带边界约束的任务节点
  Widget _buildConstrainedTaskNode(EnhancedTaskNode task, int index) {
    return widget.taskBuilder(task, index);
  }

  /// 处理键盘事件，检测Ctrl键状态
  void _handleKeyEvent(RawKeyEvent event) {
    setState(() {
      _isCtrlPressed = event.isControlPressed;
    });
  }

  /// 约束任务位置在可视区域内
  Offset constrainTaskPosition(Offset position, Size taskSize) {
    if (_canvasSize == null) return position;

    const double margin = 20.0; // 边距
    final double maxX = _canvasSize!.width * 2 - taskSize.width - margin;
    final double maxY = _canvasSize!.height * 2 - taskSize.height - margin;

    return Offset(
      position.dx.clamp(margin, maxX),
      position.dy.clamp(margin, maxY),
    );
  }

  void _handlePointerSignal(PointerSignalEvent event) {
    if (event is PointerScrollEvent) {
      // 只有在按住Ctrl键时才允许缩放
      if (_isCtrlPressed && event.scrollDelta.dy != 0) {
        final double zoomFactor = event.scrollDelta.dy > 0 ? 0.9 : 1.1;
        final Matrix4 matrix = _transformationController.value.clone();

        // 计算缩放中心点
        final Offset focalPoint = event.localPosition;

        // 应用缩放
        matrix.translate(focalPoint.dx, focalPoint.dy);
        matrix.scale(zoomFactor);
        matrix.translate(-focalPoint.dx, -focalPoint.dy);

        // 检查缩放范围
        final double newScale = matrix.getMaxScaleOnAxis();
        if (newScale >= 0.3 && newScale <= 3.0) {
          _transformationController.value = matrix;

          setState(() {
            _scale = newScale;
          });
        }
      }
      // 如果没有按Ctrl键，滚轮事件不做任何处理，允许页面正常滚动
    }
  }

  void _handleInteractionUpdate(ScaleUpdateDetails details) {
    setState(() {
      _scale = _transformationController.value.getMaxScaleOnAxis();
    });
  }
}

/// 网格背景绘制器
class GridPainter extends CustomPainter {
  final double scale;

  GridPainter({this.scale = 1.0});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey[200]!.withOpacity(0.6)
      ..strokeWidth = 0.5 / scale.clamp(0.5, 2.0); // 根据缩放调整线条粗细

    double gridSize = 20.0;

    // 根据缩放级别调整网格大小
    if (scale < 0.5) {
      gridSize = 80.0;
    } else if (scale < 1.0) {
      gridSize = 40.0;
    }

    // 绘制垂直线
    for (double x = 0; x <= size.width; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // 绘制水平线
    for (double y = 0; y <= size.height; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(GridPainter oldDelegate) => oldDelegate.scale != scale;
}
