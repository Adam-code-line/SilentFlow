import 'package:flutter/material.dart';
import '../config/app_config.dart';
import '../services/mock_team_service.dart';
import '../services/team_service.dart';

/// 开发者工具页面 - 仅在开发模式下可用
class DeveloperToolsScreen extends StatefulWidget {
  const DeveloperToolsScreen({super.key});

  @override
  State<DeveloperToolsScreen> createState() => _DeveloperToolsScreenState();
}

class _DeveloperToolsScreenState extends State<DeveloperToolsScreen> {
  bool _isDevelopmentMode = AppConfig.isDevelopmentMode;
  bool _useMockData = AppConfig.useMockData;
  bool _enableDebugLogging = AppConfig.enableDebugLogging;

  final _teamIdController = TextEditingController();
  final _teamPasswordController = TextEditingController();
  final _teamNameController = TextEditingController();
  final _userIdController = TextEditingController(text: 'user_dev_test');

  List<Map<String, dynamic>> _userTeams = [];
  Map<String, dynamic>? _teamStatistics;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    if (AppConfig.isDevelopmentMode) {
      _loadUserData();
    }
  }

  Future<void> _loadUserData() async {
    if (!mounted) return;
    setState(() => _loading = true);

    try {
      final teams = await TeamService.getUserTeams(_userIdController.text);
      final stats = await TeamService.getTeamStatistics(_userIdController.text);

      if (mounted) {
        setState(() {
          _userTeams = teams;
          _teamStatistics = stats;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('加载数据失败: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _createTestTeam() async {
    if (_teamIdController.text.isEmpty ||
        _teamPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请填写团队ID和密码')),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      final teamId = await TeamService.createTeam(
        teamId: _teamIdController.text,
        teamPassword: _teamPasswordController.text,
        teamLeader: _userIdController.text,
        teamName:
            _teamNameController.text.isEmpty ? null : _teamNameController.text,
        description: '这是一个测试团队',
        teamType: 'development',
      );

      if (mounted) {
        if (teamId != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('团队创建成功: $teamId')),
          );
          _loadUserData(); // 刷新数据
          _teamIdController.clear();
          _teamPasswordController.clear();
          _teamNameController.clear();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('团队创建失败')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('创建团队异常: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _clearMockData() async {
    MockTeamService.clearMockData();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('模拟数据已清除')),
    );
    _loadUserData(); // 刷新数据
  }

  @override
  Widget build(BuildContext context) {
    if (!AppConfig.isDevelopmentMode) {
      return Scaffold(
        appBar: AppBar(title: const Text('开发者工具')),
        body: const Center(
          child: Text(
            '开发者工具仅在开发模式下可用',
            style: TextStyle(fontSize: 18),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('开发者工具'),
        backgroundColor: Colors.orange,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 配置区域
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '开发配置',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 16),
                          SwitchListTile(
                            title: const Text('开发模式'),
                            subtitle: const Text('启用开发者功能'),
                            value: _isDevelopmentMode,
                            onChanged: (value) {
                              setState(() => _isDevelopmentMode = value);
                              // 这里应该更新AppConfig，但为了简化只是更新本地状态
                            },
                          ),
                          SwitchListTile(
                            title: const Text('使用模拟数据'),
                            subtitle: const Text('使用本地模拟数据替代API'),
                            value: _useMockData,
                            onChanged: _isDevelopmentMode
                                ? (value) {
                                    setState(() => _useMockData = value);
                                    // 这里应该更新AppConfig
                                  }
                                : null,
                          ),
                          SwitchListTile(
                            title: const Text('调试日志'),
                            subtitle: const Text('显示详细的调试信息'),
                            value: _enableDebugLogging,
                            onChanged: (value) {
                              setState(() => _enableDebugLogging = value);
                              // 这里应该更新AppConfig
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 测试用户区域
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '测试用户',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _userIdController,
                            decoration: const InputDecoration(
                              labelText: '用户ID',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _loadUserData,
                            child: const Text('刷新用户数据'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 团队创建区域
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '创建测试团队',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _teamIdController,
                            decoration: const InputDecoration(
                              labelText: '团队ID',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _teamPasswordController,
                            decoration: const InputDecoration(
                              labelText: '团队密码',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _teamNameController,
                            decoration: const InputDecoration(
                              labelText: '团队名称（可选）',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              ElevatedButton(
                                onPressed: _createTestTeam,
                                child: const Text('创建团队'),
                              ),
                              const SizedBox(width: 16),
                              ElevatedButton(
                                onPressed: _clearMockData,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                ),
                                child: const Text('清除模拟数据'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 团队统计
                  if (_teamStatistics != null)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '团队统计',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 16),
                            Text('总团队数: ${_teamStatistics!['totalTeams']}'),
                            Text('活跃团队: ${_teamStatistics!['activeTeams']}'),
                            Text(
                                '担任领导: ${_teamStatistics!['leadershipCount']}'),
                            Text(
                                '作为成员: ${_teamStatistics!['membershipCount']}'),
                            Text(
                                '平均团队规模: ${_teamStatistics!['averageTeamSize']?.toStringAsFixed(1)}'),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),

                  // 用户团队列表
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '用户团队列表',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 16),
                          if (_userTeams.isEmpty)
                            const Text('暂无团队')
                          else
                            Column(
                              children: _userTeams.map((team) {
                                return ListTile(
                                  title: Text(team['name'] ?? '未命名团队'),
                                  subtitle: Text(
                                    '类型: ${team['teamType']} | 状态: ${team['status']} | 成员: ${(team['members'] as List).length}',
                                  ),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () async {
                                      final success =
                                          await TeamService.deleteTeam(
                                        team['teamUID'].toString(),
                                      );
                                      if (success) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                              content: Text('团队删除成功')),
                                        );
                                        _loadUserData();
                                      }
                                    },
                                  ),
                                );
                              }).toList(),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  @override
  void dispose() {
    _teamIdController.dispose();
    _teamPasswordController.dispose();
    _teamNameController.dispose();
    _userIdController.dispose();
    super.dispose();
  }
}
