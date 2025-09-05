import 'package:flutter/material.dart';
import '../../../models/team_pool_model.dart';

class TeamOverviewCard extends StatelessWidget {
  final TeamPool team;

  const TeamOverviewCard({
    super.key,
    required this.team,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '团队统计',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    Icons.people,
                    '成员数',
                    '${team.memberIds.length}/${team.maxMembers}',
                    Colors.blue,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    Icons.task_alt,
                    '任务',
                    team.statistics.totalTasksCompleted.toString(),
                    Colors.green,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    Icons.check_circle,
                    '完成率',
                    '${(team.statistics.onTimeCompletionRate * 100).toInt()}%',
                    Colors.purple,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    Icons.trending_up,
                    '效率',
                    '${(team.statistics.teamEfficiency * 100).toInt()}%',
                    Colors.orange,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
      IconData icon, String label, String value, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}
