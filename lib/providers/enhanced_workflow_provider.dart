import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// 增强版工作流图状态管理
class EnhancedWorkflowProvider with ChangeNotifier {
  List<EnhancedTaskNode> _allTasks = [];
  List<EnhancedTaskNode> _filteredTasks = [];
  Map<String, Offset> _taskPositions = {};

  // 筛选器状态
  Set<EnhancedTaskStatus> _statusFilter = {};
  Set<EnhancedTaskPriority> _priorityFilter = {};

  // Getters
  List<EnhancedTaskNode> get allTasks => _allTasks;
  List<EnhancedTaskNode> get filteredTasks => _filteredTasks;

  int get totalTasksCount => _allTasks.length;
  int get completedTasksCount => _allTasks
      .where((task) => task.status == EnhancedTaskStatus.completed)
      .length;

  /// 初始化团队任务数据
  void initializeTeamTasks(String teamId) {
    _generateMockTasks();
    _applyFilters();
    notifyListeners();
  }

  /// 生成模拟任务数据
  void _generateMockTasks() {
    _allTasks = [
      EnhancedTaskNode(
        id: 'task_1',
        title: '需求分析',
        description: '分析项目需求和功能点，确定系统边界和核心功能',
        status: EnhancedTaskStatus.completed,
        priority: EnhancedTaskPriority.high,
        progress: 100,
        dependencies: [],
      ),
      EnhancedTaskNode(
        id: 'task_2',
        title: '架构设计',
        description: '设计系统架构和技术方案，选择合适的技术栈',
        status: EnhancedTaskStatus.inProgress,
        priority: EnhancedTaskPriority.high,
        progress: 60,
        dependencies: ['task_1'],
      ),
      EnhancedTaskNode(
        id: 'task_3',
        title: '前端开发',
        description: '实现用户界面和交互逻辑，包括响应式设计',
        status: EnhancedTaskStatus.pending,
        priority: EnhancedTaskPriority.medium,
        progress: 0,
        dependencies: ['task_2'],
      ),
      EnhancedTaskNode(
        id: 'task_4',
        title: '后端开发',
        description: '实现服务端逻辑和API接口，包括数据库设计',
        status: EnhancedTaskStatus.pending,
        priority: EnhancedTaskPriority.medium,
        progress: 0,
        dependencies: ['task_2'],
      ),
      EnhancedTaskNode(
        id: 'task_5',
        title: '集成测试',
        description: '进行系统集成测试，确保各模块协调工作',
        status: EnhancedTaskStatus.pending,
        priority: EnhancedTaskPriority.low,
        progress: 0,
        dependencies: ['task_3', 'task_4'],
      ),
      EnhancedTaskNode(
        id: 'task_6',
        title: '性能优化',
        description: '优化系统性能，提升用户体验',
        status: EnhancedTaskStatus.pending,
        priority: EnhancedTaskPriority.medium,
        progress: 0,
        dependencies: ['task_5'],
      ),
    ];

    // 初始化任务位置
    _initializeTaskPositions();
  }

  /// 初始化任务位置
  void _initializeTaskPositions() {
    const double startX = 50;
    const double startY = 100;
    const double spacingX = 250;
    const double spacingY = 150;

    for (int i = 0; i < _allTasks.length; i++) {
      final task = _allTasks[i];
      final row = i ~/ 3;
      final col = i % 3;

      _taskPositions[task.id] = Offset(
        startX + col * spacingX,
        startY + row * spacingY,
      );
    }
  }

  /// 获取任务位置
  Offset getTaskPosition(String taskId) {
    return _taskPositions[taskId] ?? Offset.zero;
  }

  /// 更新任务位置（带边界约束）
  void updateTaskPosition(String taskId, Offset deltaOffset,
      {Size? canvasSize}) {
    final currentPosition = _taskPositions[taskId] ?? Offset.zero;
    Offset newPosition = currentPosition + deltaOffset;

    // 应用边界约束
    if (canvasSize != null) {
      newPosition = _constrainPosition(newPosition, canvasSize);
    }

    _taskPositions[taskId] = newPosition;
    notifyListeners();
  }

