import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/team_pool_model.dart';
import '../../providers/app_provider.dart';
import '../../providers/team_pool_provider.dart';
import '../../widgets/team_creation_dialog.dart';
import 'team_detail_screen.dart';

// 导入组件模块
import 'widgets/action_button.dart';
import 'widgets/current_team_card.dart';
import 'widgets/no_team_card.dart';
import 'tabs/my_teams_tab.dart';
import 'tabs/discover_teams_tab.dart';
import 'tabs/team_stats_tab.dart';
import 'utils/team_action_handler.dart';

class TeamPoolScreen extends StatefulWidget {
  const TeamPoolScreen({super.key});

  @override
  State<TeamPoolScreen> createState() => _TeamPoolScreenState();
}

class _TeamPoolScreenState extends State<TeamPoolScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  List<TeamPool> _filteredTeams = [];

  // 软阴影样式
  static const BoxShadow _cardShadow = BoxShadow(
    color: Color.fromARGB(25, 0, 0, 0),
    offset: Offset(0, 2),
    blurRadius: 12,
    spreadRadius: 0,
  );

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
  }

  Future<void> _initializeData() async {
    final teamPoolProvider =
        Provider.of<TeamPoolProvider>(context, listen: false);
    if (!teamPoolProvider.isLoading) {
      await teamPoolProvider.initialize();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _filterTeams(String query) {
    final teamPoolProvider =
        Provider.of<TeamPoolProvider>(context, listen: false);
    _filteredTeams = teamPoolProvider.searchTeamsSync(query);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF667eea),
              Color(0xFF764ba2),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // 顶部标题和操作区域
              Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          '团队池',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Row(
                          children: [
                            ActionButton(
                              icon: Icons.add,
                              label: '创建',
                              onPressed: _showCreateTeamOptions,
                            ),
                            const SizedBox(width: 12),
                            ActionButton(
                              icon: Icons.group_add,
                              label: '加入',
                              onPressed: () => _navigateToJoinTeam(),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Consumer<TeamPoolProvider>(
                      builder: (context, provider, child) {
                        if (provider.currentTeam != null) {
                          return CurrentTeamCard(team: provider.currentTeam!);
                        }
                        return const NoTeamCard();
                      },
                    ),
                  ],
                ),
              ),
              // 标签页
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white70,
                  labelStyle: const TextStyle(fontWeight: FontWeight.w600),
                  tabs: const [
                    Tab(text: '我的团队'),
                    Tab(text: '发现团队'),
                    Tab(text: '团队统计'),
                  ],
                ),
              ),
              // 标签页内容
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(
                      top: 20, left: 20, right: 20, bottom: 20),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                    boxShadow: [_cardShadow],
                  ),
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      MyTeamsTab(
                        onTeamTap: _navigateToTeamDetail,
                        onTeamLongPress: _showTeamActions,
                        onCreateTeam: _showCreateTeamOptions,
                      ),
                      DiscoverTeamsTab(
                        onJoinTeam: _joinTeam,
                        filteredTeams: _filteredTeams,
                        searchController: _searchController,
                        onSearchChanged: _filterTeams,
                      ),
                      const TeamStatsTab(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCreateTeamOptions() {
    TeamActionHandler.showCreateTeamOptions(
      context,
      () => _navigateToCreateTeam(),
      () => _navigateToCreateTeam(useTemplate: true),
    );
  }

  void _navigateToCreateTeam({bool useTemplate = false}) {
    // 显示团队创建对话框
    showDialog(
      context: context,
      builder: (context) => TeamCreationDialog(
        isCustomCreation: !useTemplate,
      ),
    );
  }

  void _navigateToJoinTeam() {
    // TODO: 实现加入团队界面
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('加入团队功能即将上线')),
    );
  }

  void _navigateToTeamDetail(TeamPool team) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => TeamDetailScreen(team: team),
      ),
    );
  }

  void _joinTeam(TeamPool team) async {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    final teamPoolProvider =
        Provider.of<TeamPoolProvider>(context, listen: false);
    final userId = appProvider.currentUser?.id ?? '';

    if (userId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请先登录')),
      );
      return;
    }

    final success = await teamPoolProvider.joinTeam(team.id, userId);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('成功加入团队 "${team.name}"'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(teamPoolProvider.error ?? '加入团队失败'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showTeamActions(TeamPool team) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '管理团队 "${team.name}"',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('编辑团队'),
              onTap: () {
                Navigator.pop(context);
                _handleTeamAction(team, 'edit');
              },
            ),
            ListTile(
              leading: const Icon(Icons.people),
              title: const Text('管理成员'),
              onTap: () {
                Navigator.pop(context);
                _handleTeamAction(team, 'members');
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('删除团队', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _handleTeamAction(team, 'delete');
              },
            ),
          ],
        ),
      ),
    );
  }

  void _handleTeamAction(TeamPool team, String action) {
    switch (action) {
      case 'edit':
        _editTeam(team);
        break;
      case 'members':
        _manageMembers(team);
        break;
      case 'delete':
        _deleteTeam(team);
        break;
    }
  }

  void _editTeam(TeamPool team) {
    showDialog(
      context: context,
      builder: (context) => TeamCreationDialog(
        isCustomCreation: true,
        initialTemplate: {
          'name': team.name,
          'description': team.description,
          'teamId': team.id,
          'isEdit': true,
        },
      ),
    );
  }

  void _manageMembers(TeamPool team) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('成员管理功能即将上线')),
    );
  }

  void _deleteTeam(TeamPool team) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除团队'),
        content: Text('确定要删除团队 "${team.name}" 吗？\n\n此操作无法撤销，团队中的所有数据都将被删除。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _confirmDeleteTeam(team);
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDeleteTeam(TeamPool team) async {
    final teamPoolProvider =
        Provider.of<TeamPoolProvider>(context, listen: false);

    final success = await teamPoolProvider.deleteTeam(team.id);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('团队 "${team.name}" 已删除'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(teamPoolProvider.error ?? '删除团队失败'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
