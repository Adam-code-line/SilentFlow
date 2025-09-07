import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/team_pool_model.dart';
import '../../models/task_model.dart';
import '../../models/user_model.dart';
import '../../providers/app_provider.dart';
import '../../services/user_service.dart';
import '../../services/task_service.dart';
import '../../widgets/dialogs/task_creation_dialog.dart';
import 'detail_tabs/team_overview_tab.dart';
import 'detail_tabs/team_project_tab.dart';
import 'detail_tabs/team_members_tab.dart';
import 'detail_tabs/team_tasks_tab.dart';

class TeamDetailScreen extends StatefulWidget {
  final TeamPool team;

  const TeamDetailScreen({
    super.key,
    required this.team,
  });

  @override
  State<TeamDetailScreen> createState() => _TeamDetailScreenState();
}

class _TeamDetailScreenState extends State<TeamDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<User> _teamMembers = [];
  List<Task> _teamTasks = [];
  Task? _teamProject;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadTeamData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadTeamData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _loadTeamMembers();
      await _loadTeamTasks();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('加载团队数据失败: $e')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadTeamMembers() async {
    _teamMembers = [];
    for (final memberId in widget.team.memberIds) {
      final member = await UserService.getUserProfile(memberId);
      if (member != null) {
        _teamMembers.add(member);
      }
    }
  }

  Future<void> _loadTeamTasks() async {
    final allTasks = await TaskService.getAllTasks();
    _teamTasks =
        allTasks.where((task) => task.poolId == widget.team.id).toList();

    _teamProject = _teamTasks.firstWhere(
      (task) => task.level == TaskLevel.project,
      orElse: () => Task(
        id: 'default_project_${widget.team.id}',
        poolId: widget.team.id,
        title: widget.team.name,
        description: widget.team.description,
        estimatedMinutes: 2400,
        expectedAt: DateTime.now().add(const Duration(days: 30)),
        status: TaskStatus.pending,
        createdAt: DateTime.now(),
        statistics: const TaskStatistics(),
        priority: TaskPriority.high,
        baseReward: 100.0,
        level: TaskLevel.project,
        tags: widget.team.tags,
        assignedUsers: widget.team.memberIds,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

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
              // Header
              _buildHeader(),

              // Tab Bar
              _buildTabBar(colorScheme),

              const SizedBox(height: 16),

              // Content
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : TabBarView(
                          controller: _tabController,
                          children: [
                            TeamOverviewTab(
                              team: widget.team,
                              teamProject: _teamProject,
                            ),
                            TeamProjectTab(
                              team: widget.team,
                              teamProject: _teamProject,
                              onCreateProject: _createTeamProject,
                              onCreateSubTask: _createSubTask,
                            ),
                            TeamMembersTab(
                              teamMembers: _teamMembers,
                              team: widget.team,
                              onMemberAction: _handleMemberAction,
                            ),
                            TeamTasksTab(
                              team: widget.team,
                              tasks: _teamTasks,
                              teamMembers: _teamMembers,
                              onTaskTap: _handleTaskTap,
                              onAddTask: _createNewTask,
                            ),
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

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.team.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  widget.team.teamType.displayName,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          _buildTeamActions(),
        ],
      ),
    );
  }

  Widget _buildTabBar(ColorScheme colorScheme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(25),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
        ),
        labelColor: colorScheme.primary,
        unselectedLabelColor: Colors.white,
        isScrollable: true,
        tabs: const [
          Tab(text: '概览'),
          Tab(text: '项目'),
          Tab(text: '成员'),
          Tab(text: '任务'),
        ],
      ),
    );
  }

  Widget _buildTeamActions() {
    final appProvider = context.read<AppProvider>();
    final currentUserId = appProvider.currentUser?.id;
    final isLeader = widget.team.leaderId == currentUserId;
    final isMember = widget.team.memberIds.contains(currentUserId);

    return PopupMenuButton<String>(
      onSelected: _handleAction,
      icon: const Icon(Icons.more_vert, color: Colors.white),
      itemBuilder: (context) => [
        if (isLeader) ...[
          const PopupMenuItem(value: 'edit', child: Text('编辑团队')),
          const PopupMenuItem(value: 'manage_members', child: Text('管理成员')),
          const PopupMenuItem(value: 'team_settings', child: Text('团队设置')),
        ],
        if (isMember && !isLeader)
          const PopupMenuItem(value: 'leave_team', child: Text('退出团队')),
        const PopupMenuItem(value: 'share', child: Text('分享团队')),
      ],
    );
  }

  void _handleAction(String action) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$action功能即将上线')),
    );
  }

  void _handleMemberAction(User member, String action) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('对${member.name}的$action功能即将上线')),
    );
  }

  void _handleTaskTap(Task task) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('查看任务: ${task.title}')),
    );
  }

  void _createNewTask() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => TaskCreationDialog(
        team: widget.team,
      ),
    );

    if (result == true) {
      _loadTeamData();
    }
  }

  void _createSubTask(Task parentTask) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => TaskCreationDialog(
        team: widget.team,
        parentTask: parentTask,
      ),
    );

    if (result == true) {
      _loadTeamData();
    }
  }

  void _createTeamProject() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => TaskCreationDialog(
        team: widget.team,
      ),
    );

    if (result == true) {
      _loadTeamData();
    }
  }
}
