import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../models/team_pool_model.dart';
import '../../models/task_model.dart';

class WorkflowGraphView extends StatefulWidget {
  final TeamPool team;
  final bool isEditable;
  final Function(String taskId)? onTaskTap;

  const WorkflowGraphView({
    super.key,
    required this.team,
    this.isEditable = false,
    this.onTaskTap,
  });

  @override
  State<WorkflowGraphView> createState() => _WorkflowGraphViewState();
}

class _WorkflowGraphViewState extends State<WorkflowGraphView> {
  final List<Task> _mockTasks = [];

  @override
  void initState() {
    super.initState();
    _generateMockTasks();
  }

  void _generateMockTasks() {
    // 为每个团队生成一些模拟任务数据
    _mockTasks.addAll([
      Task(
        id: 'task_1_${widget.team.id}',
        title: '需求分析',
        description: '分析项目需求和功能点',
        status: TaskStatus.completed,
        priority: TaskPriority.high,
        assigneeId: widget.team.leaderId,
        poolId: widget.team.id,
        statistics: TaskStatistics(
          actualMinutes: 2400, // 5 days * 8 hours * 60 minutes
          contributionScore: 100.0,
          tacitScore: 85.0,
          collaborationEvents: 12,
        ),
        createdAt: DateTime.now().subtract(const Duration(days: 7)),
        dueDate: DateTime.now().subtract(const Duration(days: 5)),
      ),
      Task(
        id: 'task_2_${widget.team.id}',
        title: '架构设计',
        description: '设计系统架构和技术方案',
        status: TaskStatus.inProgress,
        priority: TaskPriority.high,
        assigneeId: widget.team.memberIds.isNotEmpty
            ? widget.team.memberIds.first
            : widget.team.leaderId,
        poolId: widget.team.id,
        statistics: TaskStatistics(
          actualMinutes: 960, // 2 days * 8 hours * 60 minutes
          contributionScore: 60.0,
          tacitScore: 55.0,
          collaborationEvents: 8,
        ),
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        dueDate: DateTime.now().add(const Duration(days: 2)),
      ),
      Task(
        id: 'task_3_${widget.team.id}',
        title: '前端开发',
        description: '实现用户界面和交互逻辑',
        status: TaskStatus.pending,
        priority: TaskPriority.medium,
        assigneeId: widget.team.memberIds.length > 1
            ? widget.team.memberIds[1]
            : widget.team.leaderId,
        poolId: widget.team.id,
        statistics: const TaskStatistics(
          actualMinutes: 0,
          contributionScore: 0.0,
          tacitScore: 0.0,
          collaborationEvents: 0,
        ),
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        dueDate: DateTime.now().add(const Duration(days: 5)),
      ),
      Task(
        id: 'task_4_${widget.team.id}',
        title: '后端开发',
        description: '实现服务端逻辑和API接口',
        status: TaskStatus.pending,
        priority: TaskPriority.medium,
        assigneeId: widget.team.memberIds.length > 2
            ? widget.team.memberIds[2]
            : widget.team.leaderId,
        poolId: widget.team.id,
        statistics: const TaskStatistics(
          actualMinutes: 0,
          contributionScore: 0.0,
          tacitScore: 0.0,
          collaborationEvents: 0,
        ),
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        dueDate: DateTime.now().add(const Duration(days: 7)),
      ),
      Task(
        id: 'task_5_${widget.team.id}',
        title: '测试验证',
        description: '进行功能测试和性能优化',
        status: TaskStatus.pending,
        priority: TaskPriority.low,
        assigneeId: widget.team.leaderId,
        poolId: widget.team.id,
        statistics: TaskStatistics(
          actualMinutes: 0,
          contributionScore: 0.0,
          tacitScore: 0.0,
          collaborationEvents: 0,
        ),
        createdAt: DateTime.now(),
        dueDate: DateTime.now().add(const Duration(days: 10)),
      ),
    ]);
  }

