import 'package:flutter/material.dart';
import '../../../models/team_pool_model.dart';
import '../../../models/task_model.dart';
import '../detail_widgets/team_overview_card.dart';
import '../detail_widgets/project_overview_card.dart';

class TeamOverviewTab extends StatelessWidget {
  final TeamPool team;
  final Task? teamProject;

  const TeamOverviewTab({
    super.key,
    required this.team,
    required this.teamProject,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 团队统计卡片
          TeamOverviewCard(team: team),
          const SizedBox(height: 16),

          // 项目概览卡片
          if (teamProject != null)
            ProjectOverviewCard(teamProject: teamProject),
          if (teamProject != null) const SizedBox(height: 16),

          // 团队描述
          _buildDescriptionCard(),
          const SizedBox(height: 16),

          // 团队标签
          if (team.tags.isNotEmpty) _buildTagsCard(),
          if (team.tags.isNotEmpty) const SizedBox(height: 16),

          // 最近动态
          _buildRecentActivitiesCard(),
        ],
      ),
    );
  }

  Widget _buildDescriptionCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '团队描述',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              team.description.isNotEmpty ? team.description : '暂无描述',
              style: TextStyle(
                color: team.description.isNotEmpty
                    ? Colors.black87
                    : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTagsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '团队标签',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: team.tags
                  .map((tag) => Chip(
                        label: Text(tag),
                        backgroundColor: Colors.blue.withOpacity(0.1),
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivitiesCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '最近动态',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Center(
              child: Text(
                '暂无最近动态',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
