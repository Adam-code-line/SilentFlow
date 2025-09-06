import 'package:flutter/material.dart';
import '../../../providers/enhanced_workflow_provider.dart';

/// 任务节点组件
class TaskNodeWidget extends StatelessWidget {
  final EnhancedTaskNode task;
  final bool isDragging;
  final bool isHovered;
  final bool isSelected;
  final bool isConnectionMode;
  final String? connectionFromTaskId;
  final VoidCallback? onTap;
  final VoidCallback? onDoubleTap;
  final Function(DragStartDetails)? onPanStart;
  final Function(DragUpdateDetails)? onPanUpdate;
  final Function(DragEndDetails)? onPanEnd;
  final Function(bool)? onHover;

  const TaskNodeWidget({
    super.key,
    required this.task,
    this.isDragging = false,
    this.isHovered = false,
    this.isSelected = false,
    this.isConnectionMode = false,
    this.connectionFromTaskId,
    this.onTap,
    this.onDoubleTap,
    this.onPanStart,
    this.onPanUpdate,
    this.onPanEnd,
    this.onHover,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => onHover?.call(true),
      onExit: (_) => onHover?.call(false),
      child: GestureDetector(
        onTap: onTap,
        onDoubleTap: onDoubleTap,
        onPanStart: onPanStart,
        onPanUpdate: onPanUpdate,
        onPanEnd: onPanEnd,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          transform: Matrix4.identity()
            ..scale(isDragging ? 1.05 : (isHovered ? 1.02 : 1.0)),
          child: Container(
            width: 200,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _getTaskColor(task.status),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _getTaskBorderColor(),
                width: (isSelected || isConnectionMode) ? 3 : 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black
                      .withOpacity(isDragging ? 0.3 : (isHovered ? 0.15 : 0.1)),
                  blurRadius: isDragging ? 20 : (isHovered ? 12 : 8),
                  offset: Offset(0, isDragging ? 8 : (isHovered ? 4 : 2)),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // 标题和状态图标
                Row(
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Icon(
                        _getTaskIcon(task.status),
                        size: 20,
                        color: Colors.white,
                        key: ValueKey(task.status),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        task.title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isConnectionMode)
                      Icon(
                        Icons.radio_button_unchecked,
                        size: 16,
                        color: Colors.white70,
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                // 进度条
                _buildAnimatedProgressBar(),
                const SizedBox(height: 8),
                // 优先级标签
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildPriorityChip(),
                    Text(
                      '${task.progress}%',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedProgressBar() {
    return Container(
      height: 6,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.3),
        borderRadius: BorderRadius.circular(3),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: task.progress / 100,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 800),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
      ),
    );
  }

  Widget _buildPriorityChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        _getPriorityText(task.priority),
        style: const TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }

  Color _getTaskColor(EnhancedTaskStatus status) {
    switch (status) {
      case EnhancedTaskStatus.pending:
        return const Color(0xFFF6AD55);
      case EnhancedTaskStatus.inProgress:
        return const Color(0xFF4299E1);
      case EnhancedTaskStatus.completed:
        return const Color(0xFF48BB78);
      case EnhancedTaskStatus.blocked:
        return const Color(0xFFF56565);
    }
  }

  Color _getTaskBorderColor() {
    // 连接模式下的特殊颜色
    if (isConnectionMode) {
      if (connectionFromTaskId != null) {
        if (connectionFromTaskId == task.id) {
          return Colors.blue[700]!; // 已选择的源任务
        } else {
          return Colors.green[500]!; // 可连接的目标任务
        }
      }
      return Colors.blue[300]!; // 连接模式下的默认颜色
    }

    // 选中状态
    if (isSelected) {
      return const Color(0xFF4C51BF);
    }

    // 根据任务状态的默认颜色
    switch (task.status) {
      case EnhancedTaskStatus.pending:
        return const Color(0xFFED8936);
      case EnhancedTaskStatus.inProgress:
        return const Color(0xFF3182CE);
      case EnhancedTaskStatus.completed:
        return const Color(0xFF38A169);
      case EnhancedTaskStatus.blocked:
        return const Color(0xFFE53E3E);
    }
  }

  IconData _getTaskIcon(EnhancedTaskStatus status) {
    switch (status) {
      case EnhancedTaskStatus.pending:
        return Icons.schedule;
      case EnhancedTaskStatus.inProgress:
        return Icons.play_circle_filled;
      case EnhancedTaskStatus.completed:
        return Icons.check_circle;
      case EnhancedTaskStatus.blocked:
        return Icons.block;
    }
  }

  String _getPriorityText(EnhancedTaskPriority priority) {
    switch (priority) {
      case EnhancedTaskPriority.low:
        return '低';
      case EnhancedTaskPriority.medium:
        return '中';
      case EnhancedTaskPriority.high:
        return '高';
    }
  }
}
