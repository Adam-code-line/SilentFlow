// widgets/index.dart - 统一组件导出文件
// 这个文件统一导出所有widgets，方便管理和使用

// ==================== 功能模块导出 ====================
// 推荐使用：按功能导入
export 'common/index.dart'; // 通用组件
export 'dialogs/index.dart'; // 对话框组件
export 'cards/index.dart'; // 卡片组件
export 'task/index.dart'; // 任务相关组件
export 'team/index.dart'; // 团队相关组件
export 'workflow/index.dart'; // 工作流相关组件

// ==================== 使用指南 ====================
/*
## 推荐的导入方式

### 1. 按功能模块导入（推荐）
import '../../widgets/task/index.dart';     // 只导入任务相关组件
import '../../widgets/team/index.dart';     // 只导入团队相关组件
import '../../widgets/common/index.dart';   // 只导入通用组件

### 2. 导入特定组件
import '../../widgets/task/task_card_widget.dart';
import '../../widgets/team/team_card.dart';

### 3. 导入全部组件（不推荐，包体积大）
import '../../widgets/index.dart';

## 组件命名规范
- 卡片组件：{功能}Card（如 TaskCard, TeamCard）
- 对话框组件：{功能}Dialog（如 TaskCreationDialog）
- 列表组件：{功能}List（如 ChildTasksList）
- 统计组件：{功能}Stats（如 TaskCompletionStats）

## 文件组织结构
widgets/
├── common/          # 通用组件（按钮、卡片基类等）
├── dialogs/         # 对话框组件
├── cards/           # 卡片组件
├── forms/           # 表单组件（待添加）
├── task/            # 任务功能相关组件
├── team/            # 团队功能相关组件
├── workflow/        # 工作流功能相关组件
└── index.dart       # 统一导出文件
*/