  // 计算任务节点位置
  Offset _getTaskPosition(int index) {
    final double leftPosition = index * 200.0 + 50;
    final double topPosition = 100.0 + (index % 2) * 100;
    return Offset(leftPosition, topPosition);
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${widget.team.name} - 工作流程图',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3748),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '共 ${_mockTasks.length} 个任务',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        if (widget.isEditable)
          ElevatedButton.icon(
            onPressed: _showAddTaskDialog,
            icon: const Icon(Icons.add, size: 18),
            label: const Text('添加任务'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4C51BF),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildWorkflowGraph() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        width: _mockTasks.length * 200.0 + 100,
        height: double.infinity,
        child: CustomPaint(
          painter: WorkflowPainter(
            tasks: _mockTasks,
            getTaskPosition: _getTaskPosition,
          ),
          child: Stack(
            children: _mockTasks.asMap().entries.map((entry) {
              final index = entry.key;
              final task = entry.value;
              return _buildTaskNode(task, index);
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildTaskNode(Task task, int index) {
    final position = _getTaskPosition(index);

    return Positioned(
      left: position.dx,
      top: position.dy,
      child: GestureDetector(
        onTap: () => widget.onTaskTap?.call(task.id),
        child: Container(
          width: 140,
          padding: const EdgeInsets.all(12),
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
                children: [
                  Icon(
                    _getTaskIcon(task.status),
                    size: 16,
                    color: _getTaskIconColor(task.status),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      task.title,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                task.description ?? '',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.white.withOpacity(0.9),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              _buildPriorityChip(task.priority),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriorityChip(TaskPriority priority) {
    final color = _getPriorityColor(priority);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        _getPriorityText(priority),
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Color _getTaskColor(TaskStatus status) {
    switch (status) {
      case TaskStatus.pending:
        return const Color(0xFFF6AD55);
      case TaskStatus.inProgress:
        return const Color(0xFF4299E1);
      case TaskStatus.completed:
        return const Color(0xFF48BB78);
      case TaskStatus.blocked:
        return const Color(0xFFF56565);
    }
  }

  Color _getTaskBorderColor(TaskStatus status) {
    switch (status) {
      case TaskStatus.pending:
        return const Color(0xFFED8936);
      case TaskStatus.inProgress:
        return const Color(0xFF3182CE);
      case TaskStatus.completed:
        return const Color(0xFF38A169);
      case TaskStatus.blocked:
        return const Color(0xFFE53E3E);
    }
  }

  IconData _getTaskIcon(TaskStatus status) {
    switch (status) {
      case TaskStatus.pending:
        return Icons.schedule;
      case TaskStatus.inProgress:
        return Icons.play_circle_filled;
      case TaskStatus.completed:
        return Icons.check_circle;
      case TaskStatus.blocked:
        return Icons.block;
    }
  }

  Color _getTaskIconColor(TaskStatus status) {
    return Colors.white;
  }

  Color _getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return Colors.green;
      case TaskPriority.medium:
        return Colors.orange;
      case TaskPriority.high:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getPriorityText(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return '低';
      case TaskPriority.medium:
        return '中';
      case TaskPriority.high:
        return '高';
      default:
        return '未知';
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
                const SnackBar(content: Text('功能开发中，敬请期待！')),
              );
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
}

class WorkflowPainter extends CustomPainter {
  final List<Task> tasks;
  final Offset Function(int index) getTaskPosition;

  WorkflowPainter({
    required this.tasks,
    required this.getTaskPosition,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 绘制任务节点连接线
    final linePaint = Paint()
      ..color = Colors.grey[300]!
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final arrowPaint = Paint()
      ..color = Colors.grey[400]!
      ..style = PaintingStyle.fill;

    for (int i = 0; i < tasks.length - 1; i++) {
      final fromPosition = getTaskPosition(i);
      final toPosition = getTaskPosition(i + 1);

      // 计算连线的起点和终点
      final fromOffset = Offset(fromPosition.dx + 70, fromPosition.dy + 30);
      final toOffset = Offset(toPosition.dx + 70, toPosition.dy);

      // 绘制连线
      canvas.drawLine(fromOffset, toOffset, linePaint);

      // 绘制箭头
      _drawArrow(canvas, fromOffset, toOffset, arrowPaint);
    }
  }

  void _drawArrow(Canvas canvas, Offset start, Offset end, Paint paint) {
    const arrowSize = 8.0;
    final direction = (end - start).direction;
    final arrowP1 =
        end + Offset.fromDirection(direction + math.pi * 0.8, arrowSize);
    final arrowP2 =
        end + Offset.fromDirection(direction - math.pi * 0.8, arrowSize);

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
