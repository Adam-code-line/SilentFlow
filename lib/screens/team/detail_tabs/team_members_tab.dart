import 'package:flutter/material.dart';
import '../../../models/user_model.dart';
import '../../../models/team_pool_model.dart';
import '../../../widgets/team/team_members_list.dart';

class TeamMembersTab extends StatelessWidget {
  final List<User> teamMembers;
  final TeamPool team;
  final Function(User, String) onMemberAction;

  const TeamMembersTab({
    super.key,
    required this.teamMembers,
    required this.team,
    required this.onMemberAction,
  });

  @override
  Widget build(BuildContext context) {
    return TeamMembersList(
      teamMembers: teamMembers,
      team: team,
      onMemberAction: onMemberAction,
    );
  }
}
