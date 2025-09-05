import 'package:flutter/material.dart';
import '../../../models/team_pool_model.dart';

class TeamStatsCard extends StatelessWidget {
  final TeamPool team;
  final String userId;

  const TeamStatsCard({
    super.key,
    required this.team,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    final progress = team.progress;
    final isLeader = team.isLeader(userId);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  team.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3748),
                  ),
                ),
              ),
              if (isLeader)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.orange[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '队长',
                    style: TextStyle(
                      color: Colors.orange[700],
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMiniStatItem(
                  '总任务', progress.totalTasks.toString(), Colors.blue),
              _buildMiniStatItem(
                  '已完成', progress.completedTasks.toString(), Colors.green),
              _buildMiniStatItem(
                  '进行中', progress.inProgressTasks.toString(), Colors.orange),
              _buildMiniStatItem(
                  '待开始', progress.pendingTasks.toString(), Colors.grey),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}
