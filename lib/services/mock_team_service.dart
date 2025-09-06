import 'dart:math';
import '../config/app_config.dart';

/// 模拟团队服务 - 用于开发阶段测试
class MockTeamService {
  // 模拟的团队数据存储
  static final Map<String, Map<String, dynamic>> _mockTeams = {};
  static final Map<String, List<String>> _userTeams = {}; // 用户ID -> 团队ID列表
  static int _nextTeamId = 1000;

  /// 初始化模拟数据
  static void initializeMockData() {
    if (_mockTeams.isEmpty) {
      AppConfig.debugLog('初始化模拟团队数据');

      // 创建一些示例团队
      _createSampleTeams();
    }
  }

  /// 创建示例团队
  static void _createSampleTeams() {
    final sampleTeams = [
      {
        'teamUID': 1001,
        'name': '移动开发团队',
        'description': '专注于Flutter和原生移动应用开发',
        'teamType': 'development',
        'status': 'active',
        'leader': 'user_admin_123',
        'members': ['user_admin_123', 'user_dev_456', 'user_design_789'],
        'tags': ['Flutter', '移动开发', 'UI/UX'],
        'createdAt':
            DateTime.now().subtract(const Duration(days: 30)).toIso8601String(),
      },
      {
        'teamUID': 1002,
        'name': '产品设计团队',
        'description': '负责产品原型设计和用户体验优化',
        'teamType': 'design',
        'status': 'active',
        'leader': 'user_design_789',
        'members': ['user_design_789', 'user_pm_101', 'user_research_202'],
        'tags': ['UI设计', '用户研究', '原型'],
        'createdAt':
            DateTime.now().subtract(const Duration(days: 15)).toIso8601String(),
      },
      {
        'teamUID': 1003,
        'name': '测试质量团队',
        'description': '软件测试和质量保证',
        'teamType': 'testing',
        'status': 'paused',
        'leader': 'user_qa_303',
        'members': ['user_qa_303', 'user_test_404'],
        'tags': ['自动化测试', '性能测试', '质量保证'],
        'createdAt':
            DateTime.now().subtract(const Duration(days: 7)).toIso8601String(),
      },
    ];

    for (final team in sampleTeams) {
      final teamId = team['teamUID'].toString();
      _mockTeams[teamId] = team;

      // 将团队添加到成员的团队列表中
      final members = team['members'] as List<String>;
      for (final memberId in members) {
        _userTeams[memberId] ??= [];
        if (!_userTeams[memberId]!.contains(teamId)) {
          _userTeams[memberId]!.add(teamId);
        }
      }
    }
  }

  /// 获取团队信息
  static Future<Map<String, dynamic>?> getTeamInfo(String teamId) async {
    AppConfig.debugLog('模拟获取团队信息: $teamId');
    await AppConfig.mockDelay();

    initializeMockData();
    return _mockTeams[teamId];
  }

  /// 创建团队
  static Future<String?> createTeam({
    required String teamId,
    required String teamPassword,
    required String teamLeader,
    String? teamName,
    String? description,
    String? teamType,
  }) async {
    AppConfig.debugLog('模拟创建团队: $teamId, 领导者: $teamLeader');
    await AppConfig.mockLongDelay();

    initializeMockData();

    // 生成新的团队ID
    final newTeamId = _nextTeamId.toString();
    _nextTeamId++;

    // 创建团队数据
    final teamData = {
      'teamUID': int.parse(newTeamId),
      'name': teamName ?? '新团队 $newTeamId',
      'description': description ?? '这是一个新创建的团队',
      'teamType': teamType ?? 'general',
      'status': 'active',
      'leader': teamLeader,
      'members': [teamLeader], // 创建者自动成为成员
      'tags': <String>[],
      'password': teamPassword,
      'createdAt': DateTime.now().toIso8601String(),
    };

    // 存储团队数据
    _mockTeams[newTeamId] = teamData;

    // 将团队添加到创建者的团队列表
    _userTeams[teamLeader] ??= [];
    _userTeams[teamLeader]!.add(newTeamId);

    AppConfig.debugLog('模拟团队创建成功: $newTeamId');
    return newTeamId;
  }

  /// 更新团队
  static Future<bool> updateTeam({
    required String teamId,
    required Map<String, dynamic> changedThings,
  }) async {
    AppConfig.debugLog('模拟更新团队: $teamId');
    await AppConfig.mockDelay();

    initializeMockData();

    if (_mockTeams.containsKey(teamId)) {
      // 更新团队信息
      _mockTeams[teamId]!.addAll(changedThings);
      _mockTeams[teamId]!['updatedAt'] = DateTime.now().toIso8601String();
      AppConfig.debugLog('团队更新成功: $teamId');
      return true;
    }

    AppConfig.debugLog('团队不存在: $teamId');
    return false;
  }

  /// 删除团队
  static Future<bool> deleteTeam(String teamId) async {
    AppConfig.debugLog('模拟删除团队: $teamId');
    await AppConfig.mockDelay();

    initializeMockData();

    if (_mockTeams.containsKey(teamId)) {
      final teamData = _mockTeams[teamId]!;
      final members = teamData['members'] as List<String>;

      // 从所有成员的团队列表中移除
      for (final memberId in members) {
        _userTeams[memberId]?.remove(teamId);
      }

      // 删除团队
      _mockTeams.remove(teamId);
      AppConfig.debugLog('团队删除成功: $teamId');
      return true;
    }

    AppConfig.debugLog('团队不存在: $teamId');
    return false;
  }

