```instructions
# SilentFlow AI Development Guide

## 项目概览
SilentFlow是一个基于Flutter的团队协作管理系统，采用**团队池架构**和**工作流可视化**，核心特性包括角色权限管理、智能任务分配和实时工作流图表。

## 架构模式

### 状态管理 - Provider模式
```dart
// 核心Provider: AppProvider, TeamPoolProvider
// 使用Consumer<T>监听状态变化，避免不必要的rebuild
Consumer<TeamPoolProvider>(
  builder: (context, provider, child) => Widget
)
```

### 三层架构
- **Screens/**: UI层，StatefulWidget为主，处理用户交互
- **Services/**: 业务逻辑层，TaskService, TeamService等
- **Providers/**: 状态管理层，连接UI和Services
- **Widgets/**: 可复用组件层，按功能模块组织

## 关键开发模式

### 1. 任务管理层次结构
```dart
// TaskLevel: project -> task -> taskPoint
// 父子任务关系: parentTaskId连接层级
// 状态传播: 子任务状态影响父任务进度
```

### 2. 团队池生命周期
```dart
// 团队创建 -> 成员邀请 -> 任务分配 -> 协作执行 -> 项目完成
// Provider监听: 团队状态变化自动刷新相关UI
```

### 3. 异步数据加载模式
```dart
// 标准模式: setState loading -> try/catch service call -> setState result
// 错误处理: ScaffoldMessenger显示用户友好错误信息
// 数据同步: Provider变化触发子组件自动刷新
```

## 组件化重构模式（已实施）

### 大文件拆分策略
超过300行的Screen文件应拆分为专用组件：

### TaskDetailScreen重构示例
```dart
// 主文件: task_detail_screen.dart (300行) - 状态管理和事件处理
// 组件拆分:
lib/widgets/task_detail/
├── task_info_card.dart         // 任务基本信息卡片
├── task_completion_stats.dart  // 完成统计图表
└── child_tasks_list.dart       // 子任务列表
```

### TaskBoardScreen重构示例
```dart
// 主文件: task_board_screen.dart (600行) - 标签页和状态管理
// 组件拆分:
lib/widgets/task_board/
├── task_search_filter_bar.dart // 搜索筛选栏
├── project_card_widget.dart    // 项目卡片
└── task_card_widget.dart       // 任务卡片
```

### 组件设计原则
1. **单一职责**: 每个组件只负责一个UI功能
2. **Props传递**: 通过构造函数传递数据和回调
3. **状态外提**: 组件本身无状态，状态由父组件管理
4. **样式一致**: 使用统一的颜色和圆角系统

## 文件组织规范

### 新增组件结构
```dart
lib/widgets/
├── task_detail/           // 任务详情相关组件
├── task_board/           // 任务面板相关组件
├── task_creation_dialog.dart // 通用对话框
└── common/               // 通用组件（建议创建）
```

### 组件命名规范
- Widget类名: `ComponentNameWidget` (如 `TaskCardWidget`)
- 文件名: `component_name_widget.dart` (蛇形命名)
- 回调参数: `onAction`, `onTap`, `onMenuAction`

## 核心业务逻辑

### 任务工作流
1. 任务创建 -> `TaskCreationDialog` + `TaskService.createTask()`
2. 状态更新 -> `TaskService.updateTaskStatus()` + Provider通知
3. 层级管理 -> 项目包含任务，任务包含任务点
4. **新增**: 菜单操作统一通过 `onMenuAction(task, action)` 处理

### 团队协作模式
1. 队长-队员角色权限区分
2. 邀请码机制加入团队
3. 实时任务分配和认领
4. **新增**: 支持任务认领 (`assign` action)

### 数据持久化
- SharedPreferences存储用户状态和设置
- 本地JSON文件模拟数据库（生产环境需替换为真实API）

## UI系统规范

### 颜色系统
```dart
// 状态颜色
pending: Color(0xFFED8936)    // 橙色
inProgress: Color(0xFF4299E1) // 蓝色
completed: Color(0xFF48BB78)  // 绿色
blocked: Color(0xFFE53E3E)    // 红色

// 优先级颜色
low: Colors.green
medium: Colors.orange
high: Colors.red
urgent: Colors.purple
```

### 圆角系统
- 卡片: `BorderRadius.circular(12)`
- 芯片: `BorderRadius.circular(8)` 或 `BorderRadius.circular(12)`
- 按钮: `BorderRadius.circular(25)` (搜索框等)

### 间距系统
- 页面边距: `EdgeInsets.all(16)`
- 组件间距: `SizedBox(height: 12)` 或 `16`
- 内容边距: `EdgeInsets.symmetric(horizontal: 16, vertical: 8)`

## 常见问题模式

### UI响应性
- 长列表使用ListView.builder避免性能问题
- **重构后**: 组件化提升渲染性能
- 频繁rebuild使用Consumer包装最小范围

### 状态同步
- 团队变化后延迟200ms刷新任务避免频繁调用
- 使用mounted检查避免已销毁Widget的setState
- **新增**: 组件回调确保状态同步

### 空安全处理
```dart
// 标准模式
if (task.description?.isNotEmpty == true) {
  Text(task.description!)
}
```

## 开发工作流

### 添加新功能
1. 确定组件层级（Screen/Widget/Component）
2. 设计数据流（Props down, Events up）
3. 实现组件逻辑
4. 集成到父组件
5. 测试交互流程

### 重构现有代码
1. 识别可复用的UI模块
2. 提取为独立组件文件
3. 统一Props接口
4. 移除冗余代码
5. 更新import语句

### 性能优化要点
- 避免在build()中创建新对象
- 使用const构造函数减少重建
- **重构后**: 组件拆分减少重建范围
- 图片资源压缩和懒加载
```
