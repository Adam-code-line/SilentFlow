import 'package:flutter/material.dart';
import '../../../models/user_model.dart';
import '../../../models/team_pool_model.dart';

class TeamMembersList extends StatelessWidget {
  final List<User> teamMembers;
  final TeamPool team;
  final Function(User, String) onMemberAction;

  const TeamMembersList({
    super.key,
    required this.teamMembers,
    required this.team,
    required this.onMemberAction,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: teamMembers.length,
      itemBuilder: (context, index) {
        final member = teamMembers[index];
        final role = team.memberRoles[member.id] ?? MemberRole.member;

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).primaryColor,
              child: Text(
                member.name.isNotEmpty ? member.name[0].toUpperCase() : 'U',
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            title: Text(
              member.name,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(role.displayName),
                if (member.profile.skills.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 4,
                    children: member.profile.skills
                        .take(3)
                        .map(
                          (skill) => Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              skill.name,
                              style: const TextStyle(
                                  fontSize: 10, color: Colors.blue),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ],
            ),
            trailing: _buildMemberActions(member, role),
          ),
        );
      },
    );
  }

  Widget _buildMemberActions(User member, MemberRole role) {
    // 这里可以根据当前用户权限显示不同的操作
    return PopupMenuButton<String>(
      onSelected: (value) => onMemberAction(member, value),
      itemBuilder: (context) => [
        if (role != MemberRole.coLeader)
          const PopupMenuItem(value: 'promote', child: Text('提升为副队长')),
        if (role == MemberRole.coLeader)
          const PopupMenuItem(value: 'demote', child: Text('取消副队长')),
        const PopupMenuItem(value: 'remove', child: Text('移除成员')),
      ],
    );
  }
}
