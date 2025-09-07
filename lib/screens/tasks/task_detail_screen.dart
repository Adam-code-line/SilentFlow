import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/task_model.dart';
import '../../services/task_service.dart';
import '../../providers/team_pool_provider.dart';
import '../../widgets/dialogs/task_creation_dialog.dart';
import '../../widgets/task/task_info_card.dart';
import '../../widgets/task/task_completion_stats.dart';
import '../../widgets/task/child_tasks_list.dart';

class TaskDetailScreen extends StatefulWidget {
  final Task task;

  const TaskDetailScreen({
    super.key,
    required this.task,
  });

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  List<Task> _childTasks = [];
  Map<String, int> _completionStats = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTaskDetails();
  }

  Future<void> _loadTaskDetails() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final childTasks = await TaskService.getChildTasks(widget.task.id);
      final stats = await TaskService.getTaskCompletionStats(widget.task.id);

      setState(() {
        _childTasks = childTasks;
        _completionStats = stats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('加载任务详情失败: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.task.title),
        backgroundColor: const Color(0xFF667eea),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _editTask,
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF667eea),
              Color(0xFF764ba2),
            ],
          ),
        ),
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Colors.white))
            : Column(
                children: [
                  // 任务基本信息卡片
                  Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TaskInfoCard(
                      task: widget.task,
                      onMenuAction: _handleMenuAction,
                    ),
                  ),

                  // 完成统计卡片
                  if (_completionStats.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TaskCompletionStats(stats: _completionStats),
                    ),

                  // 子任务列表
                  const SizedBox(height: 16),
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ChildTasksList(
                        childTasks: _childTasks,
                        isLoading: _isLoading,
                        onTaskTap: _openChildTaskDetail,
                      ),
                    ),
                  ),
                ],
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addChildTask,
        backgroundColor: const Color(0xFF667eea),
        child: const Icon(Icons.add),
      ),
    );
  }

  // 事件处理方法
  void _editTask() {
    // TODO: 实现任务编辑功能
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('任务编辑功能开发中')),
    );
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'status':
        _showStatusChangeDialog();
        break;
      case 'delete':
        _showDeleteConfirmDialog();
        break;
    }
  }

  void _showStatusChangeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('更改任务状态'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: TaskStatus.values.map((status) {
            return ListTile(
              leading: Icon(
                _getStatusIcon(status),
                color: _getStatusColor(status),
              ),
              title: Text(_getStatusText(status)),
              onTap: () async {
                Navigator.pop(context);
                await _updateTaskStatus(status);
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除任务'),
        content: Text('确定要删除任务 "${widget.task.title}" 吗？此操作无法撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteTask();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }

  Future<void> _updateTaskStatus(TaskStatus newStatus) async {
    try {
      final result = await TaskService.updateTaskStatus(
        teamId: widget.task.poolId,
        taskId: widget.task.id,
        status: newStatus,
      );

      if (result != null) {
        setState(() {
          // 更新本地任务状态
        });
        _loadTaskDetails(); // 重新加载数据
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('任务状态已更新')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('更新失败: $e')),
      );
    }
  }

  Future<void> _deleteTask() async {
    try {
      final success = await TaskService.deleteTask(widget.task.id);
      if (success) {
        Navigator.pop(context, true); // 返回true表示任务已删除
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('任务已删除')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('删除失败: $e')),
      );
    }
  }

  Future<void> _addChildTask() async {
    final teamPoolProvider = context.read<TeamPoolProvider>();
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => TaskCreationDialog(
        team: teamPoolProvider.currentTeam,
        parentTask: widget.task,
      ),
    );

    if (result == true) {
      _loadTaskDetails(); // 重新加载任务详情
    }
  }

  void _openChildTaskDetail(Task childTask) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TaskDetailScreen(task: childTask),
      ),
    ).then((result) {
      if (result == true) {
        _loadTaskDetails(); // 如果子任务被修改或删除，重新加载
      }
    });
  }

  // 辅助方法
  String _getStatusText(TaskStatus status) {
    switch (status) {
      case TaskStatus.pending:
        return '待处理';
      case TaskStatus.inProgress:
        return '进行中';
      case TaskStatus.completed:
        return '已完成';
      case TaskStatus.blocked:
        return '受阻';
    }
  }

  IconData _getStatusIcon(TaskStatus status) {
    switch (status) {
      case TaskStatus.pending:
        return Icons.schedule;
      case TaskStatus.inProgress:
        return Icons.play_circle;
      case TaskStatus.completed:
        return Icons.check_circle;
      case TaskStatus.blocked:
        return Icons.block;
    }
  }

  Color _getStatusColor(TaskStatus status) {
    switch (status) {
      case TaskStatus.pending:
        return const Color(0xFFED8936);
      case TaskStatus.inProgress:
        return const Color(0xFF4299E1);
      case TaskStatus.completed:
        return const Color(0xFF48BB78);
      case TaskStatus.blocked:
        return const Color(0xFFE53E3E);
    }
  }
}