  /// 设置任务位置（带边界约束）
  void setTaskPosition(String taskId, Offset position, {Size? canvasSize}) {
    Offset constrainedPosition = position;

    // 应用边界约束
    if (canvasSize != null) {
      constrainedPosition = _constrainPosition(position, canvasSize);
    }

    _taskPositions[taskId] = constrainedPosition;
    notifyListeners();
  }

  /// 约束位置在边界内
  Offset _constrainPosition(Offset position, Size canvasSize) {
    const double taskWidth = 200.0; // 任务卡片宽度
    const double taskHeight = 120.0; // 任务卡片高度
    const double margin = 20.0; // 边距

    final double maxX = canvasSize.width * 2 - taskWidth - margin;
    final double maxY = canvasSize.height * 2 - taskHeight - margin;

    return Offset(
      position.dx.clamp(margin, maxX),
      position.dy.clamp(margin, maxY),
    );
  }

  /// 根据ID获取任务
  EnhancedTaskNode? getTaskById(String taskId) {
    try {
      return _allTasks.firstWhere((task) => task.id == taskId);
    } catch (e) {
      return null;
    }
  }

  /// 添加新任务
  void addTask(EnhancedTaskNode task) {
    _allTasks.add(task);

    // 为新任务分配位置
    final newPosition = _calculateNewTaskPosition();
    _taskPositions[task.id] = newPosition;

    _applyFilters();
    notifyListeners();
  }

  /// 计算新任务的位置
  Offset _calculateNewTaskPosition() {
    if (_taskPositions.isEmpty) {
      return const Offset(50, 100);
    }

    // 找到最右下角的位置
    double maxX = 0;
    double maxY = 0;

    for (final position in _taskPositions.values) {
      if (position.dx > maxX) maxX = position.dx;
      if (position.dy > maxY) maxY = position.dy;
    }

    return Offset(maxX + 250, maxY);
  }

  /// 更新任务
  void updateTask(EnhancedTaskNode updatedTask) {
    final index = _allTasks.indexWhere((task) => task.id == updatedTask.id);
    if (index != -1) {
      _allTasks[index] = updatedTask;
      _applyFilters();
      notifyListeners();
    }
  }

  /// 删除任务
  void removeTask(String taskId) {
    _allTasks.removeWhere((task) => task.id == taskId);
    _taskPositions.remove(taskId);

    // 移除对此任务的依赖
    for (final task in _allTasks) {
      task.dependencies.remove(taskId);
    }

    _applyFilters();
    notifyListeners();
  }

  /// 添加任务依赖关系
  void addTaskDependency(String fromTaskId, String toTaskId) {
    final toTask = getTaskById(toTaskId);
    if (toTask != null && !toTask.dependencies.contains(fromTaskId)) {
      toTask.dependencies.add(fromTaskId);
      notifyListeners();
    }
  }

  /// 移除任务依赖关系
  void removeTaskDependency(String fromTaskId, String toTaskId) {
    final toTask = getTaskById(toTaskId);
    if (toTask != null) {
      toTask.dependencies.remove(fromTaskId);
      notifyListeners();
    }
  }

  /// 设置状态筛选
  void setStatusFilter(Set<EnhancedTaskStatus> filter) {
    _statusFilter = filter;
    _applyFilters();
    notifyListeners();
  }

  /// 设置优先级筛选
  void setPriorityFilter(Set<EnhancedTaskPriority> filter) {
    _priorityFilter = filter;
    _applyFilters();
    notifyListeners();
  }

  /// 清除所有筛选
  void clearFilters() {
    _statusFilter.clear();
    _priorityFilter.clear();
    _applyFilters();
    notifyListeners();
  }

