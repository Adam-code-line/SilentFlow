import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../widgets/beautiful_dialogs.dart';
import '../../widgets/team_creation_dialog.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  // 动画控制器
  late AnimationController _slideAnimationController;
  late AnimationController _fadeAnimationController;
  late AnimationController _chartAnimationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _chartAnimation;

  // 主题和状态
  bool _isDarkMode = false;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // 模拟数据
  final List<Map<String, dynamic>> _todayNodes = [
    {'content': '张三完成了「需求文档」', 'time': '10:30', 'type': 'completed'},
    {'content': '李四开始了「UI设计」', 'time': '14:15', 'type': 'started'},
    {'content': '王五遇到卡点「技术选型」', 'time': '16:45', 'type': 'blocked'},
  ];

  final List<double> _weeklyScores = [75, 82, 78, 85, 89, 92, 85];

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _startAnimations();
  }

  void _initAnimations() {
    _slideAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _chartAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _slideAnimation = Tween<double>(
      begin: 50.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _slideAnimationController,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeAnimationController,
      curve: Curves.easeOut,
    ));

    _chartAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _chartAnimationController,
      curve: Curves.elasticOut,
    ));
  }

  void _startAnimations() {
    _slideAnimationController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      _fadeAnimationController.forward();
    });
    Future.delayed(const Duration(milliseconds: 400), () {
      _chartAnimationController.forward();
    });
  }

  @override
  void dispose() {
    _slideAnimationController.dispose();
    _fadeAnimationController.dispose();
    _chartAnimationController.dispose();
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: _isDarkMode ? _buildDarkTheme() : _buildLightTheme(),
      child: Scaffold(
        backgroundColor:
            _isDarkMode ? const Color(0xFF0A0E1A) : Colors.grey[50],
        body: CustomScrollView(
          controller: _scrollController,
          slivers: [
            _buildDynamicSliverAppBar(),
            SliverPadding(
              padding: const EdgeInsets.all(20.0),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildSearchBar(),
                  const SizedBox(height: 24),
                  _buildPersonalizedInsight(),
                  const SizedBox(height: 24),
                  _buildEnhancedTacitCard(),
                  const SizedBox(height: 24),
                  _buildEnhancedTodayNodesCard(),
                  const SizedBox(height: 24),
                  _buildIntelligentQuickActions(),
                  const SizedBox(height: 24),
                  _buildEnhancedActivePoolsCard(),
                  const SizedBox(height: 24),
                  _buildPredictiveEfficiencyMap(),
                  const SizedBox(height: 100),
                ]),
              ),
            ),
          ],
        ),
        floatingActionButton: _buildSmartFAB(),
      ),
    );
  }

  ThemeData _buildLightTheme() {
    return ThemeData(
      brightness: Brightness.light,
      primarySwatch: Colors.indigo,
      scaffoldBackgroundColor: Colors.grey[50],
      cardColor: Colors.white,
    );
  }

  ThemeData _buildDarkTheme() {
    return ThemeData(
      brightness: Brightness.dark,
      primarySwatch: Colors.indigo,
      scaffoldBackgroundColor: const Color(0xFF0A0E1A),
      cardColor: const Color(0xFF1A1F35),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: Colors.white),
        bodyMedium: TextStyle(color: Colors.white70),
      ),
    );
  }

  Widget _buildDynamicSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 200,
      floating: false,
      pinned: true,
      backgroundColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: _isDarkMode
                  ? [
                      const Color(0xFF1A1F35),
                      const Color(0xFF2A2F45),
                      const Color(0xFF3A3F55),
                    ]
                  : [
                      Colors.indigo[300]!,
                      Colors.indigo[500]!,
                      Colors.purple[500]!,
                    ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _getTimeBasedGreeting(),
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              '静默协作',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              _getPersonalizedSubtitle(),
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          _buildThemeToggle(),
                          const SizedBox(width: 12),
                          _buildNotificationButton(),
                          const SizedBox(width: 12),
                          _buildUserAvatar(),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _getTimeBasedGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 6) return '夜深了，早点休息';
    if (hour < 12) return '早上好';
    if (hour < 14) return '中午好';
    if (hour < 18) return '下午好';
    if (hour < 22) return '晚上好';
    return '夜深了，注意休息';
  }

  String _getPersonalizedSubtitle() {
    final hour = DateTime.now().hour;
    if (hour < 9) return '新的一天，充满可能';
    if (hour < 12) return '团队协作正在进行';
    if (hour < 18) return '效率满满的下午';
    return '今天辛苦了';
  }

  Widget _buildThemeToggle() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isDarkMode = !_isDarkMode;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Icon(
            _isDarkMode ? Icons.light_mode : Icons.dark_mode,
            key: ValueKey(_isDarkMode),
            color: _isDarkMode ? Colors.amber : Colors.white,
            size: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationButton() {
    return GestureDetector(
      onTap: _showNotifications,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Stack(
          children: [
            const Icon(
              Icons.notifications_outlined,
              color: Colors.white,
              size: 20,
            ),
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserAvatar() {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.indigo[400]!, Colors.purple[400]!],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
      ),
      child: const Icon(
        Icons.person,
        color: Colors.white,
        size: 18,
      ),
    );
  }

  Widget _buildSearchBar() {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: _buildGlassCard(
            child: Row(
              children: [
                Icon(
                  Icons.search,
                  color: _isDarkMode ? Colors.white70 : Colors.grey[600],
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                      _handleSmartSearch(value);
                    },
                    decoration: InputDecoration(
                      hintText: '搜索项目、任务或输入命令...',
                      hintStyle: TextStyle(
                        color: _isDarkMode ? Colors.white54 : Colors.grey[500],
                        fontSize: 14,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                    style: TextStyle(
                      color: _isDarkMode ? Colors.white : Colors.black87,
                      fontSize: 14,
                    ),
                  ),
                ),
                if (_searchQuery.isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      _searchController.clear();
                      setState(() {
                        _searchQuery = '';
                      });
                    },
                    child: Icon(
                      Icons.clear,
                      color: _isDarkMode ? Colors.white70 : Colors.grey[600],
                      size: 18,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _handleSmartSearch(String query) {
    if (query.toLowerCase().contains('创建团队')) {
      _showCreateTeamDialog();
      _searchController.clear();
      setState(() {
        _searchQuery = '';
      });
    }
    // 可以添加更多智能命令
  }

  Widget _buildPersonalizedInsight() {
    return AnimatedBuilder(
      animation: _slideAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value),
          child: _buildGlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.blue[400]!, Colors.cyan[400]!],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.insights,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '个人洞察',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color:
                                  _isDarkMode ? Colors.white : Colors.black87,
                            ),
                          ),
                          Text(
                            '基于您的协作模式',
                            style: TextStyle(
                              fontSize: 12,
                              color: _isDarkMode
                                  ? Colors.white70
                                  : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildInsightMetric(
                          '完成任务', '12', Icons.check_circle, Colors.green),
                    ),
                    Expanded(
                      child: _buildInsightMetric(
                          '协作频次', '8.5', Icons.handshake, Colors.blue),
                    ),
                    Expanded(
                      child: _buildInsightMetric(
                          '响应速度', '快', Icons.speed, Colors.orange),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInsightMetric(
      String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: _isDarkMode ? Colors.white70 : Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildGlassCard({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: _isDarkMode
            ? const Color(0xFF1A1F35).withOpacity(0.7)
            : Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _isDarkMode
                ? Colors.black.withOpacity(0.3)
                : Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
        border: _isDarkMode
            ? Border.all(color: Colors.white.withOpacity(0.1))
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: child,
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedTacitCard() {
    return AnimatedBuilder(
      animation: _slideAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value),
          child: _buildInteractiveCard(
            onTap: () => _navigateToAnalytics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.purple[400]!, Colors.purple[600]!],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.psychology,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '团队协作指数',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color:
                                  _isDarkMode ? Colors.white : Colors.black87,
                            ),
                          ),
                          Text(
                            '点击查看详细分析',
                            style: TextStyle(
                              fontSize: 14,
                              color: _isDarkMode
                                  ? Colors.white70
                                  : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: _isDarkMode ? Colors.white54 : Colors.grey[400],
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // 迷你折线图
                _buildMiniChart(),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildEnhancedScoreItem(
                        '本周', '85', Colors.green, Icons.trending_up),
                    _buildEnhancedScoreItem(
                        '本月', '78', Colors.blue, Icons.calendar_month),
                    _buildEnhancedScoreItem(
                        '总分', '892', Colors.orange, Icons.emoji_events),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMiniChart() {
    return AnimatedBuilder(
      animation: _chartAnimation,
      builder: (context, child) {
        return Container(
          height: 60,
          width: double.infinity,
          child: CustomPaint(
            painter: MiniChartPainter(
              scores: _weeklyScores,
              animationValue: _chartAnimation.value,
              isDarkMode: _isDarkMode,
            ),
          ),
        );
      },
    );
  }

  Widget _buildInteractiveCard(
      {required Widget child, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: _isDarkMode ? const Color(0xFF1A1F35) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: _isDarkMode
                  ? Colors.black.withOpacity(0.3)
                  : Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
          border: _isDarkMode
              ? Border.all(color: Colors.white.withOpacity(0.1))
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: child,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedScoreItem(
      String label, String score, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _isDarkMode ? const Color(0xFF2A2F45) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(
            score,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: _isDarkMode ? Colors.white70 : Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedTodayNodesCard() {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: _buildGlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.blue[400]!, Colors.blue[600]!],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.timeline,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '今日关键节点',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color:
                                  _isDarkMode ? Colors.white : Colors.black87,
                            ),
                          ),
                          Text(
                            '实时团队动态',
                            style: TextStyle(
                              fontSize: 14,
                              color: _isDarkMode
                                  ? Colors.white70
                                  : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            '实时',
                            style: TextStyle(
                              color: Colors.green,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ...List.generate(_todayNodes.length, (index) {
                  return _buildAnimatedNodeItem(_todayNodes[index], index);
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedNodeItem(Map<String, dynamic> node, int index) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 600 + (index * 200)),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, (1 - value) * 30),
          child: Opacity(
            opacity: value,
            child: _buildEnhancedNodeItem(
              node['content'],
              node['time'],
              _getNodeColor(node['type']),
              _getNodeIcon(node['type']),
            ),
          ),
        );
      },
    );
  }

  Color _getNodeColor(String type) {
    switch (type) {
      case 'completed':
        return Colors.green;
      case 'started':
        return Colors.blue;
      case 'blocked':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _getNodeIcon(String type) {
    switch (type) {
      case 'completed':
        return Icons.check_circle;
      case 'started':
        return Icons.play_circle;
      case 'blocked':
        return Icons.help_outline;
      default:
        return Icons.info_outline;
    }
  }

  Widget _buildEnhancedNodeItem(
      String content, String time, Color color, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(_isDarkMode ? 0.15 : 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              content,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: _isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _isDarkMode
                  ? Colors.white.withOpacity(0.1)
                  : Colors.grey[100],
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              time,
              style: TextStyle(
                fontSize: 12,
                color: _isDarkMode ? Colors.white70 : Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIntelligentQuickActions() {
    return AnimatedBuilder(
      animation: _slideAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value),
          child: _buildGlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.auto_awesome,
                      color: Colors.purple[400],
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '智能快捷操作',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: _isDarkMode ? Colors.white : Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '基于您的使用习惯推荐',
                  style: TextStyle(
                    fontSize: 14,
                    color: _isDarkMode ? Colors.white70 : Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 16),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  childAspectRatio: 2.5,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  children: [
                    _buildSmartActionButton(
                        '认领任务', Icons.assignment_ind, Colors.green, _claimTask),
                    _buildSmartActionButton('创建文档', Icons.description,
                        Colors.blue, _createDocument),
                    _buildSmartActionButton(
                        '查看团队', Icons.groups, Colors.orange, _viewTeams),
                    _buildSmartActionButton(
                        '代码评审', Icons.code, Colors.purple, _codeReview),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSmartActionButton(
      String label, IconData icon, Color color, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(_isDarkMode ? 0.15 : 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedActivePoolsCard() {
    return _buildInteractiveCard(
      onTap: () => _navigateToTeams(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.cyan[400]!, Colors.cyan[600]!],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.water,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '活跃项目',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: _isDarkMode ? Colors.white : Colors.black87,
                        ),
                      ),
                      Text(
                        '当前进行中的团队协作',
                        style: TextStyle(
                          fontSize: 14,
                          color:
                              _isDarkMode ? Colors.white70 : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: _isDarkMode ? Colors.white54 : Colors.grey[400],
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildEnhancedPoolItem('软件开发团队', '4/6人', 0.75, Colors.green),
          const SizedBox(height: 12),
          _buildEnhancedPoolItem('学术论文协作', '3/4人', 0.60, Colors.blue),
        ],
      ),
    );
  }

  Widget _buildEnhancedPoolItem(
      String name, String members, double progress, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(_isDarkMode ? 0.15 : 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                name,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: _isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  members,
                  style: TextStyle(
                    fontSize: 12,
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: _isDarkMode
                        ? Colors.white.withOpacity(0.1)
                        : Colors.grey[200],
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.transparent,
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${(progress * 100).toInt()}%',
                style: TextStyle(
                  fontSize: 12,
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPredictiveEfficiencyMap() {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: _buildGlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.green[400]!, Colors.green[600]!],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.analytics,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '智能效率图谱',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color:
                                  _isDarkMode ? Colors.white : Colors.black87,
                            ),
                          ),
                          Text(
                            'AI分析您的协作模式',
                            style: TextStyle(
                              fontSize: 14,
                              color: _isDarkMode
                                  ? Colors.white70
                                  : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.auto_awesome,
                        color: Colors.green,
                        size: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _buildPredictiveTag(
                        '启动专家', Colors.green, Icons.rocket_launch, '92%'),
                    _buildPredictiveTag('收尾高手', Colors.blue, Icons.flag, '88%'),
                    _buildPredictiveTag(
                        '协调者', Colors.purple, Icons.handshake, '95%'),
                    _buildPredictiveTag(
                        '创新者', Colors.orange, Icons.lightbulb, '76%'),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(_isDarkMode ? 0.15 : 0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        color: Colors.blue,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '建议：您在项目启动阶段表现优异，可以考虑担任更多新项目的引导角色',
                          style: TextStyle(
                            fontSize: 12,
                            color:
                                _isDarkMode ? Colors.white70 : Colors.grey[700],
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPredictiveTag(
      String label, Color color, IconData icon, String accuracy) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: _isDarkMode ? const Color(0xFF2A2F45) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: _isDarkMode ? Colors.white : color,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '匹配度 $accuracy',
            style: TextStyle(
              color: _isDarkMode ? Colors.white70 : Colors.grey[600],
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmartFAB() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _isDarkMode
              ? [const Color(0xFF6C5CE7), const Color(0xFFA29BFE)]
              : [Colors.indigo[400]!, Colors.indigo[600]!],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color:
                (_isDarkMode ? Colors.purple : Colors.indigo).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: FloatingActionButton.extended(
        onPressed: _showCreateTeamDialog,
        backgroundColor: Colors.transparent,
        elevation: 0,
        icon: const Icon(Icons.group_add, color: Colors.white),
        label: const Text(
          '创建团队',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // Navigation methods
  void _navigateToAnalytics() {
    // TODO: Navigate to analytics page
  }

  void _navigateToTeams() {
    Navigator.of(context).pushReplacementNamed('/main', arguments: 1);
  }

  // Action methods
  void _claimTask() {
    // TODO: Implement task claiming
  }

  void _createDocument() {
    // TODO: Implement document creation
  }

  void _viewTeams() {
    _navigateToTeams();
  }

  void _codeReview() {
    // TODO: Implement code review
  }

  void _showCreateTeamDialog() {
    showDialog(
      context: context,
      builder: (context) => const TeamCreationDialog(isCustomCreation: false),
    );
  }

  void _showNotifications() {
    BeautifulDialogs.showConfirmDialog(
      context,
      title: '团队协作提醒',
      content: '仅显示重要团队节点：\n• 任务冲突提醒\n• 依赖关系变更\n• 关键任务完成\n• 团队成员动态',
      icon: Icons.notifications_active,
      iconColor: _isDarkMode ? Colors.purple[400] : Colors.indigo[600],
      confirmText: '知道了',
      onConfirm: () {},
    );
  }
}

// Custom painter for mini chart
class MiniChartPainter extends CustomPainter {
  final List<double> scores;
  final double animationValue;
  final bool isDarkMode;

  MiniChartPainter({
    required this.scores,
    required this.animationValue,
    required this.isDarkMode,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isDarkMode ? Colors.purple[400]! : Colors.purple[600]!
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final path = Path();
    final stepX = size.width / (scores.length - 1);
    final maxScore = scores.reduce(math.max);
    final minScore = scores.reduce(math.min);
    final scoreRange = maxScore - minScore;

    for (int i = 0; i < scores.length; i++) {
      final x = i * stepX;
      final normalizedScore = (scores[i] - minScore) / scoreRange;
      final y = size.height -
          (normalizedScore * size.height * 0.8 + size.height * 0.1);

      final animatedY = y + (size.height - y) * (1 - animationValue);

      if (i == 0) {
        path.moveTo(x, animatedY);
      } else {
        path.lineTo(x, animatedY);
      }
    }

    canvas.drawPath(path, paint);

    // Draw points
    final pointPaint = Paint()
      ..color = isDarkMode ? Colors.purple[300]! : Colors.purple[500]!
      ..style = PaintingStyle.fill;

    for (int i = 0; i < scores.length; i++) {
      final x = i * stepX;
      final normalizedScore = (scores[i] - minScore) / scoreRange;
      final y = size.height -
          (normalizedScore * size.height * 0.8 + size.height * 0.1);

      final animatedY = y + (size.height - y) * (1 - animationValue);
      canvas.drawCircle(Offset(x, animatedY), 3, pointPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