  /// 更新团队密码
  static Future<bool> updateTeamPassword({
    required String teamId,
    required String newPassword,
  }) async {
    AppConfig.debugLog('模拟更新团队密码: $teamId');
    await AppConfig.mockDelay();

    initializeMockData();

    if (_mockTeams.containsKey(teamId)) {
      _mockTeams[teamId]!['password'] = newPassword;
      _mockTeams[teamId]!['passwordUpdatedAt'] =
          DateTime.now().toIso8601String();
      AppConfig.debugLog('团队密码更新成功: $teamId');
      return true;
    }

    AppConfig.debugLog('团队不存在: $teamId');
    return false;
  }

  /// 加入团队
  static Future<bool> joinTeam(String teamId, String userId) async {
    AppConfig.debugLog('模拟用户 $userId 加入团队: $teamId');
    await AppConfig.mockDelay();

    initializeMockData();

    if (_mockTeams.containsKey(teamId)) {
      final teamData = _mockTeams[teamId]!;
      final members = List<String>.from(teamData['members'] as List);

      if (!members.contains(userId)) {
        // 添加用户到团队
        members.add(userId);
        _mockTeams[teamId]!['members'] = members;

        // 添加团队到用户的团队列表
        _userTeams[userId] ??= [];
        if (!_userTeams[userId]!.contains(teamId)) {
          _userTeams[userId]!.add(teamId);
        }

        AppConfig.debugLog('用户成功加入团队: $userId -> $teamId');
        return true;
      } else {
        AppConfig.debugLog('用户已经是团队成员: $userId');
        return true;
      }
    }

    AppConfig.debugLog('团队不存在: $teamId');
    return false;
  }

  /// 离开团队
  static Future<bool> leaveTeam(String teamId, String userId) async {
    AppConfig.debugLog('模拟用户 $userId 离开团队: $teamId');
    await AppConfig.mockDelay();

    initializeMockData();

    if (_mockTeams.containsKey(teamId)) {
      final teamData = _mockTeams[teamId]!;
      final members = List<String>.from(teamData['members'] as List);

      if (members.contains(userId)) {
        // 从团队中移除用户
        members.remove(userId);
        _mockTeams[teamId]!['members'] = members;

        // 从用户的团队列表中移除
        _userTeams[userId]?.remove(teamId);

        AppConfig.debugLog('用户成功离开团队: $userId <- $teamId');
        return true;
      } else {
        AppConfig.debugLog('用户不是团队成员: $userId');
        return false;
      }
    }

    AppConfig.debugLog('团队不存在: $teamId');
    return false;
  }

  /// 获取用户的所有团队
  static Future<List<Map<String, dynamic>>> getUserTeams(String userId) async {
    AppConfig.debugLog('模拟获取用户团队: $userId');
    await AppConfig.mockDelay();

    initializeMockData();

    final userTeamIds = _userTeams[userId] ?? [];
    final teams = <Map<String, dynamic>>[];

    for (final teamId in userTeamIds) {
      if (_mockTeams.containsKey(teamId)) {
        teams.add(Map<String, dynamic>.from(_mockTeams[teamId]!));
      }
    }

    AppConfig.debugLog('用户 $userId 的团队数量: ${teams.length}');
    return teams;
  }

  /// 搜索公开团队
  static Future<List<Map<String, dynamic>>> searchPublicTeams({
    String? keyword,
    int limit = 10,
  }) async {
    AppConfig.debugLog('模拟搜索公开团队: $keyword');
    await AppConfig.mockDelay();

    initializeMockData();

    var teams = _mockTeams.values.toList();

    // 如果有关键词，进行搜索过滤
    if (keyword != null && keyword.isNotEmpty) {
      teams = teams.where((team) {
        final name = team['name']?.toString().toLowerCase() ?? '';
        final description = team['description']?.toString().toLowerCase() ?? '';
        final searchKeyword = keyword.toLowerCase();
        return name.contains(searchKeyword) ||
            description.contains(searchKeyword);
      }).toList();
    }

    // 限制返回数量
    if (teams.length > limit) {
      teams = teams.take(limit).toList();
    }

    AppConfig.debugLog('搜索到 ${teams.length} 个团队');
    return teams.map((team) => Map<String, dynamic>.from(team)).toList();
  }

  /// 获取团队统计信息
  static Future<Map<String, dynamic>> getTeamStatistics(String userId) async {
    AppConfig.debugLog('模拟获取团队统计: $userId');
    await AppConfig.mockDelay();

    initializeMockData();

    final userTeams = await getUserTeams(userId);
    final random = Random();

    return {
      'totalTeams': userTeams.length,
      'activeTeams':
          userTeams.where((team) => team['status'] == 'active').length,
      'completedProjects': random.nextInt(10) + 5,
      'totalMembers': userTeams.fold(
          0, (sum, team) => sum + (team['members'] as List).length),
      'averageTeamSize': userTeams.isEmpty
          ? 0
          : userTeams.fold(
                  0, (sum, team) => sum + (team['members'] as List).length) /
              userTeams.length,
      'leadershipCount':
          userTeams.where((team) => team['leader'] == userId).length,
      'membershipCount':
          userTeams.where((team) => team['leader'] != userId).length,
    };
  }

  /// 清除所有模拟数据（用于测试）
  static void clearMockData() {
    AppConfig.debugLog('清除所有模拟数据');
    _mockTeams.clear();
    _userTeams.clear();
    _nextTeamId = 1000;
  }
}
