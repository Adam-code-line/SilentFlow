// 团队相关的API服务
// 连接后端团队管理接口，支持开发模式模拟
import 'api_service.dart';
import 'mock_team_service.dart';
import '../config/app_config.dart';
import 'package:dio/dio.dart';

class TeamService {
  // 获取团队信息 - GET /team/get/:teamuid
  static Future<Map<String, dynamic>?> getTeamInfo(String teamId) async {
    // 检查是否使用模拟数据
    if (AppConfig.isDevelopmentMode && AppConfig.useMockData) {
      AppConfig.debugLog('使用模拟数据获取团队信息: $teamId');
      return await MockTeamService.getTeamInfo(teamId);
    }

    try {
      final response = await ApiService.get('/team/get/$teamId');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['team'] != null) {
          return data['team'];
        }
      }
      return null;
    } on DioException catch (e) {
      print('获取团队信息失败: ${e.message}');
      return null;
    } catch (e) {
      print('获取团队信息异常: $e');
      return null;
    }
  }

  // 创建团队 - POST /team/create
  static Future<String?> createTeam({
    required String teamId,
    required String teamPassword,
    required String teamLeader,
    String? teamName,
    String? description,
    String? teamType,
  }) async {
    // 检查是否使用模拟数据
    if (AppConfig.isDevelopmentMode && AppConfig.useMockData) {
      AppConfig.debugLog('使用模拟数据创建团队: $teamId');
      return await MockTeamService.createTeam(
        teamId: teamId,
        teamPassword: teamPassword,
        teamLeader: teamLeader,
        teamName: teamName,
        description: description,
        teamType: teamType,
      );
    }

    try {
      print('TeamService.createTeam 开始调用...');
      print(
          '参数: teamId=$teamId, teamPassword=$teamPassword, teamLeader=$teamLeader');

      // 修复类型转换问题：teamLeader可能是字符串类型，需要特殊处理
      int teamLeaderInt;
      try {
        teamLeaderInt = int.parse(teamLeader);
      } catch (e) {
        print('teamLeader不是数字格式，使用哈希值: $teamLeader');
        teamLeaderInt = teamLeader.hashCode.abs();
        print('转换后的teamLeader: $teamLeaderInt');
      }

      final requestData = {
        'teamUID': int.parse(teamId),
        'teamPassword': int.parse(teamPassword),
        'teamLeader': teamLeaderInt,
      };
      print('请求数据: $requestData');

      final response = await ApiService.post('/team/create', data: requestData);
      print('收到响应: ${response.statusCode}');
      print('响应数据: ${response.data}');

      if (response.statusCode == 200) {
        final data = response.data;
        // 检查响应格式，支持多种可能的响应结构
        if (data is Map<String, dynamic>) {
          // 如果没有错误或错误为空
          if ((data['error'] == null || data['error'].toString().isEmpty)) {
            // 尝试获取teamUID，可能在不同的字段中
            String? returnedTeamId;
            if (data.containsKey('teamUID')) {
              returnedTeamId = data['teamUID'].toString();
            } else if (data.containsKey('teamId')) {
              returnedTeamId = data['teamId'].toString();
            } else if (data.containsKey('id')) {
              returnedTeamId = data['id'].toString();
            } else {
              // 如果没有返回ID，使用原始的teamId
              returnedTeamId = teamId;
            }

            print('团队创建成功，返回teamUID: $returnedTeamId');
            return returnedTeamId;
          } else {
            print('创建团队失败: ${data['message'] ?? data['error']}');
          }
        } else {
          // 如果响应不是Map格式，但状态码为200，认为创建成功
          print('团队创建成功，使用原始teamId: $teamId');
          return teamId;
        }
      } else {
        print('创建团队失败，状态码: ${response.statusCode}');
      }
      return null;
    } on DioException catch (e) {
      print('创建团队Dio异常: ${e.message}');
      print('错误类型: ${e.type}');
      if (e.response != null) {
        print('错误状态码: ${e.response?.statusCode}');
        print('错误响应: ${e.response?.data}');
      }
      return null;
    } catch (e) {
      print('创建团队异常: $e');
      print('异常堆栈: ${StackTrace.current}');
      return null;
    }
  }

  // 更新团队 - POST /team/updata
  static Future<bool> updateTeam({
    required String teamId,
    required Map<String, dynamic> changedThings,
  }) async {
    // 检查是否使用模拟数据
    if (AppConfig.isDevelopmentMode && AppConfig.useMockData) {
      AppConfig.debugLog('使用模拟数据更新团队: $teamId');
      return await MockTeamService.updateTeam(
        teamId: teamId,
        changedThings: changedThings,
      );
    }

    try {
      final response = await ApiService.post('/team/updata', data: {
        'teamUID': int.parse(teamId),
        'ChangedThings': changedThings, // 根据API文档的命名
      });

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['error'] == null || data['error'].isEmpty) {
          return true;
        } else {
          print('更新团队失败: ${data['message'] ?? data['error']}');
        }
      }
      return false;
    } on DioException catch (e) {
      print('更新团队失败: ${e.message}');
      return false;
    } catch (e) {
      print('更新团队异常: $e');
      return false;
    }
  }

  // 删除团队 - POST /team/delete
  static Future<bool> deleteTeam(String teamId) async {
    // 检查是否使用模拟数据
    if (AppConfig.isDevelopmentMode && AppConfig.useMockData) {
      AppConfig.debugLog('使用模拟数据删除团队: $teamId');
      return await MockTeamService.deleteTeam(teamId);
    }

    try {
      final response = await ApiService.post('/team/delete', data: {
        'teamUID': int.parse(teamId),
      });

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['error'] == null || data['error'].isEmpty) {
          return true;
        } else {
          print('删除团队失败: ${data['message'] ?? data['error']}');
        }
      }
      return false;
    } on DioException catch (e) {
      print('删除团队失败: ${e.message}');
      return false;
    } catch (e) {
      print('删除团队异常: $e');
      return false;
    }
  }

  // 更新团队密码 - POST /team/updatapassword
  static Future<bool> updateTeamPassword({
    required String teamId,
    required String newPassword,
  }) async {
    // 检查是否使用模拟数据
    if (AppConfig.isDevelopmentMode && AppConfig.useMockData) {
      AppConfig.debugLog('使用模拟数据更新团队密码: $teamId');
      return await MockTeamService.updateTeamPassword(
        teamId: teamId,
        newPassword: newPassword,
      );
    }

    try {
      final response = await ApiService.post('/team/updatapassword', data: {
        'teamUID': int.parse(teamId),
        'teamPassword': int.parse(newPassword), // API文档显示是数字类型
      });

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['error'] == null || data['error'].isEmpty) {
          return true;
        } else {
          print('更新团队密码失败: ${data['message'] ?? data['error']}');
        }
      }
      return false;
    } on DioException catch (e) {
      print('更新团队密码失败: ${e.message}');
      return false;
    } catch (e) {
      print('更新团队密码异常: $e');
      return false;
    }
  }

  // 新增方法：加入团队
  static Future<bool> joinTeam(String teamId, String userId) async {
    // 检查是否使用模拟数据
    if (AppConfig.isDevelopmentMode && AppConfig.useMockData) {
      AppConfig.debugLog('使用模拟数据加入团队: $userId -> $teamId');
      return await MockTeamService.joinTeam(teamId, userId);
    }

    // TODO: 实现真实的API调用
    print('警告：真实的加入团队API还未实现');
    return false;
  }

  // 新增方法：离开团队
  static Future<bool> leaveTeam(String teamId, String userId) async {
    // 检查是否使用模拟数据
    if (AppConfig.isDevelopmentMode && AppConfig.useMockData) {
      AppConfig.debugLog('使用模拟数据离开团队: $userId <- $teamId');
      return await MockTeamService.leaveTeam(teamId, userId);
    }

    // TODO: 实现真实的API调用
    print('警告：真实的离开团队API还未实现');
    return false;
  }

  // 新增方法：获取用户的团队列表
  static Future<List<Map<String, dynamic>>> getUserTeams(String userId) async {
    // 检查是否使用模拟数据
    if (AppConfig.isDevelopmentMode && AppConfig.useMockData) {
      AppConfig.debugLog('使用模拟数据获取用户团队: $userId');
      return await MockTeamService.getUserTeams(userId);
    }

    // TODO: 实现真实的API调用
    print('警告：真实的获取用户团队API还未实现');
    return [];
  }

  // 新增方法：搜索公开团队
  static Future<List<Map<String, dynamic>>> searchPublicTeams({
    String? keyword,
    int limit = 10,
  }) async {
    // 检查是否使用模拟数据
    if (AppConfig.isDevelopmentMode && AppConfig.useMockData) {
      AppConfig.debugLog('使用模拟数据搜索团队: $keyword');
      return await MockTeamService.searchPublicTeams(
        keyword: keyword,
        limit: limit,
      );
    }

    // TODO: 实现真实的API调用
    print('警告：真实的搜索团队API还未实现');
    return [];
  }

  // 新增方法：获取团队统计信息
  static Future<Map<String, dynamic>> getTeamStatistics(String userId) async {
    // 检查是否使用模拟数据
    if (AppConfig.isDevelopmentMode && AppConfig.useMockData) {
      AppConfig.debugLog('使用模拟数据获取团队统计: $userId');
      return await MockTeamService.getTeamStatistics(userId);
    }

    // TODO: 实现真实的API调用
    print('警告：真实的团队统计API还未实现');
    return {
      'totalTeams': 0,
      'activeTeams': 0,
      'completedProjects': 0,
      'totalMembers': 0,
      'averageTeamSize': 0.0,
      'leadershipCount': 0,
      'membershipCount': 0,
    };
  }
}
