# 静默协作 (SilentFlow)

> 🤝 一个专注于团队高效协作的智能管理系统  
> 通过**静默协作理念**和**智能评分机制**，实现低干扰、高效率的团队协作体验

[![Flutter](https://img.shields.io/badge/Flutter-3.8.1-blue.svg)](https://flutter.dev/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Build Status](https://img.shields.io/badge/Build-Passing-brightgreen.svg)]()

## 📖 项目简介

**静默协作**是一个基于Flutter开发的现代化团队协作管理系统，通过创新的**默契值算法**和**个人贡献值评分**，为团队提供公平、透明、高效的协作环境。系统支持任务管理、子任务分解、实时协作统计和智能评分，特别适合需要精细化管理和量化评估的团队项目。

### ✨ 核心特性

🎯 **静默协作理念**
- 无需频繁沟通，通过系统同步关键信息
- 低成本协作，减少会议和消息成本  
- 智能任务分配和自动匹配

📊 **智能评分系统**
- **个人贡献值计算** - 多维度任务完成质量评估
- **团队默契度评估** - 协作频率和配合效率分析
- **动态奖惩机制** - 基于时间和质量的自动调整

🧩 **完整任务管理**
- 任务创建、分配和状态跟踪
- 子任务系统支持复杂任务分解
- 任务依赖关系和关键节点管理

🤝 **协作池管理**
- 支持公开池和私有池
- 匿名协作模式支持
- 实时协作进度跟踪

📱 **现代化UI/UX**
- Material Design 3设计规范
- 响应式布局适配多设备
- 极简设计理念，专注核心功能

## 🏗️ 项目架构

### 📁 目录结构
```
lib/
├── config/                    # 配置文件
│   └── app_config.dart
├── models/                    # 数据模型
│   ├── user_model.dart           # 用户模型和统计信息
│   ├── task_model.dart           # 任务模型和奖励系统
│   ├── subtask_model.dart        # 子任务模型和依赖管理
│   └── collaboration_pool_model.dart # 协作池模型和团队统计
├── services/                  # 服务层（API接口和业务逻辑）
│   ├── scoring_service.dart          # 核心评分算法引擎
│   ├── collaboration_scoring_manager.dart # 协作评分管理器
│   ├── task_service.dart             # 任务管理服务
│   ├── collaboration_pool_service.dart # 协作池管理服务
│   ├── user_service.dart            # 用户管理服务
│   ├── team_service.dart            # 团队管理服务
│   ├── item_service.dart            # 后端API接口服务
│   └── api_service.dart             # 基础API服务
├── providers/                 # 状态管理
│   ├── app_provider.dart
│   └── collaboration_pool_provider.dart
├── screens/                   # 页面
│   ├── auth/                     # 认证相关
│   │   └── login_screen.dart
│   ├── home/                     # 主页
│   │   └── home_screen.dart
│   ├── collaboration/            # 协作池管理
│   │   └── collaboration_pool_screen.dart
│   ├── tasks/                    # 任务管理
│   │   └── task_board_screen.dart
│   ├── profile/                  # 个人资料
│   │   └── profile_screen.dart
│   └── main_tab_screen.dart
├── widgets/                   # 通用组件
│   └── common_widgets.dart
├── utils/                     # 工具类和示例
│   ├── silent_collaboration_example.dart # 系统集成示例
│   ├── scoring_example.dart             # 评分系统使用示例
│   └── app_utils.dart
└── main.dart                  # 应用入口
```

### 🔧 技术栈

**前端框架**
- **Flutter 3.8.1** - 跨平台UI框架
- **Material Design 3** - 现代化UI设计规范
- **Provider** - 简单高效的状态管理

**网络和存储**
- **Dio** - 强大的HTTP客户端
- **JSON序列化** - 数据模型转换
- **SharedPreferences** - 本地数据持久化

**数据可视化**
- **FL Chart** - 协作效率图表和统计展示

**后端集成**
- **Go REST API** - 高性能后端服务
- **实时数据同步** - 团队协作状态实时更新

## 🚀 快速开始

### 环境要求
- Flutter SDK 3.8.1+
- Dart 3.0+
- Android Studio / VS Code
- Git

### 安装步骤

1. **克隆项目**
   ```bash
   git clone <repository-url>
   cd SilentFlow
   ```

2. **安装依赖**
   ```bash
   flutter pub get
   ```

3. **生成代码** (JSON序列化)
   ```bash
   flutter packages pub run build_runner build
   ```

4. **运行应用**
   ```bash
   flutter run
   ```

### 配置后端服务

在 `lib/services/api_service.dart` 中配置后端服务地址:
```dart
static const String baseURL = 'http://localhost:1411';
```

## 💡 核心功能详解

### 1. 🎯 智能评分系统

#### 个人贡献值计算

**计算公式:**
```
贡献值 = (基础分数 × 难度系数 × 质量系数 + 协作奖励) × 时间系数
```

**影响因素:**
- **任务难度**: 优先级和预估时间决定基础难度系数
- **完成质量**: 基于返工次数、协作事件、用户反馈
- **时间管理**: 提前完成获得奖励，延期完成受到惩罚
- **协作参与**: 主动协作和知识分享获得额外加分

#### 团队默契度评估

**评估维度:**
- **协作频率**: 成员间共同完成任务的频率和质量
- **时间协调**: 团队成员任务时间安排的匹配度
- **沟通效率**: 协作过程中的沟通成本和效果
- **任务配合**: 任务分配的合理性和执行的协调性

#### 动态奖惩机制

**时间奖惩:**
- 提前完成: +5%~20% 奖励
- 准时完成: 无额外奖惩
- 延期完成: -10%~50% 惩罚

**质量奖惩:**
- 高质量完成: +10%~30% 奖励
- 标准质量: 无额外奖惩
- 低质量完成: -15%~40% 惩罚

### 2. 📱 页面功能说明

#### 🏠 主页 (HomeScreen)
- **协作默契值显示** - 周/月/总分统计
- **今日关键节点** - 任务完成和开始通知
- **协作池概览** - 参与的活跃协作池
- **效率图谱** - 个人协作标签展示

#### 🤝 协作池页 (CollaborationPoolScreen)
- **我参与的** - 当前活跃的协作池
- **公开池** - 可加入的公开协作池
- **已完成** - 历史完成的协作池
- 支持匿名协作标识

#### 📋 任务面板 (TaskBoardScreen)
- **三个标签页**: 我的任务、可认领任务、全部任务
- **搜索和筛选功能**
- **任务状态管理**（待处理、进行中、已完成、阻塞）
- **子任务管理系统**
- **任务优先级显示**（紧急、高、中、低）
- **障碍标签系统**
- 仅显示关键节点变化

#### 👤 个人资料 (ProfileScreen)
- 用户信息和统计
- 效率标签展示
- 协作历史回顾
- 设置和偏好配置

## 🔧 使用指南

### 快速开始示例

#### 1. 初始化协作池
```dart
CollaborationPool? pool = await CollaborationPoolService.createPool(
  name: '我的协作池',
  description: '团队项目协作',
  isAnonymous: false,
  isPublic: false,
  memberIds: ['user1', 'user2', 'user3'],
);
```

#### 2. 创建任务
```dart
Task? task = await TaskService.createTask(
  teamId: pool.id,
  title: '开发新功能',
  description: '实现用户认证模块',
  estimatedMinutes: 120,
  priority: TaskPriority.high,
  assignedUsers: ['user1', 'user2'],
);
```

#### 3. 执行和完成任务
```dart
// 开始任务
await TaskService.startTask(
  teamId: pool.id,
  taskId: task.id,
  userId: 'user1',
);

// 完成任务并获取评分
Map<String, dynamic>? result = await TaskService.completeTask(
  teamId: pool.id,
  taskId: task.id,
  userId: 'user1',
  completionNote: '功能开发完成',
);
```

#### 4. 查看评分和报告
```dart
// 生成协作池报告
Map<String, dynamic> report = await CollaborationPoolService.generatePoolReport(pool.id);

// 计算个人贡献值
double contribution = ScoringService.calculateTaskContribution(task, 'user1');
```

### 完整演示流程
```dart
Map<String, dynamic> result = await SilentCollaborationExample.demonstrateFullWorkflow();
```

## 🌐 后端接口集成

### API接口

系统与Go后端服务集成，支持以下API接口:

#### 用户管理
```dart
// services/user_service.dart
- POST /auth/login          // 用户登录
- POST /auth/register       // 用户注册  
- GET  /users/{id}          // 获取用户信息
- PUT  /users/{id}          // 更新用户信息
- GET  /users/{id}/stats    // 用户统计信息
```

#### 协作池管理
```dart
// services/collaboration_pool_service.dart
- GET  /users/{id}/pools    // 获取用户的协作池
- GET  /pools/public        // 获取公开协作池
- POST /pools               // 创建协作池
- POST /pools/{id}/join     // 加入协作池
- GET  /pools/{id}/progress // 协作池进度
```

#### 任务管理
```dart
// services/task_service.dart
- GET  /pools/{id}/tasks    // 获取协作池任务
- POST /pools/{id}/tasks    // 创建任务
- PUT  /tasks/{id}          // 更新任务状态
- POST /tasks/{id}/claim    // 认领任务
- POST /tasks/{id}/obstacle // 报告障碍
```

#### 团队管理
```dart
// services/team_service.dart  
- POST /team/create         // 创建团队
- GET  /team/get/:teamuid   // 获取团队信息
- POST /team/join           // 加入团队
```

#### 任务项管理
```dart
// services/item_service.dart
- POST /item/create/:teamuid // 创建任务项
- PUT  /item/update/:teamuid // 更新任务项
- DELETE /item/delete        // 删除任务项
```

## 🎨 设计理念

### 静默协作主题
- **冷静色调** - 以蓝紫色为主色调，营造专注氛围
- **极简设计** - 减少不必要的视觉干扰
- **关键信息突出** - 只显示重要的协作节点

### 交互设计
- **低打扰原则** - 仅在必要时提供通知
- **一键操作** - 简化常用功能的操作流程
- **状态清晰** - 明确的任务和协作状态指示

## 🏆 最佳实践

### 协作池管理
- 合理设置成员数量，建议3-8人为最佳协作规模
- 定期查看团队默契度报告，识别协作瓶颈
- 鼓励成员主动认领任务，避免任务分配不均

### 任务设计
- 设置合理的预期时间，避免过于宽松或紧张
- 利用子任务系统进行复杂任务的分解
- 重要任务设置检查点，及时发现和解决问题

### 评分优化
- 关注质量指标，避免为追求速度而牺牲质量
- 建立良好的沟通机制，减少协作成本
- 定期回顾和调整任务分配策略

## 📋 开发计划

### 第一阶段 ✅ (已完成)
- [x] 项目架构搭建
- [x] 基础UI框架
- [x] 用户认证系统
- [x] 状态管理配置
- [x] 任务面板完整功能
- [x] 子任务管理系统

### 第二阶段 ⏳ (开发中)
- [x] 协作池完整功能
- [x] 任务管理系统
- [x] 默契值计算算法
- [ ] 数据持久化优化

### 第三阶段 📅 (计划中)
- [ ] 效率图谱分析
- [ ] 静默通知系统
- [ ] 匿名协作优化
- [ ] 性能优化

### 第四阶段 🔮 (未来规划)
- [ ] 机器学习算法优化评分准确性
- [ ] 支持更多协作场景和自定义规则
- [ ] 集成即时通讯功能
- [ ] 移动端推送通知
- [ ] 数据可视化大屏展示
- [ ] 多设备支持
- [ ] 高级分析功能

## 🚀 部署和运行

### 开发环境
```bash
# 安装依赖
flutter pub get

# 生成代码
flutter packages pub run build_runner build

# 运行调试
flutter run

# 构建发布版本
flutter build apk --release
flutter build ios --release
flutter build web --release
```

### 后端服务部署
确保Go后端服务正常运行，并在 `api_service.dart` 中配置正确的API地址。

### 环境配置
根据部署环境调整 `lib/config/app_config.dart` 中的配置参数。

## 🤝 贡献指南

我们欢迎任何形式的贡献！请按照以下步骤：

1. Fork 本项目
2. 创建你的特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交你的更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 打开一个 Pull Request

## 📄 许可证

本项目采用 MIT 许可证 - 查看 [LICENSE](LICENSE) 文件了解详情。

## 📞 联系我们

- **项目维护者**: 静默协作项目组
- **问题反馈**: 通过 GitHub Issues 提交
- **功能建议**: 欢迎通过 Pull Request 贡献

---

**最后更新**: 2025年8月  
**当前版本**: v1.2.0  
**构建状态**: ✅ 通过

> 💡 **理念**: 让协作回归本质，用技术连接人心，以数据驱动效率
