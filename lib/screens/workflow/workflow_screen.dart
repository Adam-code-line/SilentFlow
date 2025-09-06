import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/team_pool_model.dart';
import '../../providers/app_provider.dart';
import '../../providers/team_pool_provider.dart';
import '../../widgets/workflow_graph/mock_workflow_view.dart';

/// 高级工作流图页面
class WorkflowScreen extends StatefulWidget {
  final String? teamId;
  const WorkflowScreen({super.key, this.teamId});

  @override
  State<WorkflowScreen> createState() => _WorkflowScreenState();
}

class _WorkflowScreenState extends State<WorkflowScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final List<TeamPool> _userTeams = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 0, vsync: this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadUserTeams();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadUserTeams() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _userTeams.clear();
    });

    try {
      final appProvider = context.read<AppProvider>();
      final currentUserId = appProvider.currentUser?.id;

      print('WorkflowScreen: 加载用户团队，用户ID: $currentUserId');

      if (currentUserId == null) {
        print('WorkflowScreen: 用户ID为空，无法加载团队');
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final teamProvider = context.read<TeamPoolProvider>();
      print('WorkflowScreen: 获取TeamPoolProvider成功');

      final allTeams = await teamProvider.getUserTeams(currentUserId);
      print('WorkflowScreen: 获取到 ${allTeams.length} 个团队');

      if (!mounted) return;

      setState(() {
        _userTeams.clear();
        _userTeams.addAll(allTeams);
        _isLoading = false;

        _tabController.dispose();
        _tabController = TabController(
          length: _userTeams.length,
          vsync: this,
          initialIndex: widget.teamId != null
              ? _userTeams
                  .indexWhere((team) => team.id == widget.teamId)
                  .clamp(0, _userTeams.length - 1)
              : 0,
        );
      });

      print('WorkflowScreen: 团队列表更新完成，共 ${_userTeams.length} 个团队');
    } catch (e) {
      if (!mounted) return;
      print('WorkflowScreen: 加载团队失败: $e');
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('加载团队失败: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _handleTaskTap(String taskId, TeamPool team) {
    // Handle task tap
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = context.watch<AppProvider>();
    final currentUserId = appProvider.currentUser?.id;

    if (_isLoading) {
      return Scaffold(
        appBar: _buildAppBar(currentUserId),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_userTeams.isEmpty) {
      return Scaffold(
        appBar: _buildAppBar(currentUserId),
        body: _buildEmptyState(),
      );
    }

    return Scaffold(
      appBar: _buildAppBar(currentUserId),
      body: _buildBody(currentUserId),
    );
  }

  PreferredSizeWidget _buildAppBar(String? currentUserId) {
    return AppBar(
      title: const Text(
        '工作流图',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      backgroundColor: const Color(0xFF4C51BF),
      elevation: 0,
      centerTitle: true,
      iconTheme: const IconThemeData(color: Colors.white),
      bottom: _userTeams.isNotEmpty
          ? TabBar(
              controller: _tabController,
              isScrollable: true,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              indicatorColor: Colors.white,
              tabs: _userTeams.map((team) => Tab(text: team.name)).toList(),
            )
          : null,
    );
  }

  Widget _buildBody(String? currentUserId) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF4C51BF),
            Color(0xFFF7FAFC),
          ],
          stops: [0.0, 0.3],
        ),
      ),
      child: TabBarView(
        controller: _tabController,
        children: _userTeams
            .map((team) => _buildTeamWorkflow(team, currentUserId))
            .toList(),
      ),
    );
  }

  Widget _buildTeamWorkflow(TeamPool team, String? currentUserId) {
    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isSmallScreen = constraints.maxWidth < 600;

          return Column(
            children: [
              _buildTeamInfoCard(team, currentUserId, isSmallScreen),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: isSmallScreen ? 8.0 : 16.0),
                  child: MockWorkflowView(
                    team: team,
                    isEditable: team.leaderId == currentUserId,
                    onTaskTap: (taskId) => _handleTaskTap(taskId, team),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTeamInfoCard(
      TeamPool team, String? currentUserId, bool isSmallScreen) {
    return Padding(
      padding: EdgeInsets.all(isSmallScreen ? 12.0 : 16.0),
      child: Container(
        padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: isSmallScreen
            ? _buildSmallScreenTeamInfo(team, currentUserId)
            : _buildLargeScreenTeamInfo(team, currentUserId),
      ),
    );
  }

  Widget _buildLargeScreenTeamInfo(TeamPool team, String? currentUserId) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF4C51BF).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            team.leaderId == currentUserId ? Icons.verified_user : Icons.groups,
            size: 32,
            color: const Color(0xFF4C51BF),
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                team.name,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3748),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                team.description.isEmpty ? '暂无描述' : team.description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildStatusChip(team),
                  const SizedBox(width: 12),
                  _buildMemberCount(team),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSmallScreenTeamInfo(TeamPool team, String? currentUserId) {
    return Column(
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF4C51BF).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                team.leaderId == currentUserId
                    ? Icons.verified_user
                    : Icons.groups,
                size: 24,
                color: const Color(0xFF4C51BF),
              ),
            ),
            const SizedBox(width: 12),
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
          ],
        ),
        const SizedBox(height: 12),
        Text(
          team.description.isEmpty ? '暂无描述' : team.description,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[600],
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildStatusChip(team),
            const SizedBox(width: 12),
            _buildMemberCount(team),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusChip(TeamPool team) {
    final bool isActive = team.status == TeamStatus.active;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isActive
            ? Colors.green.withOpacity(0.1)
            : Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isActive ? Colors.green : Colors.orange,
          width: 1,
        ),
      ),
      child: Text(
        isActive ? '活跃' : _getStatusDisplayName(team.status),
        style: TextStyle(
          color: isActive ? Colors.green[700] : Colors.orange[700],
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  String _getStatusDisplayName(TeamStatus status) {
    switch (status) {
      case TeamStatus.active:
        return '活跃';
      case TeamStatus.paused:
        return '暂停';
      case TeamStatus.completed:
        return '已完成';
      case TeamStatus.disbanded:
        return '已解散';
    }
  }

  Widget _buildMemberCount(TeamPool team) {
    return Row(
      children: [
        Icon(
          Icons.people,
          size: 16,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 4),
        Text(
          '${team.memberIds.length} 成员',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF4C51BF).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.account_tree,
                size: 64,
                color: Color(0xFF4C51BF),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              '暂无团队',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3748),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '您还没有加入任何团队\n创建或加入团队来开始使用工作流功能',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => Navigator.of(context).pushNamed('/team_pool'),
              icon: const Icon(Icons.add),
              label: const Text('管理团队'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4C51BF),
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
