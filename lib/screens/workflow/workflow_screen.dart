import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/team_pool_model.dart';
import '../../providers/app_provider.dart';
import '../../providers/team_pool_provider.dart';
import '../../widgets/workflow_graph/workflow_graph_view.dart';

/// 高级工作流图页面
class WorkflowScreen extends StatefulWidget {
  final String? teamId;
  const WorkflowScreen({super.key, this.teamId});

  @override
  State<WorkflowScreen> createState() => _WorkflowScreenState();
}

class _WorkflowScreenState extends State<WorkflowScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<TeamPool> _userTeams = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 0, vsync: this);
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
      final teamPoolProvider = context.read<TeamPoolProvider>();
      final userId = appProvider.currentUser?.id;

      if (userId != null) {
        final allTeams = teamPoolProvider.teamPools;
        _userTeams.addAll(allTeams
            .where((team) =>
                team.leaderId == userId || team.memberIds.contains(userId))
            .toList());

        if (_userTeams.isNotEmpty && mounted) {
          _tabController.dispose();
          _tabController =
              TabController(length: _userTeams.length, vsync: this);
          if (widget.teamId != null) {
            final initialIndex =
                _userTeams.indexWhere((team) => team.id == widget.teamId);
            if (initialIndex != -1) {
              _tabController.animateTo(initialIndex);
            }
          }
        }
      }
    } catch (e) {
      debugPrint('WorkflowScreen: 加载团队数据失败 - $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('加载团队数据失败: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text(
        '团队工作流图',
        style: TextStyle(
          color: Color(0xFF2D3748),
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Color(0xFF2D3748)),
        onPressed: () =>
            Navigator.of(context).pushReplacementNamed('/main', arguments: 1),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh, color: Color(0xFF2D3748)),
          onPressed: _loadUserTeams,
          tooltip: '刷新数据',
        ),
        IconButton(
          icon: const Icon(Icons.info_outline, color: Color(0xFF2D3748)),
          onPressed: _showWorkflowInfo,
          tooltip: '工作流说明',
        ),
      ],
      bottom: _userTeams.isEmpty
          ? null
          : TabBar(
              controller: _tabController,
              isScrollable: true,
              indicatorColor: const Color(0xFF4C51BF),
              labelColor: const Color(0xFF4C51BF),
              unselectedLabelColor: Colors.grey[600],
              labelStyle: const TextStyle(fontWeight: FontWeight.bold),
              tabs: _userTeams.map((team) {
                return Tab(
                  icon: Icon(
                    team.leaderId == context.read<AppProvider>().currentUser?.id
                        ? Icons.shield
                        : Icons.group,
                    size: 20,
                  ),
                  text: team.name,
                );
              }).toList(),
            ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4C51BF)),
        ),
      );
    }
    if (_userTeams.isEmpty) {
      return _buildEmptyState();
    }
    return TabBarView(
      controller: _tabController,
      children: _userTeams.map((team) => _buildTeamWorkflow(team)).toList(),
    );
  }

  Widget _buildTeamWorkflow(TeamPool team) {
    return SafeArea(
      child: Column(
        children: [
          _buildTeamInfoCard(team),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: WorkflowGraphView(
                team: team,
                isEditable: team.leaderId ==
                    context.read<AppProvider>().currentUser?.id,
                onTaskTap: (taskId) => _handleTaskTap(taskId, team),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamInfoCard(TeamPool team) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        padding: const EdgeInsets.all(20),
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
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF4C51BF).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                team.leaderId == context.read<AppProvider>().currentUser?.id
                    ? Icons.verified_user
                    : Icons.groups,
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
                  const SizedBox(height: 6),
                  Text(
                    team.description.isEmpty ? '暂无描述' : team.description,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
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
        ),
      ),
    );
  }

  Widget _buildStatusChip(TeamPool team) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: team.status == TeamStatus.active
            ? Colors.green.withOpacity(0.15)
            : Colors.orange.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            team.status == TeamStatus.active
                ? Icons.check_circle
                : Icons.pause_circle,
            size: 14,
            color: team.status == TeamStatus.active
                ? Colors.green[700]
                : Colors.orange[700],
          ),
          const SizedBox(width: 4),
          Text(
            team.status == TeamStatus.active ? '活跃' : '非活跃',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: team.status == TeamStatus.active
                  ? Colors.green[700]
                  : Colors.orange[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMemberCount(TeamPool team) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.people,
            size: 14,
            color: Colors.blue[700],
          ),
          const SizedBox(width: 4),
          Text(
            '${team.memberIds.length + 1}',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.blue[700],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE2E8F0), Color(0xFFFFFFFF)],
          ),
        ),
        child: _buildBody(),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.account_tree_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 32),
          Text(
            '暂无工作流图',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              '您还没有创建或加入任何团队\n创建团队后即可查看工作流图',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[500],
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 40),
          ElevatedButton.icon(
            onPressed: () => Navigator.of(context)
                .pushReplacementNamed('/main', arguments: 1),
            icon: const Icon(Icons.add_box_outlined),
            label: const Text('去创建团队'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4C51BF),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              elevation: 2,
            ),
          ),
        ],
      ),
    );
  }

  void _handleTaskTap(String taskId, TeamPool team) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.task_alt, color: Colors.blue[600]),
            const SizedBox(width: 8),
            const Text('任务详情'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('任务ID', taskId),
            _buildDetailRow('所属团队', team.name),
            const SizedBox(height: 16),
            const Text(
              '可用操作：',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildActionItem('查看任务详细信息', Icons.info_outline),
            _buildActionItem('编辑任务内容', Icons.edit_outlined),
            _buildActionItem('查看任务进度', Icons.trending_up),
            _buildActionItem('管理任务依赖', Icons.link),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('关闭'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('任务详情功能开发中...')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4C51BF),
              foregroundColor: Colors.white,
            ),
            child: const Text('查看详情'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionItem(String text, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Text(text, style: TextStyle(color: Colors.grey[700])),
        ],
      ),
    );
  }

  void _showWorkflowInfo() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4C51BF).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.info_outline,
                        color: Color(0xFF4C51BF),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '工作流图说明',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF2D3748),
                          ),
                    ),
                  ],
                ),
                const Divider(height: 32),
                _buildInfoSection('功能特性', [
                  _buildFeatureItem('📊', '可视化展示', '以图形方式展示任务依赖关系，一目了然'),
                  _buildFeatureItem('🔗', '智能连线', '自动规划最佳路径，避免任务死循环'),
                  _buildFeatureItem('👤', '角色权限', '根据用户角色显示不同视图，权限管理更安全'),
                  _buildFeatureItem('📈', '实时进度', '任务状态实时更新，助您掌握项目全局'),
                ]),
                _buildInfoSection('状态颜色', [
                  _buildColorLegend(
                      const Color(0xFFF6AD55), '待处理', '任务已创建，等待分配或开始'),
                  _buildColorLegend(
                      const Color(0xFF4299E1), '进行中', '任务正在执行，可实时查看进度'),
                  _buildColorLegend(
                      const Color(0xFF48BB78), '已完成', '任务已成功完成，可追溯历史'),
                  _buildColorLegend(
                      const Color(0xFFF56565), '受阻', '任务遇到障碍，需要团队协助解决'),
                ]),
                const SizedBox(height: 32),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4C51BF),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('了解了'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D3748),
          ),
        ),
        const SizedBox(height: 16),
        ...items,
      ],
    );
  }

  Widget _buildFeatureItem(String emoji, String title, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            emoji,
            style: const TextStyle(fontSize: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2D3748),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorLegend(Color color, String status, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 16,
            height: 16,
            margin: const EdgeInsets.only(top: 2),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  status,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2D3748),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
