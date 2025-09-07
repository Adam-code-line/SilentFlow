import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/app_provider.dart';
import '../../../providers/team_pool_provider.dart';
import '../../../models/team_pool_model.dart';
import '../../../widgets/team/team_card.dart';

class MyTeamsTab extends StatelessWidget {
  final Function(TeamPool) onTeamTap;
  final Function(TeamPool) onTeamLongPress;
  final VoidCallback onCreateTeam;

  const MyTeamsTab({
    super.key,
    required this.onTeamTap,
    required this.onTeamLongPress,
    required this.onCreateTeam,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<TeamPoolProvider>(
      builder: (context, provider, child) {
        final appProvider = Provider.of<AppProvider>(context);
        final userId = appProvider.currentUser?.id ?? '';
        final myTeams = provider.getUserTeamsSync(userId);

        if (provider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF667eea)),
            ),
          );
        }

        if (myTeams.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.group_off_outlined,
                  size: 80,
                  color: Colors.grey[300],
                ),
                const SizedBox(height: 20),
                Text(
                  '还没有加入任何团队',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[500],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 30),
                ElevatedButton.icon(
                  onPressed: onCreateTeam,
                  icon: const Icon(Icons.add),
                  label: const Text('创建团队'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF667eea),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: myTeams.length,
          itemBuilder: (context, index) {
            final team = myTeams[index];
            return TeamCard(
              team: team,
              userId: userId,
              onTap: () => onTeamTap(team),
              onLongPress:
                  team.isLeader(userId) ? () => onTeamLongPress(team) : null,
            );
          },
        );
      },
    );
  }
}
