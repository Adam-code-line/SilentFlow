import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:animations/animations.dart';
import 'package:shimmer/shimmer.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:auto_size_text/auto_size_text.dart';

import '../../models/team_pool_model.dart';
import '../../providers/team_pool_provider.dart';
import '../../widgets/dialogs/team_creation_dialog.dart';

// 导入组件模块
import '../../widgets/team/current_team_card.dart';
import '../../widgets/team/no_team_card.dart';
import 'tabs/my_teams_tab.dart';
import 'tabs/discover_teams_tab.dart';
import 'tabs/team_stats_tab.dart';

// 自定义颜色主题
class TeamPoolColors {
  static const primary = Color(0xFF667eea);
  static const secondary = Color(0xFF764ba2);
  static const accent = Color(0xFFc77dff);
  static const dark = Color(0xFF2b2d42);
  static const light = Color(0xFFf8f9fa);
  static const success = Color(0xFF4cc9f0);
  static const danger = Color(0xFFf72585);
  static const warning = Color(0xFFf7b2bd);
  static const info = Color(0xFF4361ee);
}

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

  // 高级阴影样式
  static const BoxShadow _cardShadow = BoxShadow(
    color: Color.fromARGB(30, 0, 0, 0),
    offset: Offset(0, 8),
    blurRadius: 24,
    spreadRadius: 0,
  );

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: 0,
    );

    // 添加页面切换动画监听
    _tabController.addListener(() {
      setState(() {});
    });

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

  // 显示美化的提示框
  void _showToast(String message, {bool isError = false}) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: isError ? TeamPoolColors.danger : TeamPoolColors.success,
      textColor: Colors.white,
      fontSize: 14.0,
      webBgColor: isError ? "#f72585" : "#4cc9f0",
      webPosition: "center",
    );
  }

  void _showCreateTeamOptions() {
    showDialog(
      context: context,
      builder: (context) => const TeamCreationDialog(),
    );
  }

  void _navigateToJoinTeam() {
    _showToast('加入团队功能开发中...');
  }

  void _navigateToTeamDetail(TeamPool team) {
    _showToast('团队详情功能开发中...');
  }

  void _showTeamOptions(TeamPool team) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        margin: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [TeamPoolColors.primary, TeamPoolColors.secondary],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.white.withOpacity(0.2),
                    child: Icon(
                      Icons.group,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      team.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildTeamOption(
                    icon: Icons.info_outline,
                    title: '团队详情',
                    subtitle: '查看团队信息和成员',
                    onTap: () {
                      Navigator.pop(context);
                      _navigateToTeamDetail(team);
                    },
                  ),
                  const Divider(),
                  _buildTeamOption(
                    icon: Icons.share,
                    title: '邀请成员',
                    subtitle: '生成邀请码分享给朋友',
                    onTap: () {
                      Navigator.pop(context);
                      _generateInviteCode(team);
                    },
                  ),
                  const Divider(),
                  _buildTeamOption(
                    icon: Icons.settings,
                    title: '团队设置',
                    subtitle: '管理团队配置和权限',
                    onTap: () {
                      Navigator.pop(context);
                      _showTeamSettings(team);
                    },
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 高级加载骨架屏 - 使用SpinKit动画
  Widget _buildAdvancedLoadingSkeleton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [_cardShadow],
      ),
      child: Column(
        children: [
          // 使用SpinKit创建优雅的加载动画
          SpinKitWave(
            color: TeamPoolColors.primary,
            size: 30.0,
          ),
          const SizedBox(height: 16),
          AutoSizeText(
            '正在加载团队信息...',
            style: TextStyle(
              fontSize: 16,
              color: TeamPoolColors.primary,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
          ),
          const SizedBox(height: 16),
          // 添加shimmer效果的骨架
          Shimmer.fromColors(
            baseColor: Colors.grey[200]!,
            highlightColor: Colors.grey[100]!,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 120,
                  height: 20,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                Container(
                  width: double.infinity,
                  height: 16,
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                Container(
                  width: 200,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMyTeamsTab() {
    return MyTeamsTab(
      onTeamTap: (TeamPool team) => _navigateToTeamDetail(team),
      onTeamLongPress: (TeamPool team) => _showTeamOptions(team),
      onCreateTeam: () => _showCreateTeamOptions(),
    );
  }

  Widget _buildDiscoverTeamsTab() {
    return DiscoverTeamsTab(
      onJoinTeam: (TeamPool team) => _showJoinTeamDialog(team),
      filteredTeams: _filteredTeams,
      searchController: _searchController,
      onSearchChanged: (String query) => _onSearchChanged(query),
    );
  }

  Widget _buildStatsTab() {
    return const TeamStatsTab();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 透明背景，使用渐变
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
          // 更柔和的渐变效果
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              TeamPoolColors.primary,
              TeamPoolColors.secondary,
              TeamPoolColors.accent,
            ],
            stops: const [0.0, 0.6, 1.0],
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
                    // 标题栏
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            // 团队图标 - 使用 SVG 或回退到 Material Icon
                            SvgPicture.asset(
                              'assets/icons/team_icon.svg',
                              color: Colors.white,
                              height: 32,
                              width: 32,
                              // 如果SVG不存在，使用回退图标
                              placeholderBuilder: (context) => Icon(
                                Icons.groups_rounded,
                                color: Colors.white,
                                size: 32,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              '团队池',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 0.5,
                                shadows: [
                                  Shadow(
                                    color: Color.fromARGB(40, 0, 0, 0),
                                    offset: Offset(1, 1),
                                    blurRadius: 2,
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                        // 操作按钮
                        Row(
                          children: [
                            _buildActionButton(
                              icon: Icons.add,
                              label: '创建',
                              onPressed: _showCreateTeamOptions,
                            ),
                            const SizedBox(width: 12),
                            _buildActionButton(
                              icon: Icons.group_add,
                              label: '加入',
                              onPressed: () => _navigateToJoinTeam(),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // 当前团队卡片 - 添加高级动画过渡
                    Consumer<TeamPoolProvider>(
                      builder: (context, provider, child) {
                        if (provider.isLoading) {
                          // 高级加载动画
                          return _buildAdvancedLoadingSkeleton();
                        }

                        // 使用 PageTransitionSwitcher 创建炫酷过渡效果
                        return PageTransitionSwitcher(
                          duration: const Duration(milliseconds: 400),
                          transitionBuilder: (
                            child,
                            primaryAnimation,
                            secondaryAnimation,
                          ) {
                            return SharedAxisTransition(
                              animation: primaryAnimation,
                              secondaryAnimation: secondaryAnimation,
                              transitionType: SharedAxisTransitionType.scaled,
                              fillColor: Colors.transparent,
                              child: child,
                            );
                          },
                          child: provider.currentTeam != null
                              ? CurrentTeamCard(
                                  key: ValueKey(
                                      'current_team_${provider.currentTeam!.id}'),
                                  team: provider.currentTeam!,
                                  onTap: () => _navigateToTeamDetail(
                                      provider.currentTeam!),
                                  shadow: _cardShadow,
                                )
                              : NoTeamCard(
                                  key: const ValueKey('no_team'),
                                ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // 标签页 - 美化样式
              _buildTabBar(),
              const SizedBox(height: 16),
              // 标签页内容
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                    boxShadow: [_cardShadow],
                    // 添加微妙的渐变
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFFffffff),
                        Color(0xFFf8f9fa),
                      ],
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildMyTeamsTab(),
                        _buildDiscoverTeamsTab(),
                        _buildStatsTab(),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 高级拟物风格操作按钮
  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: 100,
      height: 44,
      decoration: BoxDecoration(
        // 拟物风格：多层阴影效果
        color: TeamPoolColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          // 外部阴影 (凸起效果)
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            offset: const Offset(4, 4),
            blurRadius: 10,
            spreadRadius: 1,
          ),
          // 内部高光 (凹陷效果)
          BoxShadow(
            color: Colors.white.withOpacity(0.7),
            offset: const Offset(-2, -2),
            blurRadius: 6,
            spreadRadius: 1,
          ),
        ],
        // 渐变背景
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.3),
            TeamPoolColors.primary.withOpacity(0.2),
            TeamPoolColors.secondary.withOpacity(0.3),
          ],
        ),
        // 玻璃态边框
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: onPressed,
          child: Container(
            padding: EdgeInsets.zero,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 18, color: Colors.white),
                const SizedBox(width: 6),
                AutoSizeText(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                  maxLines: 1,
                  minFontSize: 10,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 高级玻璃态标签栏
  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      height: 52,
      decoration: BoxDecoration(
        // 玻璃态背景
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          // 玻璃态阴影效果
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            offset: const Offset(0, 8),
            blurRadius: 24,
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.1),
            offset: const Offset(0, -2),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ],
        // 渐变边框
        border: Border.all(
          width: 1.5,
          color: Colors.transparent,
        ),
        // 背景渐变
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.25),
            Colors.white.withOpacity(0.1),
            TeamPoolColors.primary.withOpacity(0.1),
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: TabBar(
            controller: _tabController,
            indicator: BoxDecoration(
              // 高级渐变指示器
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  TeamPoolColors.success,
                  TeamPoolColors.info,
                  TeamPoolColors.accent,
                ],
                stops: const [0.0, 0.6, 1.0],
              ),
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: TeamPoolColors.success.withOpacity(0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 3),
                  spreadRadius: 2,
                ),
              ],
            ),
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white.withOpacity(0.7),
            labelStyle: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 14,
              letterSpacing: 0.5,
            ),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 13,
              letterSpacing: 0.3,
            ),
            padding: const EdgeInsets.all(4),
            indicatorWeight: 1,
            tabs: [
              _buildTab('我的团队', Icons.group),
              _buildTab('发现团队', Icons.explore),
              _buildTab('团队统计', Icons.bar_chart),
            ],
          ),
        ),
      ),
    );
  }

  // 美化的标签
  Widget _buildTab(String text, IconData icon) {
    return Tab(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 8),
          Text(text),
        ],
      ),
    );
  }

  // 构建团队选项项
  Widget _buildTeamOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: TeamPoolColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: TeamPoolColors.primary,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: 14,
        ),
      ),
      onTap: onTap,
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Colors.grey[400],
      ),
    );
  }

  // 生成邀请码
  void _generateInviteCode(TeamPool team) async {
    try {
      // 模拟生成邀请码
      final inviteCode =
          'INV${team.id.toUpperCase()}${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(Icons.share, color: TeamPoolColors.primary),
              const SizedBox(width: 8),
              const Text('邀请码'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        inviteCode,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: inviteCode));
                        _showToast('邀请码已复制到剪贴板');
                      },
                      icon: const Icon(Icons.copy),
                      tooltip: '复制邀请码',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '分享此邀请码给朋友，他们可以使用此码加入 ${team.name}',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('关闭'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                // 这里可以调用系统分享功能
                _showToast('分享功能开发中...');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: TeamPoolColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('分享'),
            ),
          ],
        ),
      );
    } catch (e) {
      _showToast('生成邀请码失败', isError: true);
    }
  }

  // 显示团队设置
  void _showTeamSettings(TeamPool team) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Icon(Icons.settings, color: TeamPoolColors.primary),
            const SizedBox(width: 8),
            const Text('团队设置'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('编辑团队信息'),
              onTap: () {
                Navigator.pop(context);
                _showToast('编辑团队信息功能开发中...');
              },
            ),
            ListTile(
              leading: const Icon(Icons.people),
              title: const Text('成员管理'),
              onTap: () {
                Navigator.pop(context);
                _showToast('成员管理功能开发中...');
              },
            ),
            ListTile(
              leading: const Icon(Icons.security),
              title: const Text('权限设置'),
              onTap: () {
                Navigator.pop(context);
                _showToast('权限设置功能开发中...');
              },
            ),
            ListTile(
              leading: Icon(Icons.exit_to_app, color: Colors.red[400]),
              title: Text('离开团队', style: TextStyle(color: Colors.red[400])),
              onTap: () {
                Navigator.pop(context);
                _confirmLeaveTeam(team);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }

  // 确认离开团队
  void _confirmLeaveTeam(TeamPool team) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text('确认离开团队'),
        content: Text('确定要离开 "${team.name}" 吗？此操作无法撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              // 这里调用离开团队的逻辑
              _showToast('离开团队功能开发中...');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('确认离开'),
          ),
        ],
      ),
    );
  }

  // 显示加入团队对话框
  void _showJoinTeamDialog(TeamPool team) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Icon(Icons.group_add, color: TeamPoolColors.primary),
            const SizedBox(width: 8),
            const Text('加入团队'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '确定要加入 "${team.name}" 吗？',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 12),
            Text(
              team.description,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.people, size: 16, color: Colors.grey[500]),
                const SizedBox(width: 4),
                Text(
                  '${team.allMemberIds.length}/${team.maxMembers} 成员',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              // 这里调用加入团队的逻辑
              _showToast('加入团队功能开发中...');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: TeamPoolColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('确认加入'),
          ),
        ],
      ),
    );
  }

  // 搜索变化处理
  void _onSearchChanged(String query) {
    final provider = Provider.of<TeamPoolProvider>(context, listen: false);
    setState(() {
      if (query.isEmpty) {
        _filteredTeams = [];
      } else {
        _filteredTeams = provider.searchTeamsSync(query);
      }
    });
  }
}
