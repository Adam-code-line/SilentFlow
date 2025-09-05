import 'package:flutter/material.dart';
import '../../../models/task_model.dart';
import '../../../models/team_pool_model.dart';

class TeamProjectTab extends StatelessWidget {
  final TeamPool team;
  final Task? teamProject;
  final VoidCallback onCreateProject;
  final Function(Task) onCreateSubTask;

  const TeamProjectTab({
    super.key,
    required this.team,
    required this.teamProject,
    required this.onCreateProject,
    required this.onCreateSubTask,
  });

  @override
  Widget build(BuildContext context) {
    if (teamProject == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.folder_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              '暂无项目',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onCreateProject,
              icon: const Icon(Icons.add),
              label: const Text('创建团队项目'),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 项目基本信息
          _buildProjectInfoCard(),
          const SizedBox(height: 16),

          // 项目进度
          _buildProjectProgressCard(),
          const SizedBox(height: 16),

          // 项目成员分工
          _buildProjectAssignmentsCard(),
          const SizedBox(height: 16),

          // 项目里程碑
          _buildProjectMilestonesCard(),
        ],
      ),
    );
  }

  Widget _buildProjectInfoCard() {
    if (teamProject == null) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '项目信息',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildInfoRow('项目名称', teamProject!.title),
            if (teamProject!.description != null)
              _buildInfoRow('项目描述', teamProject!.description!),
            _buildInfoRow('预估时间', '${teamProject!.estimatedMinutes}分钟'),
            _buildInfoRow('优先级', teamProject!.priority.displayName),
            _buildInfoRow('状态', teamProject!.status.displayName),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectProgressCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '项目进度',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Center(
              child: Text(
                '进度统计功能开发中',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectAssignmentsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '成员分工',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Center(
              child: Text(
                '成员分工功能开发中',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectMilestonesCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '项目里程碑',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Center(
              child: Text(
                '里程碑功能开发中',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const Text(': '),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}
