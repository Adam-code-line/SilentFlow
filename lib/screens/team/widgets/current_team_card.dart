import 'package:flutter/material.dart';
import '../../../models/team_pool_model.dart';

class CurrentTeamCard extends StatelessWidget {
  final TeamPool team;

  const CurrentTeamCard({
    super.key,
    required this.team,
  });

  static const BoxShadow _cardShadow = BoxShadow(
    color: Color.fromARGB(25, 0, 0, 0),
    offset: Offset(0, 2),
    blurRadius: 12,
    spreadRadius: 0,
  );

  @override
  Widget build(BuildContext context) {
    final progress = team.progress;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [_cardShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      team.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D3748),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${team.allMemberIds.length}/${team.maxMembers} 成员',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  team.teamType.displayName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildProgressItem(
                  '总任务',
                  progress.totalTasks.toString(),
                  Icons.assignment,
                  const Color(0xFF4299E1),
                ),
              ),
              Expanded(
                child: _buildProgressItem(
                  '已完成',
                  progress.completedTasks.toString(),
                  Icons.check_circle,
                  const Color(0xFF48BB78),
                ),
              ),
              Expanded(
                child: _buildProgressItem(
                  '进行中',
                  progress.inProgressTasks.toString(),
                  Icons.hourglass_empty,
                  const Color(0xFFED8936),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '团队进度',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                '${(progress.overallProgress * 100).toInt()}%',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF667eea),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress.overallProgress,
              backgroundColor: Colors.grey[200],
              valueColor:
                  const AlwaysStoppedAnimation<Color>(Color(0xFF667eea)),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressItem(
      String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
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
