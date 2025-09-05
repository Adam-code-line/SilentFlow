import 'package:flutter/material.dart';
import '../../../models/team_pool_model.dart';
import '../../../models/task_model.dart';
import '../../../models/user_model.dart';

class TeamTasksTab extends StatelessWidget {
  final TeamPool team;
  final List<Task> tasks;
  final List<User> teamMembers;
  final Function(Task) onTaskTap;
  final VoidCallback onAddTask;

  const TeamTasksTab({
    super.key,
    required this.team,
    required this.tasks,
    required this.teamMembers,
    required this.onTaskTap,
    required this.onAddTask,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 任务统计
          _buildTaskStats(),
          const SizedBox(height: 20),

          // 添加任务按钮
          _buildAddTaskButton(context),
          const SizedBox(height: 20),

          // 任务列表
          _buildTaskList(),
        ],
      ),
    );
  }

  Widget _buildTaskStats() {
    final completedTasks =
        tasks.where((task) => task.status == TaskStatus.completed).length;
    final pendingTasks = tasks.length - completedTasks;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  Text(
                    '$completedTasks',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  const Text('已完成'),
                ],
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  Text(
                    '$pendingTasks',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                  const Text('进行中'),
                ],
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  Text(
                    '${tasks.length}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text('总任务'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddTaskButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onAddTask,
        icon: const Icon(Icons.add),
        label: const Text('添加新任务'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.all(16.0),
        ),
      ),
    );
  }

  Widget _buildTaskList() {
    if (tasks.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Center(
            child: Column(
              children: [
                Icon(
                  Icons.assignment_outlined,
                  size: 64,
                  color: Colors.grey,
                ),
                SizedBox(height: 16),
                Text(
                  '暂无任务',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  '点击上方按钮添加新任务',
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Column(
      children: [
        for (int i = 0; i < tasks.length; i++) ...[
          _buildTaskCard(tasks[i]),
          if (i < tasks.length - 1) const SizedBox(height: 12),
        ],
      ],
    );
  }

  Widget _buildTaskCard(Task task) {
    final assignee = teamMembers.firstWhere(
      (member) => member.id == task.assigneeId,
      orElse: () => User(
        id: '',
        name: '未分配',
        createdAt: DateTime.now(),
        profile: UserProfile(
          workStyle: WorkStyle(
            communicationStyle: '平衡',
            workPace: '稳定',
            preferredCollaborationMode: '混合',
            stressHandling: '正常',
            feedbackStyle: '建设性',
          ),
          availability: AvailabilityInfo(),
          contact: ContactInfo(),
        ),
        stats: const UserStats(),
      ),
    );

    final isCompleted = task.status == TaskStatus.completed;

    return Card(
      child: InkWell(
        onTap: () => onTaskTap(task),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    isCompleted
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked,
                    color: isCompleted ? Colors.green : Colors.grey,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      task.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        decoration:
                            isCompleted ? TextDecoration.lineThrough : null,
                      ),
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getPriorityColor(task.priority),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getPriorityText(task.priority),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              if (task.description?.isNotEmpty == true) ...[
                const SizedBox(height: 8),
                Text(
                  task.description!,
                  style: TextStyle(
                    color: Colors.grey[600],
                    decoration: isCompleted ? TextDecoration.lineThrough : null,
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.person,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    assignee.name,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    task.dueDate != null
                        ? '${task.dueDate!.month}/${task.dueDate!.day}'
                        : '无截止日期',
                    style: TextStyle(
                      color: task.dueDate?.isBefore(DateTime.now()) == true &&
                              !isCompleted
                          ? Colors.red
                          : Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.urgent:
        return Colors.red;
      case TaskPriority.high:
        return Colors.orange;
      case TaskPriority.medium:
        return Colors.blue;
      case TaskPriority.low:
        return Colors.green;
    }
  }

  String _getPriorityText(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.urgent:
        return '紧急';
      case TaskPriority.high:
        return '高';
      case TaskPriority.medium:
        return '中';
      case TaskPriority.low:
        return '低';
    }
  }
}