  /// 自动生成工作流连线模板
  void generateWorkflowTemplate(String templateType) {
    switch (templateType) {
      case 'linear':
        _generateLinearTemplate();
        break;
      case 'parallel':
        _generateParallelTemplate();
        break;
      case 'complex':
        _generateComplexTemplate();
        break;
      default:
        _generateLinearTemplate();
    }
    notifyListeners();
  }

  /// 生成线性工作流模板
  void _generateLinearTemplate() {
    // 清除现有依赖
    for (final task in _allTasks) {
      task.dependencies.clear();
    }

    // 按照任务顺序创建线性依赖
    for (int i = 1; i < _allTasks.length; i++) {
      _allTasks[i].dependencies.add(_allTasks[i - 1].id);
    }
  }

  /// 生成并行工作流模板
  void _generateParallelTemplate() {
    // 清除现有依赖
    for (final task in _allTasks) {
      task.dependencies.clear();
    }

    if (_allTasks.length >= 5) {
      // 需求分析 -> 架构设计
      _allTasks[1].dependencies.add(_allTasks[0].id);

      // 架构设计 -> 前端开发和后端开发（并行）
      _allTasks[2].dependencies.add(_allTasks[1].id);
      _allTasks[3].dependencies.add(_allTasks[1].id);

      // 前端和后端 -> 集成测试
      if (_allTasks.length > 4) {
        _allTasks[4].dependencies.addAll([_allTasks[2].id, _allTasks[3].id]);
      }

      // 集成测试 -> 性能优化
      if (_allTasks.length > 5) {
        _allTasks[5].dependencies.add(_allTasks[4].id);
      }
    }
  }

  /// 生成复杂工作流模板
  void _generateComplexTemplate() {
    // 清除现有依赖
    for (final task in _allTasks) {
      task.dependencies.clear();
    }

    if (_allTasks.length >= 6) {
      // 复杂的依赖关系示例
      _allTasks[1].dependencies.add(_allTasks[0].id); // 架构设计依赖需求分析
      _allTasks[2]
          .dependencies
          .addAll([_allTasks[0].id, _allTasks[1].id]); // 前端开发依赖需求分析和架构设计
      _allTasks[3].dependencies.add(_allTasks[1].id); // 后端开发依赖架构设计
      _allTasks[4]
          .dependencies
          .addAll([_allTasks[2].id, _allTasks[3].id]); // 集成测试依赖前后端开发
      _allTasks[5].dependencies.addAll(
          [_allTasks[2].id, _allTasks[3].id, _allTasks[4].id]); // 性能优化依赖多个任务
    }
  }

  /// 清除所有连线
  void clearAllConnections() {
    for (final task in _allTasks) {
      task.dependencies.clear();
    }
    notifyListeners();
  }

  /// 应用筛选器
  void _applyFilters() {
    _filteredTasks = _allTasks.where((task) {
      // 状态筛选
      if (_statusFilter.isNotEmpty && !_statusFilter.contains(task.status)) {
        return false;
      }

      // 优先级筛选
      if (_priorityFilter.isNotEmpty &&
          !_priorityFilter.contains(task.priority)) {
        return false;
      }

      return true;
    }).toList();
  }

  /// 获取任务统计信息
  Map<String, int> getTaskStatistics() {
    final stats = <String, int>{};

    for (final status in EnhancedTaskStatus.values) {
      stats[status.name] =
          _allTasks.where((task) => task.status == status).length;
    }

    return stats;
  }

  /// 计算项目完成百分比
  double getProjectCompletionPercentage() {
    if (_allTasks.isEmpty) return 0.0;

    final totalProgress =
        _allTasks.fold<int>(0, (sum, task) => sum + task.progress);
    return totalProgress / (_allTasks.length * 100);
  }

