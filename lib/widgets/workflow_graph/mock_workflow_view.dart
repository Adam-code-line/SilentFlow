import 'package:flutter/material.dart';
import '../../models/team_pool_model.dart';

/// 简化的工作流图组件 - 使用纯UI模拟数据，不依赖后端
class MockWorkflowView extends StatefulWidget {
  final TeamPool team;
  final bool isEditable;
  final Function(String taskId)? onTaskTap;

  const MockWorkflowView({
    super.key,
    required this.team,
    this.isEditable = false,
    this.onTaskTap,
  });

  @override
  State<MockWorkflowView> createState() => _MockWorkflowViewState();
}

class _MockWorkflowViewState extends State<MockWorkflowView> {
  final List<MockTaskNode> _mockTasks = [];

  @override
  void initState() {
    super.initState();
    _generateMockTasks();
  }

  void _generateMockTasks() {
    _mockTasks.addAll([
      MockTaskNode(
        id: 'task_1',
        title: '需求分析',
        description: '分析项目需求和功能点',
        status: MockTaskStatus.completed,
        priority: MockTaskPriority.high,
        progress: 100,
      ),
      MockTaskNode(
        id: 'task_2',
        title: '架构设计',
        description: '设计系统架构和技术方案',
        status: MockTaskStatus.inProgress,
        priority: MockTaskPriority.high,
        progress: 60,
      ),
      MockTaskNode(
        id: 'task_3',
        title: '前端开发',
        description: '实现用户界面和交互逻辑',
        status: MockTaskStatus.pending,
        priority: MockTaskPriority.medium,
        progress: 0,
      ),
      MockTaskNode(
        id: 'task_4',
        title: '后端开发',
        description: '实现服务端逻辑和API接口',
        status: MockTaskStatus.pending,
        priority: MockTaskPriority.medium,
        progress: 0,
      ),
      MockTaskNode(
        id: 'task_5',
        title: '测试验证',
        description: '进行功能测试和性能优化',
        status: MockTaskStatus.pending,
        priority: MockTaskPriority.low,
        progress: 0,
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 20),
          Expanded(
            child: _buildWorkflowGraph(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = constraints.maxWidth < 600;

        return Flex(
          direction: isSmallScreen ? Axis.vertical : Axis.horizontal,
          mainAxisAlignment: isSmallScreen
              ? MainAxisAlignment.start
              : MainAxisAlignment.spaceBetween,
          crossAxisAlignment: isSmallScreen
              ? CrossAxisAlignment.center
              : CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: isSmallScreen
                  ? CrossAxisAlignment.center
                  : CrossAxisAlignment.start,
              children: [
                Text(
                  '${widget.team.name} - 工作流程图',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 18 : 20,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2D3748),
                  ),
                  textAlign: isSmallScreen ? TextAlign.center : TextAlign.start,
                ),
                const SizedBox(height: 4),
                Text(
                  '共 ${_mockTasks.length} 个任务',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 12 : 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            if (isSmallScreen) const SizedBox(height: 16),
            if (widget.isEditable)
              ElevatedButton.icon(
                onPressed: _showAddTaskDialog,
                icon: Icon(Icons.add, size: isSmallScreen ? 16 : 18),
                label: const Text('添加任务'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4C51BF),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                      horizontal: isSmallScreen ? 12 : 16,
                      vertical: isSmallScreen ? 6 : 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildWorkflowGraph() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final screenHeight = constraints.maxHeight;

        // 响应式计算任务卡片大小和间距
        final double cardWidth = _getResponsiveCardWidth(screenWidth);
        final double cardSpacing = _getResponsiveCardSpacing(screenWidth);
        final double totalWidth =
            _mockTasks.length * (cardWidth + cardSpacing) + cardSpacing;

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Container(
              width: totalWidth.clamp(screenWidth, double.infinity),
              height: screenHeight.clamp(400.0, double.infinity),
              child: CustomPaint(
                painter: MockWorkflowPainter(
                  tasks: _mockTasks,
                  getTaskPosition: (index) => _getResponsiveTaskPosition(
                      index, cardWidth, cardSpacing, screenHeight),
                ),
                child: Stack(
                  children: _mockTasks.asMap().entries.map((entry) {
                    final index = entry.key;
                    final task = entry.value;
                    return _buildResponsiveTaskNode(
                        task, index, cardWidth, cardSpacing, screenHeight);
                  }).toList(),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // 响应式计算卡片宽度
  double _getResponsiveCardWidth(double screenWidth) {
    if (screenWidth < 600) return 160; // 小屏幕
    if (screenWidth < 1200) return 180; // 中等屏幕
    return 200; // 大屏幕
  }

  // 响应式计算卡片间距
  double _getResponsiveCardSpacing(double screenWidth) {
    if (screenWidth < 600) return 20; // 小屏幕
    if (screenWidth < 1200) return 30; // 中等屏幕
    return 40; // 大屏幕
  }

  // 响应式任务位置计算
  Offset _getResponsiveTaskPosition(
      int index, double cardWidth, double cardSpacing, double screenHeight) {
    final double leftPosition = index * (cardWidth + cardSpacing) + cardSpacing;
    final double verticalSpacing = screenHeight < 500 ? 80 : 120;
    final double topPosition = 60.0 + (index % 2) * verticalSpacing;
    return Offset(leftPosition, topPosition);
  }

  Widget _buildResponsiveTaskNode(MockTaskNode task, int index,
      double cardWidth, double cardSpacing, double screenHeight) {
    final position =
        _getResponsiveTaskPosition(index, cardWidth, cardSpacing, screenHeight);
    final fontSize = _getResponsiveFontSize(cardWidth);

    return Positioned(
      left: position.dx,
      top: position.dy,
      child: GestureDetector(
        onTap: () => widget.onTaskTap?.call(task.id),
        child: Container(
          width: cardWidth,
          padding: EdgeInsets.all(cardWidth < 170 ? 12 : 16),
          decoration: BoxDecoration(
            color: _getTaskColor(task.status),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _getTaskBorderColor(task.status),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildResponsivePriorityChip(task.priority, fontSize),
                  Icon(
                    _getTaskIcon(task.status),
                    color: Colors.white,
                    size: fontSize.title,
                  ),
                ],
              ),
              SizedBox(height: cardWidth < 170 ? 8 : 12),
              Text(
                task.title,
                style: TextStyle(
                  fontSize: fontSize.title,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: cardWidth < 170 ? 6 : 8),
              Text(
                task.description,
                style: TextStyle(
                  fontSize: fontSize.description,
                  color: Colors.white.withOpacity(0.9),
                ),
                maxLines: cardWidth < 170 ? 1 : 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: cardWidth < 170 ? 8 : 12),
              // 进度条
              Container(
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: task.progress / 100,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '${task.progress}% 完成',
                style: TextStyle(
                  fontSize: fontSize.progress,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 响应式字体大小
  ResponsiveFontSizes _getResponsiveFontSize(double cardWidth) {
    if (cardWidth < 170) {
      return const ResponsiveFontSizes(
        title: 12.0,
        description: 10.0,
        progress: 9.0,
        priority: 8.0,
      );
    } else if (cardWidth < 190) {
      return const ResponsiveFontSizes(
        title: 14.0,
        description: 12.0,
        progress: 10.0,
        priority: 9.0,
      );
    } else {
      return const ResponsiveFontSizes(
        title: 16.0,
        description: 13.0,
        progress: 11.0,
        priority: 10.0,
      );
    }
  }

  Widget _buildResponsivePriorityChip(
      MockTaskPriority priority, ResponsiveFontSizes fontSize) {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: fontSize.priority > 9 ? 8 : 6,
          vertical: fontSize.priority > 9 ? 4 : 3),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.5), width: 1),
      ),
      child: Text(
        _getPriorityText(priority),
        style: TextStyle(
          fontSize: fontSize.priority,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }

  Color _getTaskColor(MockTaskStatus status) {
    switch (status) {
      case MockTaskStatus.pending:
        return const Color(0xFFF6AD55);
      case MockTaskStatus.inProgress:
        return const Color(0xFF4299E1);
      case MockTaskStatus.completed:
        return const Color(0xFF48BB78);
      case MockTaskStatus.blocked:
        return const Color(0xFFF56565);
    }
  }

  Color _getTaskBorderColor(MockTaskStatus status) {
    switch (status) {
      case MockTaskStatus.pending:
        return const Color(0xFFED8936);
      case MockTaskStatus.inProgress:
        return const Color(0xFF3182CE);
      case MockTaskStatus.completed:
        return const Color(0xFF38A169);
      case MockTaskStatus.blocked:
        return const Color(0xFFE53E3E);
    }
  }

  IconData _getTaskIcon(MockTaskStatus status) {
    switch (status) {
      case MockTaskStatus.pending:
        return Icons.schedule;
      case MockTaskStatus.inProgress:
        return Icons.play_circle_filled;
      case MockTaskStatus.completed:
        return Icons.check_circle;
      case MockTaskStatus.blocked:
        return Icons.block;
    }
  }

  String _getPriorityText(MockTaskPriority priority) {
    switch (priority) {
      case MockTaskPriority.low:
        return '低';
      case MockTaskPriority.medium:
        return '中';
      case MockTaskPriority.high:
        return '高';
    }
  }

  void _showAddTaskDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('添加新任务'),
        content: const Text('任务创建功能开发中...'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('任务创建功能即将上线')),
              );
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
}

class MockWorkflowPainter extends CustomPainter {
  final List<MockTaskNode> tasks;
  final Offset Function(int index) getTaskPosition;

  MockWorkflowPainter({
    required this.tasks,
    required this.getTaskPosition,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = Colors.grey[400]!
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;

    final arrowPaint = Paint()
      ..color = Colors.grey[500]!
      ..style = PaintingStyle.fill;

    for (int i = 0; i < tasks.length - 1; i++) {
      final fromPosition = getTaskPosition(i);
      final toPosition = getTaskPosition(i + 1);

      final fromOffset = Offset(fromPosition.dx + 90, fromPosition.dy + 60);
      final toOffset = Offset(toPosition.dx + 90, toPosition.dy + 60);

      // 绘制连线
      canvas.drawLine(fromOffset, toOffset, linePaint);

      // 绘制箭头
      _drawArrow(canvas, fromOffset, toOffset, arrowPaint);
    }
  }

  void _drawArrow(Canvas canvas, Offset start, Offset end, Paint paint) {
    const arrowSize = 10.0;
    final direction = (end - start).direction;
    final arrowP1 =
        end + Offset.fromDirection(direction + 3.14159 * 0.8, arrowSize);
    final arrowP2 =
        end + Offset.fromDirection(direction - 3.14159 * 0.8, arrowSize);

    final path = Path()
      ..moveTo(end.dx, end.dy)
      ..lineTo(arrowP1.dx, arrowP1.dy)
      ..lineTo(arrowP2.dx, arrowP2.dy)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

// 简化的模拟数据类
class MockTaskNode {
  final String id;
  final String title;
  final String description;
  final MockTaskStatus status;
  final MockTaskPriority priority;
  final int progress;

  MockTaskNode({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.priority,
    required this.progress,
  });
}

enum MockTaskStatus { pending, inProgress, completed, blocked }

enum MockTaskPriority { low, medium, high }

// 响应式字体大小配置
class ResponsiveFontSizes {
  final double title;
  final double description;
  final double progress;
  final double priority;

  const ResponsiveFontSizes({
    required this.title,
    required this.description,
    required this.progress,
    required this.priority,
  });
}
