import 'package:flutter/material.dart';
import '../../../providers/enhanced_workflow_provider.dart';

/// 任务创建/编辑对话框
class TaskEditDialog extends StatefulWidget {
  final EnhancedTaskNode? task; // null表示创建新任务
  final List<EnhancedTaskNode> availableTasks; // 可选择的依赖任务

  const TaskEditDialog({
    super.key,
    this.task,
    this.availableTasks = const [],
  });

  @override
  State<TaskEditDialog> createState() => _TaskEditDialogState();
}

class _TaskEditDialogState extends State<TaskEditDialog> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late EnhancedTaskStatus _selectedStatus;
  late EnhancedTaskPriority _selectedPriority;
  late int _progress;
  final Set<String> _selectedDependencies = {};

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task?.title ?? '');
    _descriptionController =
        TextEditingController(text: widget.task?.description ?? '');
    _selectedStatus = widget.task?.status ?? EnhancedTaskStatus.pending;
    _selectedPriority = widget.task?.priority ?? EnhancedTaskPriority.medium;
    _progress = widget.task?.progress ?? 0;
    _selectedDependencies.addAll(widget.task?.dependencies ?? []);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.task == null ? '创建任务' : '编辑任务'),
      content: SizedBox(
        width: 400,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField(
                controller: _titleController,
                label: '任务标题',
                hint: '请输入任务标题',
                required: true,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _descriptionController,
                label: '任务描述',
                hint: '请输入任务描述',
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              _buildStatusDropdown(),
              const SizedBox(height: 16),
              _buildPriorityDropdown(),
              const SizedBox(height: 16),
              _buildProgressSlider(),
              const SizedBox(height: 16),
              _buildDependenciesSection(),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
        ElevatedButton(
          onPressed: _saveTask,
          child: Text(widget.task == null ? '创建' : '保存'),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    bool required = false,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label + (required ? ' *' : ''),
        hintText: hint,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }

  Widget _buildStatusDropdown() {
    return DropdownButtonFormField<EnhancedTaskStatus>(
      value: _selectedStatus,
      decoration: const InputDecoration(
        labelText: '任务状态',
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      items: EnhancedTaskStatus.values.map((status) {
        return DropdownMenuItem(
          value: status,
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: _getStatusColor(status),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(_getStatusText(status)),
            ],
          ),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() {
            _selectedStatus = value;
            if (value == EnhancedTaskStatus.completed) {
              _progress = 100;
            } else if (value == EnhancedTaskStatus.pending &&
                _progress == 100) {
              _progress = 0;
            }
          });
        }
      },
    );
  }

  Widget _buildPriorityDropdown() {
    return DropdownButtonFormField<EnhancedTaskPriority>(
      value: _selectedPriority,
      decoration: const InputDecoration(
        labelText: '优先级',
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      items: EnhancedTaskPriority.values.map((priority) {
        return DropdownMenuItem(
          value: priority,
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: _getPriorityColor(priority),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(_getPriorityText(priority)),
            ],
          ),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() {
            _selectedPriority = value;
          });
        }
      },
    );
  }

  Widget _buildProgressSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '进度: $_progress%',
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        Slider(
          value: _progress.toDouble(),
          min: 0,
          max: 100,
          divisions: 20,
          onChanged: (value) {
            setState(() {
              _progress = value.toInt();
              // 根据进度自动调整状态
              if (_progress == 0) {
                _selectedStatus = EnhancedTaskStatus.pending;
              } else if (_progress == 100) {
                _selectedStatus = EnhancedTaskStatus.completed;
              } else if (_selectedStatus == EnhancedTaskStatus.pending ||
                  _selectedStatus == EnhancedTaskStatus.completed) {
                _selectedStatus = EnhancedTaskStatus.inProgress;
              }
            });
          },
        ),
      ],
    );
  }

  Widget _buildDependenciesSection() {
    final availableTasks = widget.availableTasks
        .where((task) => task.id != widget.task?.id)
        .toList();

    if (availableTasks.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '任务依赖',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Container(
          height: 120,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ListView.builder(
            itemCount: availableTasks.length,
            itemBuilder: (context, index) {
              final task = availableTasks[index];
              final isSelected = _selectedDependencies.contains(task.id);

              return CheckboxListTile(
                dense: true,
                title: Text(
                  task.title,
                  style: const TextStyle(fontSize: 13),
                ),
                subtitle: Text(
                  _getStatusText(task.status),
                  style: TextStyle(
                    fontSize: 11,
                    color: _getStatusColor(task.status),
                  ),
                ),
                value: isSelected,
                onChanged: (selected) {
                  setState(() {
                    if (selected == true) {
                      _selectedDependencies.add(task.id);
                    } else {
                      _selectedDependencies.remove(task.id);
                    }
                  });
                },
              );
            },
          ),
        ),
      ],
    );
  }

  void _saveTask() {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入任务标题')),
      );
      return;
    }

    final result = EnhancedTaskNode(
      id: widget.task?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      status: _selectedStatus,
      priority: _selectedPriority,
      progress: _progress,
      dependencies: _selectedDependencies.toList(),
    );

    Navigator.of(context).pop(result);
  }

  Color _getStatusColor(EnhancedTaskStatus status) {
    switch (status) {
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

  Color _getPriorityColor(EnhancedTaskPriority priority) {
    switch (priority) {
      case EnhancedTaskPriority.low:
        return Colors.green;
      case EnhancedTaskPriority.medium:
        return Colors.orange;
      case EnhancedTaskPriority.high:
        return Colors.red;
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

/// 任务详情对话框
class TaskDetailDialog extends StatelessWidget {
  final EnhancedTaskNode task;
  final List<EnhancedTaskNode> allTasks;

  const TaskDetailDialog({
    super.key,
    required this.task,
    this.allTasks = const [],
  });

  @override
  Widget build(BuildContext context) {
    final dependentTasks =
        allTasks.where((t) => task.dependencies.contains(t.id)).toList();

    return AlertDialog(
      title: Text(task.title),
      content: SizedBox(
        width: 350,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (task.description.isNotEmpty) ...[
              const Text('描述:', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text(task.description),
              const SizedBox(height: 16),
            ],
            Row(
              children: [
                const Text('状态: ',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getStatusColor().withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _getStatusText(),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _getStatusColor(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text('优先级: ',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getPriorityColor().withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _getPriorityText(),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _getPriorityColor(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text('进度:', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            LinearProgressIndicator(
              value: task.progress / 100,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(_getStatusColor()),
            ),
            const SizedBox(height: 4),
            Text('${task.progress}%', style: const TextStyle(fontSize: 12)),
            if (dependentTasks.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text('依赖任务:',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              ...dependentTasks.map((depTask) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        Icon(
                          Icons.arrow_right,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            depTask.title,
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  )),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('关闭'),
        ),
      ],
    );
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
        return '低优先级';
      case EnhancedTaskPriority.medium:
        return '中优先级';
      case EnhancedTaskPriority.high:
        return '高优先级';
    }
  }
}