  /// 获取关键路径（最长依赖链）
  List<String> getCriticalPath() {
    final visited = <String>{};
    String? longestPath;
    int maxLength = 0;

    void dfs(String taskId, List<String> currentPath) {
      if (visited.contains(taskId)) return;

      visited.add(taskId);
      currentPath.add(taskId);

      final task = getTaskById(taskId);
      if (task != null) {
        bool hasUnvisitedDependents = false;

        // 找到依赖此任务的其他任务
        for (final otherTask in _allTasks) {
          if (otherTask.dependencies.contains(taskId) &&
              !visited.contains(otherTask.id)) {
            hasUnvisitedDependents = true;
            dfs(otherTask.id, List.from(currentPath));
          }
        }

        // 如果没有未访问的依赖任务，检查路径长度
        if (!hasUnvisitedDependents && currentPath.length > maxLength) {
          maxLength = currentPath.length;
          longestPath = currentPath.join(' -> ');
        }
      }

      visited.remove(taskId);
    }

    // 从没有前置依赖的任务开始
    for (final task in _allTasks) {
      if (task.dependencies.isEmpty) {
        dfs(task.id, []);
      }
    }

    return longestPath?.split(' -> ') ?? [];
  }

  /// 导出为JSON
  Map<String, dynamic> exportToJson() {
    return {
      'tasks': _allTasks.map((task) => task.toJson()).toList(),
      'positions': _taskPositions.map((key, value) => MapEntry(key, {
            'x': value.dx,
            'y': value.dy,
          })),
      'metadata': {
        'totalTasks': totalTasksCount,
        'completedTasks': completedTasksCount,
        'completionPercentage': getProjectCompletionPercentage(),
        'exportedAt': DateTime.now().toIso8601String(),
      },
    };
  }

  /// 从JSON导入
  void importFromJson(Map<String, dynamic> json) {
    try {
      final tasksList = json['tasks'] as List<dynamic>?;
      if (tasksList != null) {
        _allTasks = tasksList
            .map((taskJson) => EnhancedTaskNode.fromJson(taskJson))
            .toList();
      }

      final positionsMap = json['positions'] as Map<String, dynamic>?;
      if (positionsMap != null) {
        _taskPositions = positionsMap.map((key, value) => MapEntry(
              key,
              Offset(
                (value['x'] as num).toDouble(),
                (value['y'] as num).toDouble(),
              ),
            ));
      }

      _applyFilters();
      notifyListeners();
    } catch (e) {
      print('导入JSON数据失败: $e');
    }
  }
}

/// 增强版任务节点数据模型
class EnhancedTaskNode {
  final String id;
  final String title;
  final String description;
  final EnhancedTaskStatus status;
  final EnhancedTaskPriority priority;
  final int progress;
  final List<String> dependencies;

  EnhancedTaskNode({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.priority,
    required this.progress,
    required this.dependencies,
  });

  EnhancedTaskNode copyWith({
    String? id,
    String? title,
    String? description,
    EnhancedTaskStatus? status,
    EnhancedTaskPriority? priority,
    int? progress,
    List<String>? dependencies,
  }) {
    return EnhancedTaskNode(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      progress: progress ?? this.progress,
      dependencies: dependencies ?? this.dependencies,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'status': status.index,
      'priority': priority.index,
      'progress': progress,
      'dependencies': dependencies,
    };
  }

  factory EnhancedTaskNode.fromJson(Map<String, dynamic> json) {
    return EnhancedTaskNode(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      status: EnhancedTaskStatus.values[json['status'] ?? 0],
      priority: EnhancedTaskPriority.values[json['priority'] ?? 1],
      progress: json['progress'] ?? 0,
      dependencies: List<String>.from(json['dependencies'] ?? []),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is EnhancedTaskNode && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// 任务状态枚举
enum EnhancedTaskStatus {
  pending, // 待开始
  inProgress, // 进行中
  completed, // 已完成
  blocked, // 受阻
}

/// 任务优先级枚举
enum EnhancedTaskPriority {
  low, // 低优先级
  medium, // 中优先级
  high, // 高优先级
}
