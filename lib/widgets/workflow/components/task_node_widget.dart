import 'package:flutter/material.dart';
import '../../../providers/enhanced_workflow_provider.dart';

/// 任务节点组件 - 在工作流图中显示的任务卡片
class TaskNodeWidget extends StatelessWidget {
  final EnhancedTaskNode task;
  final bool isSelected;
  final bool isHovered;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const TaskNodeWidget({
    super.key,
    required this.task,
    this.isSelected = false,
    this.isHovered = false,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 200,
      height: 120,
      decoration: BoxDecoration(
        color: _getBackgroundColor(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getBorderColor(context),
          width: isSelected ? 2.5 : 1.5,
        ),
        boxShadow: [
          if (isHovered || isSelected)
            BoxShadow(
              color: _getStatusColor().withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 8),
              _buildTitle(),
              const SizedBox(height: 6),
              _buildProgressBar(),
              const Spacer(),
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: _getStatusColor().withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            _getStatusText(),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: _getStatusColor(),
            ),
          ),
        ),
        if (onEdit != null || onDelete != null)
          PopupMenuButton<String>(
            padding: EdgeInsets.zero,
            iconSize: 16,
            itemBuilder: (context) => [
              if (onEdit != null)
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.edit, size: 16),
                      SizedBox(width: 8),
                      Text('编辑'),
                    ],
                  ),
                ),
              if (onDelete != null)
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.delete, size: 16, color: Colors.red),
                      SizedBox(width: 8),
                      Text('删除', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
            ],
            onSelected: (value) {
              switch (value) {
                case 'edit':
                  onEdit?.call();
                  break;
                case 'delete':
                  onDelete?.call();
                  break;
              }
            },
          ),
      ],
    );
  }

  Widget _buildTitle() {
    return Text(
      task.title,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildProgressBar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '进度',
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[600],
              ),
            ),
            Text(
              '${task.progress}%',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Container(
          height: 4,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(2),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: task.progress / 100,
            child: Container(
              decoration: BoxDecoration(
                color: _getStatusColor(),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: _getPriorityColor().withOpacity(0.2),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            _getPriorityText(),
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: _getPriorityColor(),
            ),
          ),
        ),
        if (task.dependencies.isNotEmpty)
          Icon(
            Icons.link,
            size: 12,
            color: Colors.grey[500],
          ),
      ],
    );
  }

  Color _getBackgroundColor(BuildContext context) {
    if (isSelected) {
      return _getStatusColor().withOpacity(0.1);
    }
    if (isHovered) {
      return Colors.grey[50]!;
    }
    return Colors.white;
  }

  Color _getBorderColor(BuildContext context) {
    if (isSelected) {
      return _getStatusColor();
    }
    if (isHovered) {
      return _getStatusColor().withOpacity(0.5);
    }
    return Colors.grey[300]!;
  }

  Color _getStatusColor() {
    switch (task.status) {
      case EnhancedTaskStatus.pending:
        return Colors.orange;
      case EnhancedTaskStatus.inProgress:
        return Colors.blue;
      case EnhancedTaskStatus.completed:
        return Colors.green;
      case EnhancedTaskStatus.blocked:
        return Colors.red;
    }
  }

  String _getStatusText() {
    switch (task.status) {
      case EnhancedTaskStatus.pending:
        return '待开始';
      case EnhancedTaskStatus.inProgress:
        return '进行中';
      case EnhancedTaskStatus.completed:
        return '已完成';
      case EnhancedTaskStatus.blocked:
        return '受阻';
    }
  }

  Color _getPriorityColor() {
    switch (task.priority) {
      case EnhancedTaskPriority.low:
        return Colors.green;
      case EnhancedTaskPriority.medium:
        return Colors.orange;
      case EnhancedTaskPriority.high:
        return Colors.red;
    }
  }

  String _getPriorityText() {
    switch (task.priority) {
      case EnhancedTaskPriority.low:
        return '低';
      case EnhancedTaskPriority.medium:
        return '中';
      case EnhancedTaskPriority.high:
        return '高';
    }
  }
}
