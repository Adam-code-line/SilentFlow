// widgets/widget_manager.dart - 组件管理器
import 'package:flutter/material.dart';

/// 组件管理器 - 提供组件注册、查找、统计等功能
class WidgetManager {
  static final WidgetManager _instance = WidgetManager._internal();
  factory WidgetManager() => _instance;
  WidgetManager._internal();

  // 组件注册表
  final Map<String, Map<String, dynamic>> _registry = {};

  /// 注册组件
  void registerWidget({
    required String category,
    required String name,
    required Type widgetType,
    String? description,
    List<String>? tags,
  }) {
    _registry[category] ??= {};
    _registry[category]![name] = {
      'type': widgetType,
      'description': description,
      'tags': tags ?? [],
      'registeredAt': DateTime.now(),
    };
  }

  /// 获取所有注册的组件分类
  List<String> getCategories() => _registry.keys.toList();

  /// 获取指定分类下的所有组件
  Map<String, dynamic>? getCategoryWidgets(String category) {
    return _registry[category];
  }

  /// 搜索组件
  Map<String, Map<String, dynamic>> searchWidgets(String query) {
    final results = <String, Map<String, dynamic>>{};

    _registry.forEach((category, widgets) {
      widgets.forEach((name, info) {
        if (name.toLowerCase().contains(query.toLowerCase()) ||
            (info['description']?.toLowerCase().contains(query.toLowerCase()) ??
                false) ||
            (info['tags'] as List).any(
                (tag) => tag.toLowerCase().contains(query.toLowerCase()))) {
          results['$category.$name'] = info;
        }
      });
    });

    return results;
  }

  /// 获取组件统计信息
  Map<String, int> getStats() {
    final stats = <String, int>{};
    int totalWidgets = 0;

    _registry.forEach((category, widgets) {
      stats[category] = widgets.length;
      totalWidgets += widgets.length;
    });

    stats['total'] = totalWidgets;
    return stats;
  }

  /// 初始化 - 注册所有组件
  void initializeRegistry() {
    // 通用组件
    registerWidget(
      category: 'common',
      name: 'SilentCard',
      widgetType: Widget,
      description: '通用卡片组件，支持点击和自定义样式',
      tags: ['card', 'common', 'reusable'],
    );

    // 任务相关组件
    registerWidget(
      category: 'task',
      name: 'TaskCard',
      widgetType: Widget,
      description: '任务卡片组件，显示任务基本信息',
      tags: ['task', 'card', 'display'],
    );

    registerWidget(
      category: 'task',
      name: 'TaskInfoCard',
      widgetType: Widget,
      description: '任务详情信息卡片',
      tags: ['task', 'detail', 'info'],
    );

    registerWidget(
      category: 'task',
      name: 'TaskCompletionStats',
      widgetType: Widget,
      description: '任务完成统计图表',
      tags: ['task', 'stats', 'chart'],
    );

    registerWidget(
      category: 'task',
      name: 'ChildTasksList',
      widgetType: Widget,
      description: '子任务列表组件',
      tags: ['task', 'list', 'children'],
    );

    // 团队相关组件
    registerWidget(
      category: 'team',
      name: 'TeamCard',
      widgetType: Widget,
      description: '团队卡片组件',
      tags: ['team', 'card', 'display'],
    );

    registerWidget(
      category: 'team',
      name: 'TeamStatsCard',
      widgetType: Widget,
      description: '团队统计卡片',
      tags: ['team', 'stats', 'card'],
    );

    // 对话框组件
    registerWidget(
      category: 'dialogs',
      name: 'TaskCreationDialog',
      widgetType: Widget,
      description: '任务创建对话框',
      tags: ['dialog', 'task', 'creation'],
    );

    registerWidget(
      category: 'dialogs',
      name: 'TeamCreationDialog',
      widgetType: Widget,
      description: '团队创建对话框',
      tags: ['dialog', 'team', 'creation'],
    );
  }

  /// 打印组件清单（开发调试用）
  void printInventory() {
    print('========== Widget Inventory ==========');
    final stats = getStats();
    print('Total Widgets: ${stats['total']}');
    print('');

    _registry.forEach((category, widgets) {
      print('📁 $category (${widgets.length} widgets)');
      widgets.forEach((name, info) {
        print('  └─ $name: ${info['description'] ?? 'No description'}');
        if ((info['tags'] as List).isNotEmpty) {
          print('     Tags: ${(info['tags'] as List).join(', ')}');
        }
      });
      print('');
    });
  }
}

/// 组件管理器初始化函数
/// 在app启动时调用
void initializeWidgetManager() {
  final manager = WidgetManager();
  manager.initializeRegistry();

  // 开发环境下打印组件清单
  if (const bool.fromEnvironment('dart.vm.product') == false) {
    manager.printInventory();
  }
}
