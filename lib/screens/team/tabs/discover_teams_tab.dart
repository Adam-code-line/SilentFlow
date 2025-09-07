import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/team_pool_provider.dart';
import '../../../models/team_pool_model.dart';
import '../../../widgets/team/public_team_card.dart';

class DiscoverTeamsTab extends StatefulWidget {
  final Function(TeamPool) onJoinTeam;
  final List<TeamPool> filteredTeams;
  final TextEditingController searchController;
  final Function(String) onSearchChanged;

  const DiscoverTeamsTab({
    super.key,
    required this.onJoinTeam,
    required this.filteredTeams,
    required this.searchController,
    required this.onSearchChanged,
  });

  @override
  State<DiscoverTeamsTab> createState() => _DiscoverTeamsTabState();
}

class _DiscoverTeamsTabState extends State<DiscoverTeamsTab> {
  @override
  Widget build(BuildContext context) {
    return Consumer<TeamPoolProvider>(
      builder: (context, provider, child) {
        final publicTeams = provider.allPublicTeams;

        return Column(
          children: [
            // 搜索栏
            Padding(
              padding: const EdgeInsets.all(20),
              child: TextField(
                controller: widget.searchController,
                onChanged: widget.onSearchChanged,
                decoration: InputDecoration(
                  hintText: '搜索团队...',
                  prefixIcon:
                      const Icon(Icons.search, color: Color(0xFF667eea)),
                  filled: true,
                  fillColor: Colors.grey[50],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ),
            // 团队列表
            Expanded(
              child: widget.filteredTeams.isNotEmpty ||
                      widget.searchController.text.isNotEmpty
                  ? ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: widget.filteredTeams.length,
                      itemBuilder: (context, index) {
                        final team = widget.filteredTeams[index];
                        return PublicTeamCard(
                          team: team,
                          onJoin: () => widget.onJoinTeam(team),
                        );
                      },
                    )
                  : publicTeams.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.search_off,
                                size: 80,
                                color: Colors.grey[300],
                              ),
                              const SizedBox(height: 20),
                              Text(
                                '暂无公开团队',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey[500],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: publicTeams.length,
                          itemBuilder: (context, index) {
                            final team = publicTeams[index];
                            return PublicTeamCard(
                              team: team,
                              onJoin: () => widget.onJoinTeam(team),
                            );
                          },
                        ),
            ),
          ],
        );
      },
    );
  }
}
