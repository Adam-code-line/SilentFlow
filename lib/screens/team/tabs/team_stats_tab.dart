import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/app_provider.dart';
import '../../../providers/team_pool_provider.dart';
import '../../../models/task_model.dart' show TaskStatus;
import '../../../widgets/team/stat_card.dart';
import '../../../widgets/team/team_stats_card.dart';

class TeamStatsTab extends StatelessWidget {
  const TeamStatsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TeamPoolProvider>(
      builder: (context, provider, child) {
        final appProvider = Provider.of<AppProvider>(context);
        final userId = appProvider.currentUser?.id ?? '';
        final myTeams = provider.getUserTeamsSync(userId);
        final leadingTeams = provider.getUserLeadingTeamsSync(userId);

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '我的团队统计',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3748),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: StatCard(
                      title: '加入团队',
                      value: myTeams.length.toString(),
                      icon: Icons.groups,
                      color: const Color(0xFF4299E1),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: StatCard(
                      title: '领导团队',
                      value: leadingTeams.length.toString(),
                      icon: Icons.star,
                      color: const Color(0xFFED8936),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: StatCard(
                      title: '总任务数',
                      value: myTeams
                          .fold(0, (sum, team) => sum + team.tasks.length)
                          .toString(),
                      icon: Icons.assignment,
                      color: const Color(0xFF48BB78),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: StatCard(
                      title: '完成任务',
                      value: myTeams
                          .fold(
                              0,
                              (sum, team) =>
                                  sum +
                                  team.tasks
                                      .where((t) =>
                                          t.status == TaskStatus.completed)
                                      .length)
                          .toString(),
                      icon: Icons.check_circle,
                      color: const Color(0xFF9F7AEA),
                    ),
                  ),
                ],
              ),
              if (myTeams.isNotEmpty) ...[
                const SizedBox(height: 30),
                const Text(
                  '团队详情',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3748),
                  ),
                ),
                const SizedBox(height: 16),
                ...myTeams
                    .map((team) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: TeamStatsCard(team: team, userId: userId),
                        ))
                    .toList(),
              ],
            ],
          ),
        );
      },
    );
  }
}
