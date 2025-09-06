import 'package:flutter/material.dart';
import '../../../providers/enhanced_workflow_provider.dart';

/// 添加任务对话框
class AddTaskDialog extends StatefulWidget {
  final Function(EnhancedTaskNode) onTaskAdded;

  const AddTaskDialog({super.key, required this.onTaskAdded});

  @override
  State<AddTaskDialog> createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends State<AddTaskDialog> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  EnhancedTaskPriority _priority = EnhancedTaskPriority.medium;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('添加新任务'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: '任务标题',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: '任务描述',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<EnhancedTaskPriority>(
              value: _priority,
              decoration: const InputDecoration(
                labelText: '优先级',
                border: OutlineInputBorder(),
              ),
              items: EnhancedTaskPriority.values.map((priority) {
                return DropdownMenuItem(
                  value: priority,
                  child: Text(_getPriorityText(priority)),
                );
              }).toList(),
              onChanged: (value) => setState(() => _priority = value!),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
        ElevatedButton(
          onPressed: _createTask,
          child: const Text('创建'),
        ),
      ],
    );
  }

  void _createTask() {
    if (_titleController.text.trim().isEmpty) return;

    final task = EnhancedTaskNode(
      id: 'task_${DateTime.now().millisecondsSinceEpoch}',
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      status: EnhancedTaskStatus.pending,
      priority: _priority,
      progress: 0,
      dependencies: [],
    );

    widget.onTaskAdded(task);
    Navigator.of(context).pop();
  }

  String _getPriorityText(EnhancedTaskPriority priority) {
    switch (priority) {
      case EnhancedTaskPriority.low:
        return '低优先级';
      case EnhancedTaskPriority.medium:
        return '中优先级';
      case EnhancedTaskPriority.high:
        return '高优先级';
    }
  }
}

/// 编辑任务对话框
class EditTaskDialog extends StatefulWidget {
  final EnhancedTaskNode task;
  final Function(EnhancedTaskNode) onTaskUpdated;

  const EditTaskDialog({
    super.key,
    required this.task,
    required this.onTaskUpdated,
  });

  @override
  State<EditTaskDialog> createState() => _EditTaskDialogState();
}

class _EditTaskDialogState extends State<EditTaskDialog> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late EnhancedTaskPriority _priority;
  late EnhancedTaskStatus _status;
  late double _progress;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task.title);
    _descriptionController =
        TextEditingController(text: widget.task.description);
    _priority = widget.task.priority;
    _status = widget.task.status;
    _progress = widget.task.progress.toDouble();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('编辑任务'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: '任务标题',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: '任务描述',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<EnhancedTaskStatus>(
              value: _status,
              decoration: const InputDecoration(
                labelText: '状态',
                border: OutlineInputBorder(),
              ),
              items: EnhancedTaskStatus.values.map((status) {
                return DropdownMenuItem(
                  value: status,
                  child: Text(_getStatusText(status)),
                );
              }).toList(),
              onChanged: (value) => setState(() => _status = value!),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<EnhancedTaskPriority>(
              value: _priority,
              decoration: const InputDecoration(
                labelText: '优先级',
                border: OutlineInputBorder(),
              ),
              items: EnhancedTaskPriority.values.map((priority) {
                return DropdownMenuItem(
                  value: priority,
                  child: Text(_getPriorityText(priority)),
                );
              }).toList(),
              onChanged: (value) => setState(() => _priority = value!),
            ),
            const SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('进度: ${_progress.round()}%'),
                Slider(
                  value: _progress,
                  min: 0,
                  max: 100,
                  divisions: 20,
                  onChanged: (value) => setState(() => _progress = value),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
        ElevatedButton(
          onPressed: _updateTask,
          child: const Text('保存'),
        ),
      ],
    );
  }

  void _updateTask() {
    if (_titleController.text.trim().isEmpty) return;

    final updatedTask = EnhancedTaskNode(
      id: widget.task.id,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      status: _status,
      priority: _priority,
      progress: _progress.round(),
      dependencies: widget.task.dependencies,
    );

    widget.onTaskUpdated(updatedTask);
    Navigator.of(context).pop();
  }

  String _getStatusText(EnhancedTaskStatus status) {
    switch (status) {
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

  String _getPriorityText(EnhancedTaskPriority priority) {
    switch (priority) {
      case EnhancedTaskPriority.low:
        return '低优先级';
      case EnhancedTaskPriority.medium:
        return '中优先级';
      case EnhancedTaskPriority.high:
        return '高优先级';
    }
  }
}
